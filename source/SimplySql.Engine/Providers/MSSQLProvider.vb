Imports System.Collections.Specialized
Imports System.Data
Imports System.Data.Common
Imports Microsoft.Data.SqlClient
Imports System.Runtime.CompilerServices
Imports System.Data.SQLite

Public Class MSSQLProvider
    Inherits ProviderBase

    Public Sub New(connectionName As String, commandTimeout As Integer, connection As SqlConnection)
        MyBase.New(connectionName, ProviderTypes.MSSQL, connection, commandTimeout)

        AddHandler Me.Connection.InfoMessage, AddressOf HandleInfoMessage
    End Sub

    Public Overloads ReadOnly Property Connection As SqlConnection
        Get
            Return DirectCast(MyBase.Connection, SqlConnection)
        End Get
    End Property

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
                        ex.Data.Add("Query", query)
                        ex.Data.Add("Parameters", params)
                        Throw ex
                    End Try
                End Using
            End Using
        End If
    End Function

    Public Overrides Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Long)) As Long
        Dim bcpOption = SqlBulkCopyOptions.KeepIdentity + SqlBulkCopyOptions.CheckConstraints + SqlBulkCopyOptions.FireTriggers
        Using dataReader
            Using bcp As New SqlBulkCopy(Connection, bcpOption, Transaction)
                With bcp
                    .EnableStreaming = True
                    .BulkCopyTimeout = batchTimeout
                    .BatchSize = batchSize
                    .DestinationTableName = destinationTable
                End With

                If columnMap Is Nothing OrElse columnMap.Count = 0 Then
                    dataReader.
                        GetSchemaTable().
                        AsEnumerable.
                        Select(Function(dr) dr("ColumnName").ToString).
                        ToList.
                        ForEach(Function(colName) bcp.ColumnMappings.Add(colName, colName))
                Else
                    For Each key As String In columnMap.Keys
                        bcp.ColumnMappings.Add(key, columnMap.Item(key).ToString)
                    Next
                End If

                If notify IsNot Nothing Then
                    bcp.NotifyAfter = batchSize
                    AddHandler bcp.SqlRowsCopied, Sub(sender As Object, e As SqlRowsCopiedEventArgs) notify.Invoke(e.RowsCopied)
                End If

                Dim rowcount As Long = 0
                rowcount -= DirectCast(GetScalar($"SELECT COUNT(1) FROM {destinationTable}", 30), Long)
                bcp.WriteToServer(dataReader)
                rowcount += DirectCast(GetScalar($"SELECT COUNT(1) FROM {destinationTable}", 30), Long)
                Return rowcount
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
                conn.Credential = New SqlCredential(connDetail.UserName, connDetail.SecurePassword)
        End Select

        Return New MSSQLProvider(connDetail.ConnectionName, connDetail.CommandTimeout, conn)
    End Function
#End Region
End Class
