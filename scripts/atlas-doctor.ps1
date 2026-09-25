# Read-only physical installation and live engine diagnostic. Windows PowerShell 5.1+.
[CmdletBinding()]param([string]$ResultPath,[switch]$Independent)
. (Join-Path $PSScriptRoot 'atlas-release-pin.ps1')
$ErrorActionPreference='Stop'
$taskDoctorClock=[Diagnostics.Stopwatch]::StartNew()
if(!('AtlasDoctorNative' -as [type])){Add-Type -TypeDefinition @'
using System;using System.IO;using System.IO.Pipes;using System.Text;using System.Runtime.InteropServices;using System.Threading;using System.Diagnostics;using System.Threading.Tasks;
public sealed class AtlasDoctorProbe {public bool TimedOut;public bool HelperExited;public int HelperPid;public int ExitCode;public string Output;public string Error;}
public static class AtlasDoctorNative {
 [DllImport("kernel32.dll",CharSet=CharSet.Unicode,SetLastError=true)]public static extern uint GetFinalPathNameByHandle(IntPtr h,StringBuilder p,uint n,uint f);
 public static string Physical(string path){using(var f=File.OpenRead(path)){var b=new StringBuilder(32768);uint n=GetFinalPathNameByHandle(f.SafeFileHandle.DangerousGetHandle(),b,32768,0);if(n==0||n>=32768)throw new IOException("PHYSICAL_PATH_QUERY_FAILED");return b.ToString();}}
 static void Read(PipeStream p,byte[] b,CancellationToken t){int i=0;while(i<b.Length){int n=p.ReadAsync(b,i,b.Length-i,t).GetAwaiter().GetResult();if(n==0)throw new EndOfStreamException();i+=n;}}
 public static string Status(string name){using(var p=new NamedPipeClientStream(".",name,PipeDirection.InOut,PipeOptions.Asynchronous)){p.Connect(2000);using(var c=new CancellationTokenSource(3000))using(c.Token.Register(delegate{p.Dispose();})){byte[] body=Encoding.UTF8.GetBytes("{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"get_status\",\"params\":{}}");byte[] header=BitConverter.GetBytes(System.Net.IPAddress.HostToNetworkOrder(body.Length));p.WriteAsync(header,0,4,c.Token).GetAwaiter().GetResult();p.WriteAsync(body,0,body.Length,c.Token).GetAwaiter().GetResult();Read(p,header,c.Token);int length=System.Net.IPAddress.NetworkToHostOrder(BitConverter.ToInt32(header,0));if(length<1||length>1048576)throw new IOException("STATUS_FRAME_INVALID");body=new byte[length];Read(p,body,c.Token);return Encoding.UTF8.GetString(body);}}}
 // Kill only this short-lived, owned diagnostic helper when its WMI provider
 // stalls. A provider-side launch may still complete: never claim cancellation
 // of that launch, stop Revit, or automatically submit a second request.
 public static AtlasDoctorProbe Probe(string script,int budgetMs){
  if(budgetMs<100||budgetMs>10000)throw new ArgumentOutOfRangeException("budgetMs");
  var start=new ProcessStartInfo(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System),@"WindowsPowerShell\v1.0\powershell.exe"),"-NoLogo -NoProfile -NonInteractive -EncodedCommand "+Convert.ToBase64String(Encoding.Unicode.GetBytes(script)));
  start.UseShellExecute=false;start.CreateNoWindow=true;start.WindowStyle=ProcessWindowStyle.Hidden;start.RedirectStandardOutput=true;start.RedirectStandardError=true;
  using(var p=Process.Start(start)){
   var output=p.StandardOutput.ReadToEndAsync();var error=p.StandardError.ReadToEndAsync();var result=new AtlasDoctorProbe{HelperPid=p.Id};
   if(!p.WaitForExit(budgetMs)){result.TimedOut=true;try{p.Kill();}catch(InvalidOperationException){}p.WaitForExit(1000);}
   result.HelperExited=p.HasExited;result.ExitCode=result.HelperExited?p.ExitCode:-1;
   if(Task.WaitAll(new Task[]{output,error},1000)){result.Output=output.Result;result.Error=error.Result;}else result.TimedOut=true;
   return result;
  }
 }
}
'@}
function Hash([string]$p){$s=[IO.File]::OpenRead($p);$h=[Security.Cryptography.SHA256]::Create();try{([BitConverter]::ToString($h.ComputeHash($s))).Replace('-','')}finally{$s.Dispose();$h.Dispose()}}
function Physical([string]$p){$v=[AtlasDoctorNative]::Physical($p);if($v.StartsWith('\\?\')){$v=$v.Substring(4)};return $v}
function FileInfo([string]$p){if(!(Test-Path -LiteralPath $p)){return @{path=$p;status='missing'}};return @{path=$p;physical_path=(Physical $p);sha256=(Hash $p);status='present'}}
function Publish($r){$json=$r|ConvertTo-Json -Depth 15;if($ResultPath){[IO.File]::WriteAllText([IO.Path]::GetFullPath($ResultPath),$json)};$json}
try{
 if($ResultPath -and (Test-Path -LiteralPath $ResultPath) -and (Get-Item -LiteralPath $ResultPath).Length -gt 0){throw 'DOCTOR_RESULT_EXISTS: use a fresh path to avoid stale diagnostic evidence'}
 $taskRoot=Join-Path $env:LOCALAPPDATA 'Atlas';$taskNative=Join-Path $env:LOCALAPPDATA 'RevitFamilyBuilder';$taskConfig=Join-Path $taskRoot 'broker-installation.json'
 $taskRedirected=(Test-Path $taskConfig) -and !([string]::Equals((Physical $taskConfig),[IO.Path]::GetFullPath($taskConfig),[StringComparison]::OrdinalIgnoreCase))
 if($taskRedirected -and !$Independent){
  $taskScript=Physical $PSCommandPath
  if(!$ResultPath){$ResultPath=Physical ([IO.Path]::GetTempFileName())}
  foreach($p in @($taskScript,$ResultPath)){if($p.Contains('"')){throw 'DOCTOR_LAUNCH_PATH_INVALID'}}
  $taskCommand='"'+$env:WINDIR+'\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -File "'+$taskScript+'" -Independent -ResultPath "'+$ResultPath+'"'
  $taskProbeScript='$ErrorActionPreference=''Stop''; $taskStartup=New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{ShowWindow=[uint16]0}; Invoke-CimMethod -ClassName Win32_Process -MethodName Create -OperationTimeoutSec 5 -Arguments @{CommandLine='''+$taskCommand.Replace("'","''")+''';ProcessStartupInformation=$taskStartup} | Select-Object ReturnValue,ProcessId | ConvertTo-Json -Compress'
  $taskProbe=[AtlasDoctorNative]::Probe($taskProbeScript,6000)
  if($taskProbe.TimedOut -or $taskProbe.ExitCode -ne 0){
   if((Test-Path -LiteralPath $ResultPath) -and (Get-Item -LiteralPath $ResultPath).Length -gt 0){Get-Content -LiteralPath $ResultPath -Raw;return}
   @{status='launch_unknown';code='INDEPENDENT_DOCTOR_LAUNCH_UNAVAILABLE';diagnostic_helper_pid=$taskProbe.HelperPid;helper_exited=$taskProbe.HelperExited;timed_out=$taskProbe.TimedOut;result_path=$ResultPath;physical_installation_verified=$false;model_changed=$false;credentials_printed=$false;next_action='The Windows provider did not confirm the independent diagnostic launch. Retain this result path and inspect it later; do not repeat the launch or infer runtime health.'}|ConvertTo-Json;return
  }
  $taskLaunch=$taskProbe.Output|ConvertFrom-Json
  if($taskLaunch.ReturnValue -ne 0){throw 'INDEPENDENT_DOCTOR_LAUNCH_FAILED'}
  while($taskDoctorClock.Elapsed.TotalSeconds -lt 20){if((Test-Path $ResultPath) -and (Get-Item $ResultPath).Length -gt 0){Get-Content -LiteralPath $ResultPath -Raw;return};Start-Sleep -Milliseconds 250}
  @{status='pending';process_id=$taskLaunch.ProcessId;result_path=$ResultPath;next_action='Read the retained diagnostic result; do not launch another diagnostic.'}|ConvertTo-Json;return
 }
 if($taskRedirected){throw 'PACKAGED_HOST_REDIRECTION_UNRESOLVED'}
 $taskSelected=$null
 if(Test-Path $taskConfig){$taskSelected=Get-Content $taskConfig -Raw|ConvertFrom-Json}
 $taskNativeSelections=@('2025','2026'|ForEach-Object{$p=Join-Path $taskNative ('active-core-'+$_+'.txt');if(Test-Path $p){$v=[IO.File]::ReadAllText($p).Trim();@{revit_version=$_;selection=(FileInfo $p);engine=(FileInfo $v)}}})
 $taskSessions=@();$taskSessionRoot=Join-Path $taskNative 'sessions'
 if(Test-Path $taskSessionRoot){foreach($f in Get-ChildItem $taskSessionRoot -Filter '*.json'){
  try{$s=Get-Content $f.FullName -Raw|ConvertFrom-Json;$p=Get-Process -Id $s.pid -ErrorAction SilentlyContinue;if(!$p -or $p.ProcessName -ne 'Revit'){continue};$reply=[AtlasDoctorNative]::Status($s.pipe_name)|ConvertFrom-Json;if($reply.error){throw $reply.error.message};$r=$reply.result
   $selected=@($taskNativeSelections|Where-Object revit_version -eq $r.revit_version)
   $taskSessions+=@{session_id=$r.session_id;pid=$r.pid;revit_version=$r.revit_version;engine_path=$r.engine_path;engine_sha256=$r.engine_sha256;matches_selected=($selected.Count -eq 1 -and $selected[0].engine.sha256 -eq $r.engine_sha256);running=$r.running;queued=$r.queued;dispatcher_observation=$r.dispatcher_observation;hardening_supported=($r.capabilities -contains 'family_authoring_hardening_v1');status='responding'}
  }catch{$taskSessions+=@{session_file=$f.Name;status='unavailable';error=$_.Exception.Message}}
 }}
 $taskBrokers=@(Get-Process -Name Atlas.Broker -ErrorAction SilentlyContinue|ForEach-Object{
  $taskBrokerProcess=$_
  try{$taskExecutable=$taskBrokerProcess.Path;if(!$taskExecutable){throw 'BROKER_PATH_UNAVAILABLE'};@{pid=$taskBrokerProcess.Id;executable=(FileInfo $taskExecutable);assembly=(FileInfo (Join-Path (Split-Path $taskExecutable -Parent) 'Atlas.Broker.dll'));matches_selected=($taskSelected -and $taskExecutable -eq $taskSelected.executable);status='inspected'}}
  catch{@{pid=$taskBrokerProcess.Id;status='unavailable';error=$_.Exception.Message}}
 })
 $taskPlugin=Get-Content (Join-Path (Split-Path $PSScriptRoot -Parent) '.codex-plugin/plugin.json') -Raw|ConvertFrom-Json
 $taskSelectedReport=if($taskSelected){@{executable=(FileInfo $taskSelected.executable);assembly=(FileInfo (Join-Path (Split-Path $taskSelected.executable -Parent) 'Atlas.Broker.dll'));expected_executable_sha256=$taskSelected.sha256;expected_assembly_sha256=$taskSelected.assembly_sha256}}else{$null}
 $taskStatus=if(!$taskSelected){'RUNTIME_MISSING'}elseif(@($taskSessions|Where-Object status -eq 'responding').Count -eq 0){'NO_RESPONDING_REVIT_SESSION'}elseif(@($taskSessions|Where-Object {$_.status -eq 'responding' -and !$_.matches_selected}).Count){'LOADED_ENGINE_DIFFERS_FROM_SELECTION'}else{'RESPONDING'}
 if($taskSelected -and ($taskSelectedReport.executable.sha256 -ne $taskSelected.sha256 -or $taskSelectedReport.assembly.sha256 -ne $taskSelected.assembly_sha256)){$taskStatus='INSTALLED_RUNTIME_CHANGED'}
 $taskDiagnostic=@{status=$taskStatus;physical_installation_verified=$true;independent_process=[bool]$Independent;plugin=@{name=$taskPlugin.name;version=$taskPlugin.version;path=(Split-Path $PSScriptRoot -Parent);client_cached_tool_schema='Use atlas_catalog to verify the connected broker contract; this file version cannot establish the current conversation cache.'};selected_broker=$taskSelectedReport;running_brokers=$taskBrokers;selected_engines=$taskNativeSelections;live_sessions=$taskSessions;credential_present=([bool][Environment]::GetEnvironmentVariable('ATLAS_BEARER_TOKEN','User'));credentials_printed=$false;model_changed=$false;next_action='Compare selected and loaded identities. Close owned work normally before an engine restart. A responding engine is not family acceptance. The separate RevitAtlas port-8090 add-in is outside Atlas Core.'}
 $taskDescriptor=Get-Content -LiteralPath (Join-Path (Split-Path $PSScriptRoot -Parent) 'runtime-release.json') -Raw|ConvertFrom-Json
 $taskReceipt=Join-Path $taskRoot 'active-install.json'
 Publish (Resolve-AtlasPinnedRuntimeStatus $taskDiagnostic $taskDescriptor $taskReceipt)
}catch{$taskFailure=@{status='blocked';code=$_.Exception.Message;model_changed=$false;credentials_printed=$false};if($_.Exception.Message.StartsWith('DOCTOR_RESULT_EXISTS')){$taskFailure|ConvertTo-Json}else{Publish $taskFailure};exit 1}
