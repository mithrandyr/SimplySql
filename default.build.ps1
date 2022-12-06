task Build {
  remove "source\output"
  exec {
    dotnet build source -c release -o "source\output"
  }
} 

task Clean {
  remove "source\output"
  foreach($prj in @("ConsoleTest","SimplySql.Cmdlets","SimplySql.Common","SimplySql.Engine")) {
    remove "source\$prj\bin"
    remove "source\$prj\obj"
  }
}

task CreateModule {
  remove "SimplySql"
  New-Item "SimplySql" -ItemType Directory | Out-Null
  Copy-Item "ScriptSrc\SimplySql.psd1" -Destination SimplySql

  New-Item "SimplySql\bin" -ItemType Directory | Out-Null

}

task GenerateDocs {

}

task SQLite_Interops {

}


task . Build, Clean