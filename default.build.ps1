task Build {
  remove "source\output"
  exec {
    dotnet build source -c release -o "source\output"
  }
} 

task Clean {
  #remove "source\output"
  foreach($prj in @("SimplySql.Cmdlets","SimplySql.Common","SimplySql.Engine")) {
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

}


task . Build, CreateModule, Clean, GenerateDocs, SQLite_Interops