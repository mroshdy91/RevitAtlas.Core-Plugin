function Resolve-AtlasPinnedRuntimeStatus($Diagnostic,$Descriptor,[string]$ReceiptPath) {
    # Preserve the physical diagnostic and its selected-engine details. The
    # install receipt is a read-only version pin, not a connection credential.
    $Diagnostic | Add-Member -NotePropertyName expected_runtime -NotePropertyValue @{
        version=$Descriptor.version;manifest_sha256=$Descriptor.manifest_sha256
    } -Force
    if($Diagnostic.status -in @('RUNTIME_MISSING','INSTALLED_RUNTIME_CHANGED','blocked')){return $Diagnostic}
    if(!(Test-Path -LiteralPath $ReceiptPath -PathType Leaf)){
        $Diagnostic.status='RUNTIME_IDENTITY_UNVERIFIED'
        $Diagnostic.next_action='The active installation receipt is missing. Inspect the current installation and run the pinned setup when authorized; do not infer compatibility from a running broker.'
        $Diagnostic | Add-Member -NotePropertyName active_runtime -NotePropertyValue @{receipt_present=$false} -Force
        return $Diagnostic
    }
    try{
        $record=Get-Content -LiteralPath $ReceiptPath -Raw | ConvertFrom-Json
        $installedHash=[string]$record.manifest_sha256
        if($record.format_version -ne 2 -or $record.status -cne 'installed' -or $installedHash -notmatch '^[a-fA-F0-9]{64}$'){
            throw 'ACTIVE_RECEIPT_INVALID'
        }
        $Diagnostic | Add-Member -NotePropertyName active_runtime -NotePropertyValue @{
            receipt_present=$true;version=$record.version;manifest_sha256=$installedHash.ToLowerInvariant()
        } -Force
        if($installedHash.ToLowerInvariant() -cne $Descriptor.manifest_sha256.ToLowerInvariant()){
            $Diagnostic.status='RUNTIME_UPDATE_REQUIRED'
            $Diagnostic.next_action='The installed runtime differs from this plugin release. Save work and close Revit normally, then run the packaged pinned setup helper when authorized.'
        }
    }catch{
        $Diagnostic.status='RUNTIME_IDENTITY_UNVERIFIED'
        $Diagnostic.next_action='The active installation receipt cannot prove this runtime version. Inspect the current installation and use the pinned setup helper when authorized.'
        $Diagnostic | Add-Member -NotePropertyName active_runtime -NotePropertyValue @{receipt_present=$true;receipt_valid=$false} -Force
    }
    return $Diagnostic
}
