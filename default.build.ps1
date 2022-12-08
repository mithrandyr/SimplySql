task Build {
  remove "source\output"
  exec {
    dotnet publish source -c release -o "source\output"
  }
} 

task Clean {
  remove "source\output"
  foreach($prj in @("SimplySql.Cmdlets","SimplySql.Common","SimplySql.Engine","SQLite")) {
    remove "source\$prj\bin" -verbose
    remove "source\$prj\obj" -verbose
  }
}

task CreateModule {
  remove "Output\SimplySql"
  New-Item "Output\SimplySql" -ItemType Directory | Out-Null
  #Base Module Files
  $baseFiles = @(
    "SimplySql\SimplySql.psd1"
    "Source\Output\SimplySql.Cmdlets.dll"
    "Source\Output\EnumerableToDataReader.dll"
  ) | Copy-Item -Destination "Output\SimplySql" -PassThru

  #Copy files for engine
  New-Item "Output\SimplySql\bin" -ItemType Directory | Out-Null
  Get-ChildItem "Source\Output\*.dll" -Exclude $baseFiles.Name |
    Copy-Item -Destination "Output\SimplySql\bin"
}

task GenerateDocs {

}

task SQLite_Interops {
  $envList = "win-x64","win-x86","linux-x64","osx-x64"

  foreach($env in $envlist) {
    remove "source\output"
    exec {
      dotnet publish source\SQLite -c release -o "source\output" -r $env
    }
    
    $dest = "output\SimplySql\bin\$env"
    remove $dest
    New-Item $dest -ItemType Directory | Out-Null
    Get-ChildItem "source\output\*.dll" -exclude "SQLite.dll" |
      Copy-Item -Destination $dest    
  }
  remove "output\SimplySql\bin\System.Data.SQLite.dll"
}


task . Build, CreateModule, SQLite_Interops, Clean, GenerateDocs
task Debugging Build