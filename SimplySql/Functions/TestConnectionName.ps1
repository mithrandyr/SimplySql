Filter TestConnectionName {
    Param([parameter(Mandatory, ValueFromPipeline)][string]$ConnectionName
        , [switch]$Quiet)
    
    If(-not $Script:Connections.ContainsKey($ConnectionName)) {
        If(-not $Quiet.IsPresent) {
            If($ConnectionName -eq "Default") { Write-Warning "There is no active SQL Connection."}
            Else { Write-Warning "There is no active SQL connection ($ConnectionName)."}
        }
        Return $false
    }
    Else {
        Return $true
    }
}