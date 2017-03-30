[cmdletBinding()]
Param([switch]$Load)

If($Load) {
    $cmd = "{0}" -f $PSCmdlet.MyInvocation.MyCommand.Source
    PowerShell -noprofile -noexit -command $cmd
}
Else {
    Write-Host "In New PowerShell Session, [exit] to resume."
    $PSModuleAutoLoadingPreference = "none"
    Import-Module $PSScriptRoot -Force
    Get-Module SimplySql | Format-List

    Open-SqlConnection -DataSource it4 -InitialCatalog sandbox 

    Show-SqlConnection

    isq "select @a" -Parameters @{a=1}
}