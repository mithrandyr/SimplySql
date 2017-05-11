Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Script:Connections = @{}
$Script:Providers = @{}

#Add Type for translating DataReader to PSObject
#Repo for source code is at https://github.com/mithrandyr/DataReaderToPSObject
Add-Type -Path "$PSScriptRoot\DataReaderToPSObject.dll"

#Load up base Classes
"SqlMessage","ProviderConfig","ProviderBase" |
    ForEach-Object { . (Join-Path -Path "$PSScriptRoot\Classes" -ChildPath "$_.ps1") }

#Load Up Internal Functions
Get-ChildItem "$PSScriptRoot\Functions" -File | ForEach-Object { . $_.FullName }

#Load up providers
ForEach($f in Get-ChildItem "$PSScriptRoot\Providers\" -Directory) {
    $Configfile = (Join-Path $f.FullName ("{0}.ps1" -f $f.name))
    $ProviderFile = (Join-Path $f.FullName ("{0}Provider.ps1" -f $f.name))
    $InitFile = (Join-Path $f.FullName ("Init.ps1" -f $f.name))

    If((Test-Path $ConfigFile) -and (Test-Path $ProviderFile)) {
        Try {
            If(Test-Path $InitFile) { . $InitFile }
            . $ProviderFile
            $Script:Providers[$f.name] = &$ConfigFile
        }
        Catch {
            Write-Warning ("'{0}' Provider Failed to Load: {1}" -f $f.Name, $_.ToString())
        }
    }
}

If($Script:Providers.Keys.Count -eq 0) { Write-Error "No Providers were loaded!" }
Else {
    #Load Cmdlets
    Get-ChildItem "$PSScriptRoot\Cmdlets" -File | ForEach-Object { . $_.FullName }
}

Remove-Variable f, Configfile, InitFile