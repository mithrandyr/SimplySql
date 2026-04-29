Invoke-Build -DebugOnly

$PSModuleAutoLoadingPreference = "none"
Import-Module .\Output\SimplySql.Cmdlets.dll -Verbose
Import-Module microsoft.powershell.security

Write-Host " call 'RunTests' to execute pester tests..."
function RunTests([ValidateSet("mssql","mysql","postgre","oracle","sqlite")][string[]]$Tests = @("mssql","mysql","postgre","oracle","sqlite")) {
    Import-Module Pester
    $testsToRun = ($Tests.ForEach({"..\Tests\$_.tests.ps1"}) -join ", ")
    Invoke-Pester @($testsToRun) -output detailed
}