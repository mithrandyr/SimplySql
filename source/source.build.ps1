param([version]$Version = "2.0.0", [switch]$DebugOnly, [switch]$SkipDedup)

if(-not [bool](Get-ChildItem alias:\).where({$_.name -eq "hv"})) {
    New-Alias -Name HV -Value (Resolve-Path ..\HandleVerbose.ps1)
}
#$Script:envList = @($env)
$Script:envList = @(
    [PSCustomObject]@{framework="net47"; env="win-x86"; output="output\bin\PS5\win-x86"}
    [PSCustomObject]@{framework="net47"; env="win-x64"; output="output\bin\PS5\win-x64"}
    [PSCustomObject]@{framework="net6.0"; env="win-x64"; output="output\bin\PS7\win-x64"}
    [PSCustomObject]@{framework="net6.0"; env="linux-x64"; output="output\bin\PS7\linux-x64"}
    [PSCustomObject]@{framework="net6.0"; env="osx-x64"; output="output\bin\PS7\osx-x64"}
)

function dedup([string]$Path) {
    Write-Host "  DeDuplicate: $Path"
    [string[]]$list = Get-ChildItem -Path $Path -Name -Directory |
        ForEach-Object { Join-Path $Path $_ }
    if($list.Count -eq 1) {
        Move-Item -Path (Join-Path $list[0] -ChildPath "*") -Destination $path
        Remove-Item $list[0]
    } elseif($list.count -gt 1) {
        $safeFiles = @{}
        $first = $list[0]
        Write-Host "  --$($first | Split-Path -Leaf)" -NoNewline
        Get-ChildItem -Path $first |
            Where-Object Name -ne "System.Data.SQLite.dll" | #always exclude this SQLite dll because of native interop binding
            Where-Object Name -ne "SQLite.Interop.dll" | #always exclude this SQLite dll because of native interop binding
            Get-FileHash |
            ForEach-Object {
                $name = $_.Path | Split-Path -Leaf
                $safeFiles[$name] = $_.Hash
                Write-Host "." -NoNewline
            }
        Write-Host "!"
        
        #run Dedup
        foreach($second in $list | Select-Object -Skip 1) {
            Write-Host "  --$($second | Split-Path -Leaf)" -NoNewline
            $retain = $safeFiles.Keys |
                Where-Object { Test-Path (Join-Path $second $_) } |
                Where-Object { $safeFiles[$_] -eq (Get-FileHash (Join-Path $second $_)).Hash }
            
            $toRemove = $safeFiles.Keys | Where-Object {$_ -notin $retain}
            $toRemove | ForEach-Object {
                $safeFiles.remove($_)
                Write-Host "." -NoNewline
            }
            Write-Host "!"        
        }

        #cleanup
        foreach($file in $safeFiles.Keys) {
            Move-Item "$first\$file" "$path"
            foreach($second in $list | Select-Object -Skip 1) {
                $f = Join-Path $second $file
                if(Test-Path $f) { Remove-Item $f }
            }
        }
        
        $list |
            Where-Object { @(Get-ChildItem $_).Count -eq 0 } |
            Remove-Item # remove empty folders
    }
}

task Clean { remove output }

task Build {
    $configuration = "Release"
    if($DebugOnly) { $configuration = "debug"}
    
    exec { dotnet publish "SimplySql.Cmdlets" -c $configuration -o "output\bin" -p:Version=$Version -p:AssemblyVersion=$version} | HV "Building SimplySql.Cmdlets ($version)" "."
    
    Move-Item "output\bin\SimplySql.Cmdlets.*" -Destination "output"
    Remove-Item "output\bin\*" #-Exclude "SimplySql.*" -Recurse

    if($DebugOnly) { $Script:envList = $Script:envList | Where-Object env -eq "win-x64" }
    foreach($env in $Script:envList) {
        #exec { dotnet publish "SimplySql.Cmdlets" -c $Configuration -r $env -o "output\bin\$env"} | HV "Building PlatformSpecific Dependencies $env" "."
        exec {
            dotnet publish "SimplySql.Engine" -c $configuration -r $env.env -f $env.framework -o $env.output
        } | HV "Building PlatformSpecific Dependencies $($env.env) ($($env.framework))" "."
 
        Get-ChildItem -Path $env.output -Directory | Remove-Item -Recurse
        #exec { dotnet publish "SimplySql.Cmdlets" -c $Configuration -r $env } | HV "Building PlatformSpecific Dependencies $env" "."
        #Remove-Item "output\bin\$env" -Include "SimplySql.*" -Recurse
    }
    
    #remove PDB/json
    Get-ChildItem -Path .\output\* -Include "*.pdb", "*.json" -Recurse | Remove-Item

    #get SQLite Interops...
    exec { dotnet build "SimplySql.Engine" -c $configuration } | HV "SQLite Interop" "."
    if (Test-Path ".\output\bin\PS5\win-x86\" -PathType Container) {
        Copy-Item ".\SimplySql.Engine\bin\$configuration\net47\x86\SQLite.Interop.dll" -Destination ".\output\bin\PS5\win-x86"
    }
    if (Test-Path ".\output\bin\PS5\win-x64\" -PathType Container) {
        Copy-Item ".\SimplySql.Engine\bin\$configuration\net47\x64\SQLite.Interop.dll" -Destination ".\output\bin\PS5\win-x64"
    }
    Get-ChildItem -Path ".\SimplySql.Engine\bin" -Directory | Remove-Item -Recurse
}

Task DeDup {
    if(-not $SkipDedup) {
        dedup ".\output\bin\PS5"
        dedup ".\output\bin\PS7"
        dedup ".\output\bin"
    }
}

task . Clean, Build, DeDup