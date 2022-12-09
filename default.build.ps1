New-Alias -Name HV -Value (Resolve-Path HandleVerbose.ps1)

task Clean { remove "output" }
task Build { Invoke-Build -File "source\source.build.ps1" } 

task ComposeModule {
  if(-not (Test-Path "output\SimplySql" -PathType Container)) {
    New-Item "Output\SimplySql" -ItemType Directory | Out-Null
  }
}, copyManifest, copyBinaries, GenerateDocs

task GenerateDocs {
  Start-Job -ScriptBlock {
        Set-Location $using:BuildRoot
        Import-Module ".\output\SimplySql"
        
        if(-not (Test-Path "docs")) {
          New-MarkdownHelp -Module SimplySql -OutputFolder Docs -AlphabeticParamsOrder -WithModulePage
          New-MarkdownAboutHelp -OutputFolder Docs -AboutName "SimplySql"
        }
        else { Update-MarkdownHelpModule -Path "Docs" -AlphabeticParamsOrder -Force -RefreshModulePage }
      } |
    Receive-Job -Wait -AutoRemoveJob |
    Select-Object -Expand Name |
    HV "Generating Module Documentation" "."
}

task copyManifest {
  #Base Module Files
  Copy-Item "ModuleManifest\SimplySql.psd1" -Destination "output\SimplySql" -Force
}
task copyBinaries {
  #Copy files for engine
  Copy-Item "source\output\*" -Destination "output\SimplySql" -Force
  Copy-Item "source\output\bin" -Destination "output\SimplySql" -Recurse -Force  
}



task . Build, ComposeModule