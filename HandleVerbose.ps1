[cmdletBinding()]
param([parameter(Position=0)][string]$Summary, [parameter(position=1)][string]$StepValue, [parameter(ValueFromPipeline)]$thisItem)
begin { 
    if ($VerbosePreference -ne "Continue" -and -not [string]::IsNullOrWhiteSpace($summary)){
        Write-Host "  $Summary..." -NoNewline
    }
}
process {
    if($VerbosePreference -eq "Continue") { $thisItem }
    elseif(-not [string]::IsNullOrWhiteSpace($StepValue)) { Write-Host $StepValue -NoNewline}
}
end {
    if ($VerbosePreference -ne "Continue" -and -not [string]::IsNullOrWhiteSpace($summary)){
        Write-Host "Done!"
    }
}