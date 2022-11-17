$outputFolder = Join-Path $PSScriptRoot "Output"
$binFolder = Join-Path $outputFolder "bin"
$cmdletFolder = Resolve-Path .\
$engineFolder = $cmdletFolder -replace "\\SimplySql\.Cmdlets\\", "\SimplySql.Engine\"
$primaryList = @("SimplySql.Common.dll", "SimplySql.Cmdlets.dll")

if(Test-Path $outputFolder) { Remove-Item -Path $outputFolder -Force -Recurse}
New-Item -Path $outputFolder -ItemType Directory | Out-Null
New-Item -Path $binFolder -ItemType Directory | Out-Null

Get-ChildItem -Path $engineFolder -Filter *.dll -File |
	Copy-Item -Destination $binFolder 

Get-ChildItem -Path $cmdletFolder -Filter *.dll -File |
	Where-Object { $_.Name -in $primaryList } |
	Copy-Item -Destination $outputFolder
	
Set-Location $PSScriptRoot

Import-Module .\Output\SimplySql.Cmdlets.dll -Verbose