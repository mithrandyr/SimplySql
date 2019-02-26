Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Script:Connections = @{}
#$Script:Providers = @{}

#Add Type for translating DataReader to PSObject
#Repo for source code is at https://github.com/mithrandyr/DataReaderToPSObject
Add-Type -Path "$PSScriptRoot\DataReaderToPSObject\DataReaderToPSObject.dll"

#Load up base Classes
. "$PSScriptRoot\Classes.ps1"

#Load Up Internal Functions
Get-ChildItem "$PSScriptRoot\Functions" -File | ForEach-Object { . $_.FullName }

#Load up providers
ForEach($f in Get-ChildItem "$PSScriptRoot\Providers\" -Directory) {
    $Configfile = (Join-Path $f.FullName ("config.ps1" -f $f.name))
    
    If(Test-Path $ConfigFile) {
        Try { . $ConfigFile }
        Catch { Write-Warning ("'{0}' Provider Failed to Load: {1}" -f $f.Name, $_.ToString()) }
    }
}

If(@(Get-Command -Module SimplySql -Verb Open).Count -eq 0) { Write-Error "No Providers were loaded!" }
Else {
    #Load Cmdlets
    Get-ChildItem "$PSScriptRoot\Cmdlets" -File | ForEach-Object { . $_.FullName }
}

Remove-Variable f, Configfile