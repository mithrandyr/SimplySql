param(
    [ValidateSet("pwsh","powershell")][string]$env = "pwsh"
    , [ValidateSet("mssql","mysql","postgre","oracle","sqlite")][string[]]$Tests = "sqlite"
    , [switch]$Interactive
)

$arglist = @()
$arglist += "-NoProfile", "-NoLogo"
if($Interactive){ $arglist += "-NoExit" }


$arglist += "-Command function prompt {'TESTING> '}; Import-Module .\Output\SimplySql"
if($tests.count -gt 0) {
    $arglist += "; Invoke-Pester @({0}) -output detailed" -f ($Tests.ForEach({"'.\Tests\$_.tests.ps1'"}) -join ", ")
}

Start-Process -FilePath $env -ArgumentList $arglist -NoNewWindow -Wait -WorkingDirectory $PSScriptRoot

