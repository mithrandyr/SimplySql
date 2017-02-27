Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Script:Connections = @{}
$Script:Providers = @{}

#Load up base code
ForEach($f in Get-ChildItem "$PSScriptRoot\Code" -File) {
    . $f.FullName
}

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

#Load Cmdlets
ForEach($f in Get-ChildItem "$PSScriptRoot\Cmdlets" -File) {
    . $f.FullName
}