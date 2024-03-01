Imports System.Collections.Specialized
Imports System.Data
Imports System.Data.Common
Imports Microsoft.Data.SqlClient

Public Class MSSQLProvider
    Inherits ProviderBase

    Public Overloads ReadOnly Property Connection As SqlConnection
        Get
            Return DirectCast(MyBase.Connection, SqlConnection)
        End Get
    End Property

    Private Sub New(connectionName As String, commandTimeout As Integer, connection As SqlConnection)
        MyBase.New(connectionName, ProviderTypes.MSSQL, connection, commandTimeout)

        AddHandler Me.Connection.InfoMessage, AddressOf HandleInfoMessage
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

    Public Overrides Sub ChangeDatabase(databaseName As String)
        Connection.ChangeDatabase(databaseName)
    End Sub

    Public Overrides Function GetDataset(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As DataSet
        If Not useProviderTypes Then
            Return MyBase.GetDataset(query, cmdTimeout, params, False)
        Else
            Using cmd As SqlCommand = GetCommand(query, cmdTimeout, params)
                Using da As New SqlDataAdapter(cmd)
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

    Public Overrides Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Long)) As Long
        If batchTimeout < 0 Then batchTimeout = CommandTimeout
        Dim bcpOption = SqlBulkCopyOptions.KeepIdentity + SqlBulkCopyOptions.CheckConstraints + SqlBulkCopyOptions.FireTriggers
        Using dataReader
            Using bcp As New SqlBulkCopy(Connection, bcpOption, Transaction) With {.BulkCopyTimeout = batchTimeout, .BatchSize = batchSize, .DestinationTableName = destinationTable, .EnableStreaming = True}
                GenerateSchemaMap(dataReader, columnMap).ForEach(Sub(x) bcp.ColumnMappings.Add(x.SourceName, x.DestinationName))

                If notify IsNot Nothing Then
                    bcp.NotifyAfter = batchSize
                    AddHandler bcp.SqlRowsCopied, Sub(sender As Object, e As SqlRowsCopiedEventArgs) notify.Invoke(e.RowsCopied)
                End If

                bcp.WriteToServer(dataReader)
                Return bcp.RowsCopied
            End Using
        End Using
    End Function

    Private Sub HandleInfoMessage(sender As Object, e As SqlInfoMessageEventArgs)
        Me.Messages.Enqueue(New SqlMessage(e.Message))
    End Sub

#Region "Shared Functions"
    Public Shared Function Create(connDetail As ConnectionMSSQL) As MSSQLProvider
        Dim connString As String
        If connDetail.HasConnectionString Then
            connString = connDetail.ConnectionString
        Else
            Dim sb As New SqlConnectionStringBuilder With {.ApplicationName = connDetail.ApplicationName, .DataSource = connDetail.Server, .InitialCatalog = connDetail.Database}
            Select Case connDetail.AuthType
                Case ConnectionMSSQL.AuthMSSQLType.Windows
                    sb.Encrypt = SqlConnectionEncryptOption.Optional
                    sb.IntegratedSecurity = True
                Case ConnectionMSSQL.AuthMSSQLType.Credential
                    sb.Encrypt = SqlConnectionEncryptOption.Optional
                Case ConnectionMSSQL.AuthMSSQLType.AzureCredential
                    sb.Authentication = SqlAuthenticationMethod.ActiveDirectoryPassword
            End Select

            'Process additional parameters through the hashtable
            sb.AddHashtable(connDetail.Additional)
            connString = sb.ToString
        End If

        Dim conn As New SqlConnection(connString)
        Select Case connDetail.AuthType
            Case ConnectionMSSQL.AuthMSSQLType.Token
                conn.AccessToken = connDetail.Token
            Case ConnectionMSSQL.AuthMSSQLType.AzureCredential, ConnectionMSSQL.AuthMSSQLType.Credential
                Dim p = connDetail.SecurePassword
                p.MakeReadOnly()
                conn.Credential = New SqlCredential(connDetail.UserName, p)
        End Select

        Return New MSSQLProvider(connDetail.ConnectionName, connDetail.CommandTimeout, conn)
    End Function
#End Region
End Class
