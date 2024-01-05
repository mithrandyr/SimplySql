Invoke-Build -DebugOnly

$PSModuleAutoLoadingPreference = "none"
Import-Module .\Output\SimplySql.Cmdlets.dll -Verbose
Import-Module microsoft.powershell.security