Imports System.Data.SQLite
Imports SimplySql.Common

Public Class SQLiteProvider
    Inherits ProviderBase

    Public Sub New(connectionName As String, commandTimeout As Integer, connection As SQLiteConnection)
        MyBase.New(connectionName, Common.ProviderTypes.SQLite, connection, commandTimeout)
    End Sub
    Public Overrides Sub ChangeDatabase()
        Throw New NotImplementedException()
    End Sub

    Public Overrides Function ConnectionInfo() As SortedDictionary(Of String, Object)
        Dim sd As New SortedDictionary(Of String, Object)
        With sd
            .Add("ConnectionName", ConnectionName)
            .Add("ProviderType", ProviderType)
            .Add("ConnectionState", Connection.State)
            .Add("ConnectionString", Connection.ConnectionString)
            .Add("ServerVersion", DirectCast(Connection, SQLiteConnection).ServerVersion)
            .Add("DataSource", DirectCast(Connection, SQLiteConnection).DataSource)
            .Add("CommandTimeout", CommandTimeout)
            .Add("HasTransaction", HasTransaction)
        End With
        Return sd
    End Function

    Public Overrides Function GetDataSet(cmd As Data.IDbCommand, Optional useProviderTypes As Boolean = False) As Data.DataSet
        Dim ds As New Data.DataSet
        Dim da As New SQLiteDataAdapter(cmd)
        da.ReturnProviderSpecificTypes = useProviderTypes
        Try
            da.Fill(ds)
            Return ds
        Finally
            da.Dispose()
        End Try
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

    Public Overrides Function GetMessage() As SqlMessage
        Throw New NotImplementedException("SQLiteProvider does not support SqlMessages.")
    End Function

    Public Overrides Sub ClearMessages()
        Throw New NotImplementedException("SQLiteProvider does not support SqlMessages.")
    End Sub

    Public Shared Function Create(connectionName As String, connectionString As String, commandTimeout As Integer) As SQLiteProvider
        Dim conn As New SQLiteConnection(connectionString)
        Return New SQLiteProvider(connectionName, commandTimeout, conn)
    End Function
End Class
