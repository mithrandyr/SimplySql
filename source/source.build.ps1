param([version]$Version = "2.0.0", [switch]$DebugOnly, [switch]$SkipDedup, [validateset("win-x64","linux-x64")][string]$env="win-x64")

if(-not [bool](Get-ChildItem alias:\).where({$_.name -eq "hv"})) {
    New-Alias -Name HV -Value (Resolve-Path ..\HandleVerbose.ps1)
}
$Script:envList = @($env)

task Clean { remove output }

task Build {
    $configuration = "Release"
    if($DebugOnly) { $configuration = "debug"}
    
    exec { dotnet publish "SimplySql.Cmdlets" -c $Configuration -o "output\bin" -p:Version=$Version -p:AssemblyVersion=$version} | HV "Building SimplySql.Cmdlets ($version)" "."
    
    Move-Item "output\bin\SimplySql.Cmdlets.*" -Destination "output"
    Remove-Item "output\bin\" -Exclude "SimplySql.*" -Recurse

    if(-not $DebugOnly) { $Script:envList += @("win-x86", "linux-x64", "osx-x64")}
    foreach($env in $Script:envList) {
        exec { dotnet publish "SimplySql.Cmdlets" -c $Configuration -r $env -o "output\bin\$env"} | HV "Building PlatformSpecific Dependencies $env" "."
        Remove-Item "output\bin\$env" -Include "SimplySql.*" -Recurse
    }
}

Task DeDup {
    if(-not $DebugOnly -and -not $SkipDedup) {
        $first = $Script:envList[0]
        $safeFiles = @{}
        Get-ChildItem -Path "output\bin\$first" |
            Where-Object Name -ne "System.Data.SQLite.dll" | #always exclude this SQLite dll because of native interop binding
            Get-FileHash |
            ForEach-Object {
                $name = $_.Path | Split-Path -Leaf
                $safeFiles[$name] = $_.Hash
            }
        
        Write-Host "  ." -NoNewline

        foreach($second in $Script:envList | Select-Object -Skip 1) {
            $retain = $safeFiles.Keys | 
                Where-Object { Test-Path "output\bin\$second\$_" } |
                Where-Object { $safeFiles[$_] -eq (Get-FileHash "output\bin\$second\$_").Hash }
            
            $toRemove = $safeFiles.Keys | Where-Object {$_ -notin $retain}
            $toRemove | ForEach-Object { $safeFiles.remove($_) }
                
            Write-Host "." -NoNewline
        }

        foreach($file in $safeFiles.Keys) {
            Move-Item "output\bin\$first\$file" "output\bin"
            foreach($second in $Script:envList | Select-Object -Skip 1) {
                Remove-Item "output\bin\$second\$file"
            }
        }
        Write-Host
    }
}

task . Clean, Build, DeDup