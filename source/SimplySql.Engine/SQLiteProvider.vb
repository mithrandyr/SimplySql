Imports System.Data.SQLite
Public Class SQLiteProvider
    Inherits ProviderBase

    Public Sub New(connectionName As String, commandTimeout As Integer, connection As SQLiteConnection)
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

    Public Shared Function Create(connectionName As String, dataSource As String, password As String, commandTimeout As Integer) As SQLiteProvider
        Dim sb As New SQLiteConnectionStringBuilder
        If Not dataSource.Equals(":memory:", StringComparison.OrdinalIgnoreCase) Then
            Dim filepath = New IO.FileInfo(dataSource)
            If Not filepath.Directory.Exists Then filepath.Directory.Create()
        End If

        sb.DataSource = dataSource

        If Not String.IsNullOrWhiteSpace(password) Then sb.Password = password

        Return Create(connectionName, sb.ToString, commandTimeout)
    End Function
    Public Shared Function Create(connectionName As String, connectionString As String, commandTimeout As Integer) As SQLiteProvider
        Dim conn As New SQLiteConnection(connectionString)
        conn.Open()
        Return New SQLiteProvider(connectionName, commandTimeout, conn)
    End Function
End Class
