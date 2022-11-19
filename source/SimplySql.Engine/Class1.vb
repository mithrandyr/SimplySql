Public Class Test
    Public Shared Function Greet(Optional Name As String = "World") As String
        Return $"Hello {Name}!"
    End Function

    Public Shared Function NewConnection(providerName As Common.ProviderTypes) As Data.IDbConnection
        Select Case providerName
            Case Common.ProviderTypes.PostGre
                Return New Npgsql.NpgsqlConnection
            Case Common.ProviderTypes.MSSQL
                Return New System.Data.SqlClient.SqlConnection
            Case Common.ProviderTypes.SQLite
                Return New System.Data.SQLite.SQLiteConnection
            Case Common.ProviderTypes.Oracle
                Return New Oracle.ManagedDataAccess.Client.OracleConnection
            Case Common.ProviderTypes.MySql
                Return New MySqlConnector.MySqlConnection
            Case Else
                Throw New ArgumentOutOfRangeException("providerName", providerName, "Not a valid ProviderType.")
        End Select
    End Function
End Class