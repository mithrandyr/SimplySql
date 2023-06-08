Imports System.Collections.Specialized
Imports System.Data
Imports System.Data.Common
Imports System.Data.SqlClient
Imports System.Data.SQLite
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
                        Select(Function(dr) dr("ColumnName")).
                        ToList.
                        ForEach(Function(colName) bcp.ColumnMappings.Add(colName, colName))
                Else
                    For Each de As DictionaryEntry In columnMap
                        bcp.ColumnMappings.Add(de.Key, de.Value)
                    Next
                End If

                If notify IsNot Nothing Then
                    bcp.NotifyAfter = batchSize
                    AddHandler bcp.SqlRowsCopied, Sub(sender As Object, e As SqlRowsCopiedEventArgs) notify.Invoke(e.RowsCopied)
                End If

                Dim rowcount As Long = 0
                rowcount -= GetScalar($"SELECT COUNT(1) FROM {destinationTable}", 30)
                bcp.WriteToServer(dataReader)
                rowcount += GetScalar($"SELECT COUNT(1) FROM {destinationTable}", 30)
                Return rowcount
            End Using
        End Using
    End Function

    Private Sub HandleInfoMessage(sender As Object, e As SqlInfoMessageEventArgs)
        Me.Messages.Enqueue(New SqlMessage(e.Message))
    End Sub

#Region "Shared Functions"
    Public Shared Function Create(connectionName As String, server As String, database As String, commandTimeout As Integer, Optional additionalParams As Hashtable = Nothing) As MSSQLProvider
        Dim sb As New System.Data.SqlClient.SqlConnectionStringBuilder
        sb.DataSource = server
        sb.InitialCatalog = database

        If Not dataSource.Equals(":memory:", StringComparison.OrdinalIgnoreCase) Then
            Dim filepath = New IO.FileInfo(dataSource)
            If Not filepath.Directory.Exists Then filepath.Directory.Create()
        End If

        sb.DataSource = dataSource

        If Not String.IsNullOrWhiteSpace(password) Then sb.Password = password

        'Process additional parameters through the hashtable
        sb.AddHashtable(additionalParams)

        Return Create(connectionName, sb.ToString, commandTimeout)
    End Function
    Public Shared Function Create(connectionName As String, connectionString As String, commandTimeout As Integer) As MSSQLProvider
        Dim conn As New SqlConnection(connectionString)
        Return New MSSQLProvider(connectionName, commandTimeout, conn)
    End Function
#End Region
End Class
