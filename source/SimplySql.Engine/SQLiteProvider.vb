Imports System.Data.SQLite
Imports NetTopologySuite.Operation.Buffer.Validate
Imports SimplySql.Common

Public Class SQLiteProvider
    Inherits ProviderBase

    Public Sub New(connectionName As String, commandTimeout As Integer, connection As SQLiteConnection)
        MyBase.New(connectionName, Common.ProviderTypes.SQLite, connection, commandTimeout)
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

    Public Overrides Function GetDataSet(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As Data.DataSet
        If Not useProviderTypes Then
            Return MyBase.GetDataset(query, cmdTimeout, params, False)
        Else
            Using cmd As SQLiteCommand = GetCommand(query, cmdTimeout, params)
                Using da As New SQLiteDataAdapter(cmd)
                    Dim ds As New Data.DataSet
                    da.ReturnProviderSpecificTypes = True
                    Try
                        da.Fill(ds)
                        Return ds
                    Catch ex As Exception
                        ex.Data.Add("Query", query)
                        ex.Data.Add("Parameters", params)
                        Throw ex
                    End Try
                End Using
            End Using
        End If
    End Function

#Region "Not Supported"
    Public Overrides Sub ChangeDatabase(databaseName As String)
        Throw New NotSupportedException($"SQLite does not support databases, cannot change to {databaseName}.")
    End Sub
    Public Overrides Function CreateConnection(ht As Hashtable) As Data.IDbConnection
        Throw New NotImplementedException()
    End Function

    Public Overrides Function GetMessage() As SqlMessage
        Throw New NotSupportedException("SQLiteProvider does not support SqlMessages.")
    End Function

    Public Overrides Sub ClearMessages()
        Throw New NotSupportedException("SQLiteProvider does not support SqlMessages.")
    End Sub
    Public Overrides ReadOnly Property HasMessages As Boolean
        Get
            Throw New NotSupportedException("SQLiteProvider does not support SqlMessages.")
        End Get
    End Property
#End Region

#Region "Shared Functions"
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
        Return New SQLiteProvider(connectionName, commandTimeout, conn)
    End Function
#End Region
End Class
