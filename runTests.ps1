param(
    [ValidateSet("pwsh","powershell")][string]$env = "pwsh"
    , [ValidateSet("mssql","mysql","postgre","oracle","sqlite")][string[]]$Tests
    , [switch]$Interactive
)

$arglist = @()
$arglist += "-NoProfile", "-NoLogo"
if($Interactive){ $arglist += "-NoExit" }


$arglist += "-Command function prompt {'TESTING> '}; Import-Module .\Output\SimplySql; 'SimplySql Version: {0}' -f (Get-Module SimplySql | Select-Object -ExpandProperty Version)"
if($tests.count -gt 0) {
    $arglist += "; Invoke-Pester @({0}) -output detailed" -f ($Tests.ForEach({"'.\Tests\$_.tests.ps1'"}) -join ", ")
}

Start-Process -FilePath $env -ArgumentList $arglist -NoNewWindow -Wait -WorkingDirectory $PSScriptRoot

