Imports System.Management.Automation

<Cmdlet("Test", "SimplySql")>
<OutputType(GetType(Data.IDbConnection))>
Public Class Test
    Inherits PSCmdlet
    <Parameter(Mandatory:=True, Position:=1)>
    Public Property ProviderType As Providers

    Protected Overrides Sub ProcessRecord()
        Select Case ProviderType
            Case Providers.PostGre
                WriteObject(New Npgsql.NpgsqlConnection)
            Case Else
                WriteError(New ErrorRecord(New ArgumentException(String.Format("Does not support {0}", ProviderType), "ProviderType"), "", ErrorCategory.InvalidArgument, Nothing))
        End Select
    End Sub
End Class

Public Enum Providers
    PostGre
    Oracle
    MySql
    MSSQL
    SQLite
End Enum
