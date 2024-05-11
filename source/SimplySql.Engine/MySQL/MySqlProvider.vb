Imports System.Collections.Specialized
Imports System.Data
Imports MySqlConnector

Public Class MySqlProvider
    Inherits ProviderBase
    Public Overloads ReadOnly Property Connection As MySqlConnection
        Get
            Return DirectCast(MyBase.Connection, MySqlConnection)
        End Get
    End Property

    Private Sub New(connectionName As String, commandTimeout As Integer, connection As MySqlConnection)
        MyBase.New(connectionName, ProviderTypes.MySql, connection, commandTimeout)

        AddHandler connection.InfoMessage, AddressOf HandleInfoMessage
    End Sub

    Public Overrides Function ConnectionInfo() As OrderedDictionary
        Dim od = MyBase.ConnectionInfo
        With od
            .Add("ServerVersion", Connection.ServerVersion)
            .Add("Server", Connection.DataSource)
            .Add("Database", Connection.Database)
        End With
        Return od
    End Function

    Public Overrides Function GetDataSet(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As Data.DataSet
        If Not useProviderTypes Then
            Return MyBase.GetDataset(query, cmdTimeout, params, False)
        Else
            Using cmd As MySqlCommand = GetCommand(query, cmdTimeout, params)
                Using da As New MySqlDataAdapter(cmd)
                    Dim ds As New Data.DataSet
                    da.ReturnProviderSpecificTypes = True
                    Try
                        da.Fill(ds)
                        Return ds
                    Catch ex As Exception
                        ex.AddQueryDetails(query, params)
                        Throw
                    End Try
                End Using
            End Using
        End If
    End Function

    Public Overrides Sub ChangeDatabase(databaseName As String)
        Connection.ChangeDatabase(databaseName)
    End Sub

    Public Overrides Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Long)) As Long
        If batchTimeout < 0 Then batchTimeout = CommandTimeout
        Using dataReader
            Dim bcp As New MySqlBulkCopy(Connection, Transaction) With {.BulkCopyTimeout = batchTimeout, .DestinationTableName = destinationTable}
            GenerateSchemaMap(dataReader, columnMap).ForEach(Sub(x) bcp.ColumnMappings.Add(New MySqlBulkCopyColumnMapping(x.Ordinal, x.DestinationName)))

            If notify IsNot Nothing Then
                bcp.NotifyAfter = batchSize
                AddHandler bcp.MySqlRowsCopied, Sub(sender As Object, e As MySqlRowsCopiedEventArgs) notify.Invoke(e.RowsCopied)
            End If

            Dim result = bcp.WriteToServer(dataReader)
            result.Warnings.ToList.ForEach(Sub(w) Messages.Enqueue(New SqlMessage(w.Message)))
            Return result.RowsInserted
        End Using
    End Function

    Private Sub HandleInfoMessage(sender As Object, e As MySqlInfoMessageEventArgs)
        For Each m In e.Errors
            Messages.Enqueue(New SqlMessage(m.Message))
        Next
    End Sub

#Region "Shared Functions"
    Public Shared Function Create(connDetail As ConnectionMySql) As MySqlProvider
        Dim sb As MySqlConnectionStringBuilder
        If connDetail.HasConnectionString Then
            sb = New MySqlConnectionStringBuilder(connDetail.ConnectionString)
        Else
            sb = New MySqlConnectionStringBuilder With {
                    .ApplicationName = connDetail.ApplicationName,
                    .Server = connDetail.Server,
                    .Port = connDetail.Port,
                    .Database = connDetail.Database,
                    .SslMode = MapSslMode(connDetail.SslMode),
                    .AllowLoadLocalInfile = True,
                    .UseAffectedRows = True,
                    .AllowUserVariables = True
                }

            'Process additional parameters through the hashtable
            sb.AddHashtable(connDetail.Additional)
        End If

        If connDetail.Credential IsNot Nothing Then
            sb.UserID = connDetail.UserName
            sb.Password = connDetail.Password
        End If

        Return New MySqlProvider(connDetail.ConnectionName, connDetail.CommandTimeout, New MySqlConnection(sb.ToString))
    End Function
    Private Shared Function MapSslMode(ssl As String) As MySqlSslMode
        Return [Enum].Parse(GetType(MySqlSslMode), ssl)
    End Function
#End Region
End Class
