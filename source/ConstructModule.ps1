$outputFolder = Join-Path $PSScriptRoot "Output"
$binFolder = Join-Path $outputFolder "bin"
$cmdletFolder = Resolve-Path .\
$engineFolder = $cmdletFolder -replace "\\SimplySql\.Cmdlets\\", "\SimplySql.Engine\"
$primaryList = @("SimplySql.Common.dll", "SimplySql.Cmdlets.dll", "EnumerableToDataReader.dll")

if(Test-Path $outputFolder) { Remove-Item -Path $outputFolder -Force -Recurse}
New-Item -Path $outputFolder -ItemType Directory | Out-Null
New-Item -Path $binFolder -ItemType Directory | Out-Null

Get-ChildItem -Path $engineFolder -Filter *.dll -File -Recurse |
	Copy-Item -Destination $binFolder 

Get-ChildItem -Path $cmdletFolder -Filter *.dll -File |
	Where-Object { $_.Name -in $primaryList } |
	Copy-Item -Destination $outputFolder
	
Set-Location $PSScriptRoot

#Process SQLite Interops
$Platforms = @("linux-x64", "osx-x64", "win-x64", "win-x86")
$Version = Get-Item "Output\bin\System.Data.SQLite.dll" | Select-Object -ExpandProperty VersionInfo | Select-Object -ExpandProperty FileVersion
$Version = $Version.Substring(0, $Version.Length - 2)
$SQLitePath = "$home\.nuget\packages\system.data.sqlite.core\$version\runtimes"
$SQLiteDll = Join-Path $binFolder "System.Data.SQLite.dll"

foreach ($p in $Platforms) {
	$dstPath = Join-Path $binFolder $p	
	$srcPath = Join-Path $SQLitePath "$p\native\netstandard2.0\SQLite.Interop.dll"
	
	New-Item -ItemType Directory -Path $dstPath | Out-Null
	Copy-Item -Path $srcPath -Destination $dstPath #interop File
	Copy-Item -Path $SQLiteDll -Destination $dstPath
}
Remove-Item -Path $SQLiteDll

Import-Module .\Output\SimplySql.Cmdlets.dll -Verbose