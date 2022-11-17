Imports System.Management.Automation

<Cmdlet("Test", "SimplySql")>
<OutputType(GetType(Data.IDbConnection))>
Public Class Test
    Inherits PSCmdlet
    <Parameter(Mandatory:=True, Position:=0)>
    Public Property ProviderType As Providers

    Protected Overrides Sub ProcessRecord()
        Select Case ProviderType
            Case Providers.PostGre
                WriteObject(New Npgsql.NpgsqlConnection)
            Case Providers.MSSQL
                WriteObject(New Data.SqlClient.SqlConnection)
            Case Providers.SQLite
                WriteObject(New Data.SQLite.SQLiteConnection)
            Case Providers.Oracle
                WriteObject(New Oracle.ManagedDataAccess.Client.OracleConnection)
            Case Providers.MySql
                WriteObject(New MySqlConnector.MySqlConnection)
            Case Else
                WriteError(New ErrorRecord(New ArgumentException(String.Format("Does not support {0}", ProviderType), "ProviderType"), "", ErrorCategory.InvalidArgument, Nothing))
        End Select
    End Sub
End Class

<Cmdlet("Test", "SimplySql2")>
Public Class test2
    Inherits PSCmdlet
    Protected Overrides Sub EndProcessing()
        WriteInformation(New InformationRecord(String.Format("Type: {0}", System.Runtime.InteropServices.RuntimeInformation.FrameworkDescription), ".NET"))
        Console.WriteLine(IO.Path.GetDirectoryName(Reflection.Assembly.GetExecutingAssembly().Location))
    End Sub

End Class
Public Enum Providers
    PostGre
    Oracle
    MySql
    MSSQL
    SQLite
End Enum
