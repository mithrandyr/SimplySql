#check to see if BinarySrc version matches ScriptSrc version
$ErrorActionPreference = "Stop"
$binarySrcVersion = Join-Path $PSScriptRoot "BinarySrc\bin\Release\SimplySql.dll" |
    Get-Item |
    Select-Object -ExpandProperty versioninfo |
    Select-Object -ExpandProperty ProductVersion

$scriptSrcVersion = [version](Import-PowerShellDataFile -Path (Join-Path $PSScriptRoot "ScriptSrc\SimplySql.psd1" )).ModuleVersion

Write-Host "BinaryVersion:", $binarySrcVersion
Write-Host "ScriptVersion:", $scriptSrcVersion