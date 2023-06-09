﻿Imports System.Collections.Specialized
Imports System.Data
Imports System.Data.Common
Imports Microsoft.Data.SqlClient
Imports System.Runtime.CompilerServices

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
        Me.Connection.ChangeDatabase(databaseName)
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
    Public Shared Function Create(connectionName As String, server As String, database As String, commandTimeout As Integer, auth As AuthMSSQL, Optional additionalParams As Hashtable = Nothing) As MSSQLProvider
        Dim sb As New SqlConnectionStringBuilder
        sb.DataSource = server
        sb.InitialCatalog = database

        Select Case auth.AuthType
            Case AuthMSSQL.AuthMSSQLType.Windows
                sb.IntegratedSecurity = True
            Case AuthMSSQL.AuthMSSQLType.Azure
                sb.Authentication = SqlAuthenticationMethod.ActiveDirectoryPassword

        End Select
        'Process additional parameters through the hashtable
        sb.AddHashtable(additionalParams)

        Return Create(connectionName, sb.ToString, commandTimeout, auth.AzureToken)
    End Function
    Public Shared Function Create(connectionName As String, connectionString As String, commandTimeout As Integer, Optional azToken As String = Nothing) As MSSQLProvider
        Dim conn As New SqlConnection(connectionString)
        If Not String.IsNullOrWhiteSpace(azToken) Then conn.AccessToken = azToken
        Return New MSSQLProvider(connectionName, commandTimeout, conn)
    End Function
#End Region
End Class
