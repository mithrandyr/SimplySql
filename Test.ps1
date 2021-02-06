[cmdletBinding()]
Param([switch]$Load, [switch]$NoTest, [string]$TestName)
If($Load) {
    Write-Host "Original PID: $pid"
    If($NoTest) { $cmd = "{0} -NoTest" -f $PSCmdlet.MyInvocation.MyCommand.Source }
    Else { 
        If($TestName) { $cmd = "{0} -TestName '{1}'" -f $PSCmdlet.MyInvocation.MyCommand.Source, $TestName }
        Else { $cmd = "{0}" -f $PSCmdlet.MyInvocation.MyCommand.Source }
    }
    PowerShell -noprofile -noexit -command $cmd
    if($global:IsNestedSessionSimplySql) { Write-Warning "Exited one session, but currently in another nested session!" }
    else { Write-Warning "You have exited the last nested session."}
}
Else {
    Write-Host "Session PID: $pid"
    #Clear-Host
    Write-Host "In New PowerShell Session, [exit] to resume."
    $global:IsNestedSessionSimplySql = $true

    $PSModuleAutoLoadingPreference = "none"
    Get-Module SimplySql | Where-Object Path -NotLike "$PSScriptRoot\*" | Remove-Module
    Import-Module $PSScriptRoot\Output\SimplySql.psd1 -Force    
    Import-Module Pester -Force
    Write-Host ("Loaded '{0}' of SimplySql!" -f (Get-Module SimplySql).Version.ToString())

    If(-not $NoTest) {
        If($TestName) { Invoke-Pester -Script $PSScriptRoot -TestName $TestName }
        Else { Invoke-Pester -Script $PSScriptRoot }
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