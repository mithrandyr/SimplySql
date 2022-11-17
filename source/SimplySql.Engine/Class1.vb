Public Class Test
    Public Shared Function Greet(Optional Name As String = "World") As String
        Return $"Hello {Name}!"
    End Function

    Public Shared Function NewConnection(providerName As Common.ProviderType) As Data.IDbConnection
        Select Case providerName
            Case Common.ProviderType.PostGre
                Return New Npgsql.NpgsqlConnection
            Case Common.ProviderType.MSSQL
                Return New Microsoft.Data.SqlClient.SqlConnection
            Case Common.ProviderType.SQLite
                Return New Microsoft.Data.Sqlite.SqliteConnection
            Case Common.ProviderType.Oracle
                Return New Oracle.ManagedDataAccess.Client.OracleConnection
            Case Common.ProviderType.MySql
                Return New MySqlConnector.MySqlConnection
            Case Else
                Throw New ArgumentOutOfRangeException("providerName", providerName, "Not a valid ProviderType.")
        End Select
    End Function
End Class