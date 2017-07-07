[cmdletBinding()]
Param([switch]$Load, [switch]$NoTest)
Write-Host "PID: $pid"
If($Load) {
    If($NoTest) { $cmd = "{0} -NoTest" -f $PSCmdlet.MyInvocation.MyCommand.Source }
    Else { $cmd = "{0}" -f $PSCmdlet.MyInvocation.MyCommand.Source }
    PowerShell -noprofile -noexit -command $cmd
}
Else {
    #Clear-Host
    Write-Host "In New PowerShell Session, [exit] to resume."
    $PSModuleAutoLoadingPreference = "none"
    Import-Module $PSScriptRoot\SimplySql -Force
    Get-Module SimplySql | Where-Object Path -NotLike "$PSScriptRoot\*" | Remove-Module
    Import-Module Pester -Force

    If(-not $NoTest) {
        Invoke-Pester -Script $PSScriptRoot -TestName "Provider: SQL"
    }
    <#Get-Module SimplySql | Format-List

    Get-SqlProviderHelp -Provider SQL
    Get-SqlProviderHelp -Provider SQLite

    Open-SqlConnection -DataSource it4 -InitialCatalog sandbox 

    Show-SqlConnection

    isq "select @a" -Parameters @{a=1}

    Get-SqlProviderHelp -Provider SQL

    #>
}