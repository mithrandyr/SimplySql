Public Class SQLiteProvider
    Inherits ProviderBase

    Public Sub New(connectionName As String, commandTimeout As Integer, connection As Microsoft.Data.Sqlite.SqliteConnection)
        MyBase.New(connectionName, Common.ProviderTypes.SQLite)
    End Sub
    Public Overrides Sub ChangeDatabase()
        Throw New NotImplementedException()
    End Sub

    Public Overrides Function ConnectionInfo() As SortedDictionary(Of String, Object)
        Throw New NotImplementedException()
    End Function

    Public Overrides Function GetDataSet() As Data.DataSet
        Throw New NotImplementedException()
    End Function

    Public Overrides Function CreateConnection(ht As Hashtable) As Data.IDbConnection
        Throw New NotImplementedException()
    End Function

    Public Shared Function Create() As SQLiteProvider
        Return Nothing
    End Function
End Class
