[cmdletBinding()]
Param([switch]$Load)

If($Load) {
    $cmd = "{0}" -f $PSCmdlet.MyInvocation.MyCommand.Source
    PowerShell -noprofile -noexit -command $cmd
}
Else {
    Clear-Host
    Write-Host "In New PowerShell Session, [exit] to resume."
    $PSModuleAutoLoadingPreference = "none"
    Import-Module $PSScriptRoot -Force
    Get-Module SimplySql | Format-List

    Get-SqlProviderHelp -Provider SQL
    Get-SqlProviderHelp -Provider SQLite

    Open-SqlConnection -DataSource it4 -InitialCatalog sandbox 

    Show-SqlConnection

    isq "select @a" -Parameters @{a=1}

    Get-SqlProviderHelp -Provider SQL
}