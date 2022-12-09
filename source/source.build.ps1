param([switch]$DebugOnly)

if(-not [bool](Get-ChildItem alias:\).where({$_.name -eq "hv"})) {
    New-Alias -Name HV -Value (Resolve-Path ..\HandleVerbose.ps1)
}

task Clean { remove output }

task Build {
    $configuration = "Release"
    if($DebugOnly) { $configuration = "debug"}
    
    exec { dotnet publish "SimplySql.Cmdlets" -c $Configuration -o "output\bin" } | HV "Building SimplySql.Cmdlets" "."
    
    Move-Item "output\bin\SimplySql.Cmdlets.dll" -Destination "output"
    Move-Item "output\bin\EnumerableToDataReader.dll" -Destination "output"
    remove "output\bin\System.Data.SQLite.dll"

    $envList = @("win-x64")
    if(-not $DebugOnly) { $envList += @("win-x86", "linux-x64", "osx-x64")}
    foreach($env in $envList) {
        exec { dotnet publish SQLite -c $Configuration -r $env -o "output\bin\$env"} | HV "Building SQLite (Interop) for $env" "."
        Remove-Item "output\bin\$env" -Exclude "SQLite.Interop.dll", "System.Data.SQLite.dll" -Recurse
    }
}

task . Clean, Build