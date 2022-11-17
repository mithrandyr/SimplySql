Public Class Test
    Public Shared Function Greet(Optional Name As String = "World") As String
        Return $"Hello {Name}!"
    End Function

    Public Shared Function NewConnection(providerName As Providers) As Data.IDbConnection
        Select Case providerName
            Case Providers.PostGre
                'WriteObject(New Npgsql.NpgsqlConnection)
            Case Providers.MSSQL
                'WriteObject(New Data.SqlClient.SqlConnection)
            Case Providers.SQLite
                'WriteObject(New Data.SQLite.SQLiteConnection)
            Case Providers.Oracle
                'WriteObject(New Oracle.ManagedDataAccess.Client.OracleConnection)
            Case Providers.MySql
                Return New MySqlConnector.MySqlConnection
            Case Else
                Throw New ArgumentOutOfRangeException("providerName", providerName, "Not a valid ProviderType.")
        End Select
    End Function
End Class

Public Enum Providers
    PostGre
    Oracle
    MySql
    MSSQL
    SQLite
End Enum