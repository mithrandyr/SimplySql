Public Class Test
    Public Shared Function OracleConnection() As Oracle.ManagedDataAccess.Client.OracleConnection
        Return New Oracle.ManagedDataAccess.Client.OracleConnection
    End Function

    Public Shared Function SqlConnection() As SqlClient.SqlConnection
        Return New SqlClient.SqlConnection
    End Function

    Public Shared Function PostGreConnection() As Npgsql.NpgsqlConnection
        Return New Npgsql.NpgsqlConnection
    End Function

    Public Shared Function MySqlConnection() As MySqlConnector.MySqlConnection
        Return New MySqlConnector.MySqlConnection
    End Function

    Public Shared Function SQLiteConnection() As SQLite.SQLiteConnection
        Return New SQLite.SQLiteConnection
    End Function

End Class
