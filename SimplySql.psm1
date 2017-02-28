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
    $fName = $f.Name
    $file = (Join-Path $f.FullName $fName) + ".ps1"
    If(Test-Path $file) {
        Try { 
            $Script:Providers.$fName = &$file
        }
        Catch {
            Write-Warning ("'{0}' Provider Failed to Load: {1}" -f $fName, $_.ToString())
        }
    }
}

If($Script:Providers.Keys.Count -eq 0) { Write-Warning "No Providers were loaded!" }
Else {
    #Load Cmdlets
    Get-ChildItem "$PSScriptRoot\Cmdlets" -File | ForEach-Object { . $_.FullName }
}

Remove-Variable f, fname, file