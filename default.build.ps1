param([version]$Version, [switch]$CommitRevision)
New-Alias -Name HV -Value (Resolve-Path HandleVerbose.ps1)

if(-not $version) {
  $Script:Version = [Version](Import-PowerShellDataFile -Path "ModuleManifest\SimplySql.psd1")["ModuleVersion"]
  $Script:Version = [version]::new($version.Major, $version.Minor, $version.Build, $version.Revision + 1)
}

task Clean { remove "output" }
task Build { Invoke-Build -File "source\source.build.ps1" -Version $Version}

task ComposeModule {
  if(-not (Test-Path "output\SimplySql" -PathType Container)) {
    New-Item "Output\SimplySql" -ItemType Directory | Out-Null
  }
}, copyManifest, copyBinaries, updateManifest, GenerateDocs

task GenerateDocs {
  Start-Job -ScriptBlock {
        Set-Location $using:BuildRoot
        Import-Module ".\output\SimplySql" -Verbose:$false
        
        if(-not (Test-Path "docs")) {
          New-MarkdownHelp -Module SimplySql -OutputFolder Docs -AlphabeticParamsOrder -WithModulePage
          New-MarkdownAboutHelp -OutputFolder Docs -AboutName "SimplySql"
        }
        else { Update-MarkdownHelpModule -Path "Docs" -AlphabeticParamsOrder -Force -RefreshModulePage }
      } |
    Receive-Job -Wait -AutoRemoveJob |
    ForEach-Object { "  $($_.Name)" } |
    HV "Generating Module Documentation" "."
}

task copyManifest {
  #Base Module Files  
  Copy-Item "ModuleManifest\SimplySql.psd1" -Destination "output\SimplySql" -Force
}

task copyBinaries {
  #Copy files for engine
  Copy-Item "source\output\*.dll" -Destination "output\SimplySql" -Force
  Copy-Item "source\output\bin" -Destination "output\SimplySql" -Filter "*.dll" -Recurse -Force  
}

task updateManifest {
  Import-Module PowerShellGet -Verbose:$false
  $cmdlets = Start-Job -ScriptBlock {
      Set-Location $using:BuildRoot  
      Import-Module ".\Output\SimplySql\SimplySql.Cmdlets.dll"    
      Get-Command -Module SimplySql.Cmdlets
    } |
    Receive-Job -AutoRemoveJob -wait |
    Sort-Object name |
    ForEach-Object name

  Update-ModuleManifest -Path "Output\SimplySql\SimplySql.psd1" -ModuleVersion $version -CmdletsToExport $cmdlets
  Copy-Item -Path "Output\SimplySql\SimplySql.psd1" -Destination "ModuleManifest\SimplySql.psd1"
}

task revisionCommit {
  exec { git commit "ModuleManifest/SimplySql.psd1" -m "Updating version To $version" } | HV "Incrementing Version ($version) and Git Commit"
} -If $CommitRevision


task . Build, ComposeModule, revisionCommit