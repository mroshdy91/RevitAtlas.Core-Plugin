# Windows PowerShell 5.1+; no SDK, GitHub account or existing MCP connection required.
[CmdletBinding()]
param(
    [ValidateSet('Doctor','Install')][string]$Action='Doctor',
    [string]$DescriptorPath
)
$ErrorActionPreference='Stop'
if([string]::IsNullOrWhiteSpace($DescriptorPath)){
    $DescriptorPath=Join-Path (Split-Path $PSScriptRoot -Parent) 'runtime-release.json'
}

function Get-AtlasHash([string]$Path) {
    # Avoid script-module discovery differences when clients inherit another
    # PowerShell version's module path. Hash the exact file bytes in both hosts.
    $stream=[IO.File]::OpenRead($Path)
    $algorithm=[Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($algorithm.ComputeHash($stream))).Replace('-','').ToLowerInvariant() }
    finally { $algorithm.Dispose();$stream.Dispose() }
}
function Resolve-AtlasMember([string]$Root,[string]$Relative) {
    if(!$Relative -or $Relative -match '[\\:]|(^|/)\.\.?(/|$)' -or [IO.Path]::IsPathRooted($Relative)){throw 'ARCHIVE_PATH_INVALID'}
    $base=[IO.Path]::GetFullPath($Root).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar
    $path=[IO.Path]::GetFullPath((Join-Path $base $Relative))
    if(!$path.StartsWith($base,[StringComparison]::OrdinalIgnoreCase)){throw 'ARCHIVE_PATH_INVALID'}
    return $path
}
function Expand-AtlasArchive([string]$Archive,[string]$Destination) {
    Add-Type -AssemblyName System.IO.Compression,System.IO.Compression.FileSystem
    $zip=[IO.Compression.ZipFile]::OpenRead($Archive)
    try {
        $seen=@{};$size=[long]0
        foreach($entry in $zip.Entries){
            $path=Resolve-AtlasMember $Destination $entry.FullName
            if($seen.ContainsKey($path)){throw 'ARCHIVE_DUPLICATE_PATH'};$seen[$path]=$true
            $size+=$entry.Length
            if($size -gt 2147483648 -or $zip.Entries.Count -gt 10000){throw 'ARCHIVE_LIMIT_EXCEEDED'}
            if(($entry.ExternalAttributes -shr 16 -band 0xF000) -eq 0xA000){throw 'ARCHIVE_LINK_NOT_ALLOWED'}
        }
        foreach($entry in $zip.Entries){
            $path=Resolve-AtlasMember $Destination $entry.FullName
            if($entry.FullName.EndsWith('/')){[IO.Directory]::CreateDirectory($path)|Out-Null;continue}
            [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($path))|Out-Null
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$path,$false)
        }
    } finally {$zip.Dispose()}
}
function Get-AtlasPhysicalFile([string]$Path){
    # The verified installer loads this tiny Windows path-query helper before
    # reporting packaged-host redirection. Resolve exact files, never enumerate
    # or relocate somebody else's runtime state.
    if(!('AtlasSetupPhysicalPath' -as [type])){throw 'PHYSICAL_PATH_HELPER_UNAVAILABLE'}
    $stream=[IO.File]::OpenRead($Path)
    try{
        $buffer=[Text.StringBuilder]::new(32768)
        $count=[AtlasSetupPhysicalPath]::GetFinalPathNameByHandle($stream.SafeFileHandle.DangerousGetHandle(),$buffer,32768,0)
        if($count -eq 0 -or $count -ge 32768){throw 'PHYSICAL_PATH_QUERY_FAILED'}
        $physical=$buffer.ToString();if($physical.StartsWith('\\?\')){$physical=$physical.Substring(4)}
        return $physical
    }finally{$stream.Dispose()}
}
function Invoke-AtlasIndependentSetup([string]$Installer,[string]$Package,[string]$Hash){
    $physicalInstaller=Get-AtlasPhysicalFile $Installer
    $physicalPackage=[IO.Path]::GetDirectoryName((Get-AtlasPhysicalFile (Join-Path $Package 'release.json')))
    $resultPath=Join-Path ([IO.Path]::GetDirectoryName($physicalPackage)) 'independent-setup-result.json'
    foreach($p in @($physicalInstaller,$physicalPackage,$resultPath)){if($p.Contains('"')){throw 'SETUP_LAUNCH_PATH_INVALID'}}
    $command='"'+$env:WINDIR+'\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -File "'+$physicalInstaller+'" -Action Install -PackageRoot "'+$physicalPackage+'" -ExpectedManifestSha256 '+$Hash+' -ResultPath "'+$resultPath+'"'
    $startup=New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{ShowWindow=[uint16]0}
    $launch=Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine=$command;ProcessStartupInformation=$startup}
    if($launch.ReturnValue -ne 0){throw 'INDEPENDENT_SETUP_LAUNCH_FAILED'}
    $timer=[Diagnostics.Stopwatch]::StartNew()
    while($timer.Elapsed.TotalSeconds -lt 45){
        if(Test-Path -LiteralPath $resultPath){return (Get-Content -LiteralPath $resultPath -Raw|ConvertFrom-Json)}
        Start-Sleep -Milliseconds 500
    }
    return @{status='pending';process_id=$launch.ProcessId;result_path=$resultPath;next_action='Read this retained result when available. Do not start a second installer or kill the process.'}
}
function Invoke-AtlasSetup {
    $descriptor=Get-Content -LiteralPath $DescriptorPath -Raw|ConvertFrom-Json
    if($descriptor.format_version -ne 1 -or $descriptor.product -cne 'RevitAtlas'){throw 'SETUP_DESCRIPTOR_INVALID'}
    if($Action -eq 'Doctor' -and $descriptor.status -eq 'published'){return (& (Join-Path $PSScriptRoot 'atlas-doctor.ps1')|ConvertFrom-Json)}
    $root=Join-Path $env:LOCALAPPDATA 'Atlas'
    $installed=Test-Path -LiteralPath (Join-Path $root 'broker-installation.json')
    $revit=@('2025','2026'|Where-Object {Test-Path -LiteralPath (Join-Path $env:ProgramFiles "Autodesk/Revit $_/Revit.exe")})
    $running=@(Get-Process -Name Revit -ErrorAction SilentlyContinue).Count
    if($Action -eq 'Doctor'){
        $code='RUNTIME_MISSING';$next='Install the pinned official runtime using this helper.'
        if($installed){
            $code='RUNTIME_PRESENT';$next='Check atlas_status; presence alone does not prove a compatible connected engine.'
            $config=Get-Content -LiteralPath (Join-Path $root 'broker-installation.json') -Raw|ConvertFrom-Json
            if(!(Test-Path -LiteralPath $config.executable) -or (Get-AtlasHash $config.executable) -ne $config.sha256){$code='INSTALLED_RUNTIME_CHANGED';$next='Do not run the altered runtime. Reinstall the pinned official package after preserving the existing setup receipt.'}
            elseif($running -eq 0){$code='REVIT_CLOSED';$next='Open the requested supported Revit version, then check atlas_status.'}
            $stored=[Environment]::GetEnvironmentVariable('ATLAS_BEARER_TOKEN','User')
            if(!$stored){$code='CLIENT_CONFIGURATION_MISSING';$next='Run Install to provision the local connection; do not print or ask the user for credentials.'}
            elseif($env:ATLAS_BEARER_TOKEN -cne $stored){$code='CLIENT_RESTART_REQUIRED';$next='Restart the AI client so it inherits the local connection credential.'}
        }
        if($descriptor.status -cne 'published'){$code='PUBLIC_RUNTIME_NOT_RELEASED';$next=$descriptor.reason}
        elseif($revit.Count -eq 0){$code='REVIT_PREREQUISITE_MISSING';$next='Install licensed Revit 2025 or 2026. Atlas cannot install Autodesk software.'}
        elseif($running -gt 0 -and !$installed){$code='REVIT_RESTART_REQUIRED';$next='Save work and close Revit normally before setup. Do not terminate it.'}
        return @{status=$code;runtime_present=$installed;detected_revit_versions=$revit;running_revit_processes=$running;release_status=$descriptor.status;next_action=$next;credentials_printed=$false}
    }
    if($descriptor.status -cne 'published'){throw 'PUBLIC_RUNTIME_NOT_RELEASED: no installation was attempted'}
    if($revit.Count -eq 0){throw 'REVIT_PREREQUISITE_MISSING'}
    if($running -gt 0){throw 'REVIT_RESTART_REQUIRED: save work and close Revit normally'}
    if($descriptor.version -notmatch '^[0-9]+\.[0-9]+\.[0-9]+(?:-[a-zA-Z0-9.-]+)?$'){throw 'SETUP_VERSION_INVALID'}
    $prefix='https://github.com/mroshdy91/RevitAtlas.Core-Plugin/releases/download/v'+$descriptor.version+'/'
    if(!$descriptor.asset_url.StartsWith($prefix,[StringComparison]::Ordinal) -or $descriptor.asset_url.Substring($prefix.Length) -notmatch '^[a-zA-Z0-9_.-]+\.zip$'){throw 'SETUP_ORIGIN_INVALID'}
    foreach($field in @('asset_sha256','manifest_sha256','installer_sha256')){if($descriptor.$field -notmatch '^[a-fA-F0-9]{64}$'){throw 'SETUP_PIN_MISSING'}}
    $stage=Join-Path ([IO.Path]::GetTempPath()) ('RevitAtlas-setup-'+[Guid]::NewGuid().ToString('N'))
    [IO.Directory]::CreateDirectory($stage)|Out-Null
    $archive=Join-Path $stage 'runtime.zip'
    [Net.ServicePointManager]::SecurityProtocol=[Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing -Uri $descriptor.asset_url -OutFile $archive
    if((Get-AtlasHash $archive) -cne $descriptor.asset_sha256.ToLowerInvariant()){throw 'DOWNLOAD_HASH_MISMATCH: nothing was executed'}
    $package=Join-Path $stage 'package';Expand-AtlasArchive $archive $package
    if((Get-AtlasHash (Join-Path $package 'release.json')) -cne $descriptor.manifest_sha256.ToLowerInvariant()){throw 'MANIFEST_HASH_MISMATCH'}
    $installer=Join-Path $package 'install-runtime.ps1'
    if((Get-AtlasHash $installer) -cne $descriptor.installer_sha256.ToLowerInvariant()){throw 'INSTALLER_HASH_MISMATCH'}
    $result=& $installer -Action Install -PackageRoot $package -ExpectedManifestSha256 $descriptor.manifest_sha256|ConvertFrom-Json
    if($result.code -like 'PACKAGED_HOST_REDIRECTION:*'){$result=Invoke-AtlasIndependentSetup $installer $package $descriptor.manifest_sha256}
    if($result.status -notin @('installed','already_installed','pending')){throw ($result.code)}
    return $result
}
if($MyInvocation.InvocationName -ne '.'){
    try {Invoke-AtlasSetup|ConvertTo-Json -Depth 8}
    catch { @{status='blocked';code=$_.Exception.Message;changes_may_be_partial=($Action -eq 'Install');next_action='Use the reported condition and any installation receipt. Do not bypass integrity checks or Windows policy.'}|ConvertTo-Json -Depth 5;exit 1 }
}
