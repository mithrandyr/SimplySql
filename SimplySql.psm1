Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$Script:Connections = @{}
$Script:Providers = @{}

#Load up base Classes
"SqlMap","SqlMessage","ProviderConfig","ProviderBase" |
    ForEach-Object { . (Join-Path -Path "$PSScriptRoot\Classes" -ChildPath "$_.ps1") }

#Load Up Internal Functions
Get-ChildItem "$PSScriptRoot\Functions" -File | ForEach-Object { . $_.FullName }

#Load up providers
ForEach($f in Get-ChildItem "$PSScriptRoot\Providers\" -Directory) {
    $Configfile = (Join-Path $f.FullName ("{0}.ps1" -f $f.name))
    $InitFile = (Join-Path $f.FullName ("{0}Provider.ps1" -f $f.name))

    If((Test-Path $ConfigFile) -and (Test-Path $InitFile)) {
        Try {
            . $InitFile
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