param([switch]$DebugOnly)
task Clean { remove output }

task Build {
    $configuration = "Release"
    if($DebugOnly) { $configuration = "debug"}
    
    exec { dotnet publish "SimplySql.Cmdlets" -c $Configuration -o "output\bin" }
    Move-Item "output\bin\SimplySql.Cmdlets.dll" -Destination "output"
    Move-Item "output\bin\EnumerableToDataReader.dll" -Destination "output"
    remove "output\bin\System.Data.SQLite.dll"

    $envList = @("win-x64")
    if(-not $DebugOnly) { $envList += @("win-x86", "linux-x64", "osx-x64")}
    foreach($env in $envList) {
        exec { dotnet publish SQLite -c $Configuration -r $env -o "output\bin\$env"}
        Remove-Item "output\bin\$env" -Exclude "SQLite.Interop.dll", "System.Data.SQLite.dll" -Recurse
    }
}

task . Clean, Build