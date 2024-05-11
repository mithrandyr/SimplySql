Imports System.Collections.Specialized
Imports System.Data
Imports System.Data.Common
Imports System.Threading

Public MustInherit Class ProviderBase
    Implements ISimplySqlProvider
    Public ReadOnly Property ConnectionName As String Implements ISimplySqlProvider.ConnectionName

    Private _providerType As Engine.ProviderTypes
    Public ReadOnly Property ProviderType As String Implements ISimplySqlProvider.ProviderName
        Get
            Return _providerType.ToString()
        End Get
    End Property

    Public ReadOnly Property Connection As IDbConnection Implements ISimplySqlProvider.Connection
    Public Property CommandTimeout As Integer = 30 Implements ISimplySqlProvider.CommandTimeout
    Public Sub New(connName As String, providerType As Engine.ProviderTypes, conn As IDbConnection, timeout As Integer)
        ConnectionName = connName
        _providerType = providerType
        Connection = conn
        CommandTimeout = timeout
        'conn.Open()
    End Sub

#Region "Overrides"
    Public Overridable Function ConnectionInfo() As OrderedDictionary Implements ISimplySqlProvider.ConnectionInfo
        Dim od As New OrderedDictionary
        With od
            .Add("ConnectionName", ConnectionName)
            .Add("ProviderType", ProviderType)
            .Add("ConnectionState", Connection.State)
            .Add("ConnectionString", Connection.ConnectionString)
            .Add("CommandTimeout", CommandTimeout)
            .Add("HasTransaction", HasTransaction)
        End With
        Return od
    End Function
    Public MustOverride Sub ChangeDatabase(databaseName As String) Implements ISimplySqlProvider.ChangeDatabase

    Public Overridable Function HandleParamValue(x As Object) As Object
        If TypeOf x Is System.Management.Automation.PSObject Then x = DirectCast(x, System.Management.Automation.PSObject).BaseObject
        Return If(x, DBNull.Value)
    End Function
#End Region

#Region "Concrete"
    Public Sub AttachCommand(cmd As IDbCommand)
        cmd.Connection = Me.Connection
        If Me.HasTransaction Then cmd.Transaction = Me.Transaction
    End Sub

#Region "GetCommand"
    Public Overridable Function GetCommand(query As String, timeout As Integer, params As Hashtable) As IDbCommand Implements ISimplySqlProvider.GetCommand
        Dim cmd As IDbCommand = Me.Connection.CreateCommand()
        cmd.CommandText = query
        cmd.CommandTimeout = If(timeout < 0, Me.CommandTimeout, timeout)
        If Me.HasTransaction Then cmd.Transaction = Me.Transaction

        If params IsNot Nothing Then
            For Each de As DictionaryEntry In params
                Dim param As IDbDataParameter = cmd.CreateParameter()
                param.ParameterName = de.Key
                param.Value = HandleParamValue(de.Value)
                cmd.Parameters.Add(param)
            Next
        End If

        Return cmd
    End Function
    Public Function GetCommand(query As String, Optional params As Hashtable = Nothing) As IDbCommand
        Return Me.GetCommand(query, Me.CommandTimeout, params)
    End Function
#End Region

#Region "GetScalar"
    Public Overridable Function GetScalar(query As String, timeout As Integer, params As Hashtable) As Object Implements ISimplySqlProvider.GetScalar
        Using cmd As IDbCommand = GetCommand(query, timeout, params)
            Try
                Return cmd.ExecuteScalar()
            Catch ex As Exception
                ex.AddQueryDetails(query, params)
                Throw
            End Try
        End Using
    End Function
    Public Function GetScalar(query As String, timeout As Integer) As Object
        Return Me.GetScalar(query, timeout, Nothing)
    End Function
#End Region

#Region "GetDataSet"
    Public Overridable Function GetDataset(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As DataSet Implements ISimplySqlProvider.GetDataSet
        If useProviderTypes Then Throw New NotSupportedException($"{ProviderType} does not support -UseTypesFromProvider.")
        Using cmd As IDbCommand = GetCommand(query, cmdTimeout, params)
            Try
                Dim ds As New DataSet
                Using dr As IDataReader = cmd.ExecuteReader
                    Do
                        Dim dt As New DataTable
                        dt.Load(dr)
                        If dt.Rows.Count > 0 Then ds.Tables.Add(dt)
                    Loop While Not dr.IsClosed AndAlso dr.NextResult()
                End Using
                Return ds
            Catch ex As Exception
                ex.AddQueryDetails(query, params)
                Throw
            End Try
        End Using
    End Function
#End Region

#Region "GetReader"
    Public Overridable Function GetReader(query As String, params As Hashtable, Optional timeout As Integer = -1) As IDataReader Implements ISimplySqlProvider.GetDataReader
        Using cmd As IDbCommand = Me.GetCommand(query, timeout, params)
            Try
                Return cmd.ExecuteReader()
            Catch ex As Exception
                ex.AddQueryDetails(query, params)
                Throw
            End Try
        End Using
    End Function
#End Region

#Region "Update"
    Public Overridable Function Update(cmd As IDbCommand) As Int64 Implements ISimplySqlProvider.Update
        If cmd.Transaction Is Nothing AndAlso HasTransaction Then cmd.Transaction = Transaction
        Try
            Return cmd.ExecuteNonQuery()
        Catch ex As Exception
            ex.AddQueryDetails(cmd.CommandText, cmd.Parameters)
            Throw
        End Try
    End Function
    Public Overridable Function Update(query As String, timeout As Integer, params As Hashtable) As Int64 Implements ISimplySqlProvider.Update
        Using cmd As IDbCommand = Me.GetCommand(query, timeout, params)
            Return Update(cmd)
        End Using
    End Function
#End Region

#Region "BulkLoad"
    Public Overridable Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Int64)) As Int64 Implements ISimplySqlProvider.BulkLoad
        If batchTimeout < 0 Then batchTimeout = CommandTimeout
        Dim batchIteration As Int64 = 0
        Dim ord As Integer = 0
        Dim hasPrepared As Boolean = False
        Dim schemaMap As New List(Of SchemaMapItem)
        For Each dr In dataReader.GetSchemaTable().Rows.Cast(Of DataRow).OrderBy(Function(x) x("ColumnOrdinal"))
            schemaMap.Add(New SchemaMapItem With {.Ordinal = ord, .SourceName = dr("ColumnName"), .DestinationName = dr("ColumnName")})
            ord += 1
        Next

        If columnMap IsNot Nothing AndAlso columnMap.Count > 0 Then
            Dim columnMapDictionary As Dictionary(Of String, String) = columnMap.Cast(Of DictionaryEntry).ToDictionary(Function(x) x.Key.ToString, Function(x) x.Value.ToString)
            schemaMap = schemaMap.Where(Function(x) columnMapDictionary.ContainsKey(x.SourceName)).Select(Function(x) New SchemaMapItem With {.Ordinal = x.Ordinal, .SourceName = x.SourceName, .DestinationName = columnMapDictionary(x.SourceName)})
        End If

        Dim insertSql As String = String.Format("INSERT INTO {0} ([{1}]) VALUES (@Param{2})", destinationTable,
                                                String.Join("], [", schemaMap.Select(Function(x) x.DestinationName)),
                                                String.Join(", @Param", schemaMap.Select(Function(x) x.Ordinal))
                                                )
        Dim sw = Stopwatch.StartNew()
        Using bulkCmd = Me.GetCommand(insertSql)
            Using dataReader
                bulkCmd.Transaction = Me.Connection.BeginTransaction
                Try
                    While dataReader.Read()
                        If Not hasPrepared Then
                            schemaMap.ForEach(Sub(x)
                                                  Dim param = bulkCmd.CreateParameter()
                                                  param.ParameterName = String.Format("Param{0}", x.Ordinal)
                                                  param.Value = dataReader.GetValue(x.Ordinal)
                                                  bulkCmd.Parameters.Add(param)
                                              End Sub)
                            bulkCmd.Prepare()
                            hasPrepared = True
                        Else
                            schemaMap.ForEach(Sub(x) DirectCast(bulkCmd.Parameters(x.Ordinal), IDataParameter).Value = dataReader.GetValue(x.Ordinal))
                        End If
                        batchIteration += 1
                        bulkCmd.ExecuteNonQuery()

                        If sw.Elapsed.TotalSeconds > batchTimeout Then
                            Dim ex As New TimeoutException(String.Format("Batch took longer than {0} seconds to complete.", batchTimeout))
                            ex.AddQueryDetails(insertSql, bulkCmd.Parameters)
                            Throw ex
                        End If

                        If batchIteration Mod batchSize = 0 Then
                            bulkCmd.Transaction.Commit()
                            bulkCmd.Transaction.Dispose()
                            If notify IsNot Nothing Then notify.Invoke(batchIteration)
                            bulkCmd.Transaction = Me.Connection.BeginTransaction()
                            sw.Restart()
                        End If
                    End While

                    bulkCmd.Transaction.Commit()
                Catch ex As Exception
                    ex.AddQueryDetails(insertSql, bulkCmd.Parameters)
                    Throw
                Finally
                    If bulkCmd.Transaction IsNot Nothing Then bulkCmd.Transaction.Dispose()
                End Try
            End Using
        End Using
        Return batchIteration
    End Function

    Friend Shared Function GenerateSchemaMap(dr As IDataReader, columnMap As Hashtable) As List(Of SchemaMapItem)
        Dim schemaMap As New List(Of SchemaMapItem)
        Dim ord As Integer = 0
        For Each row In dr.GetSchemaTable().Select().OrderBy(Function(x) x("ColumnOrdinal"))
            Dim smi = New SchemaMapItem With {.Ordinal = ord}
            smi.SourceName = row("ColumnName")
            smi.DestinationName = row("ColumnName")
            smi.DataType = row("DataType").ToString

            'schemaMap.Add(New SchemaMapItem With {.Ordinal = ord, .SourceName = row("ColumnName"), .DestinationName = row("ColumnName"), .DataType = row("DataType")})
            schemaMap.Add(smi)
            ord += 1
        Next

        If columnMap IsNot Nothing AndAlso columnMap.Count > 0 Then
            Dim columnMapDictionary As Dictionary(Of String, String) = columnMap.Cast(Of DictionaryEntry).ToDictionary(Function(x) x.Key.ToString, Function(x) x.Value.ToString)
            schemaMap = schemaMap.Where(Function(x) columnMapDictionary.ContainsKey(x.SourceName)).Select(Function(x) New SchemaMapItem With {.Ordinal = x.Ordinal, .SourceName = x.SourceName, .DestinationName = columnMapDictionary(x.SourceName)})
        End If
        Return schemaMap
    End Function
#End Region

#Region "Messages"
    Public ReadOnly Property Messages As New Queue(Of SqlMessage) Implements ISimplySqlProvider.Messages
    Public Overridable Function GetMessage() As SqlMessage Implements ISimplySqlProvider.GetMessage
        Return Me.Messages.Dequeue()
    End Function

    Public Overridable Sub ClearMessages() Implements ISimplySqlProvider.ClearMessages
        Me.Messages.Clear()
    End Sub

    Public Overridable ReadOnly Property HasMessages() As Boolean Implements ISimplySqlProvider.HasMessages
        Get
            Return Me.Messages.Count > 0
        End Get
    End Property
#End Region

#Region "Transactions"
    Public Property Transaction As IDbTransaction Implements ISimplySqlProvider.Transaction
    Public ReadOnly Property HasTransaction As Boolean Implements ISimplySqlProvider.HasTransaction
        Get
            Return Me.Transaction IsNot Nothing
        End Get
    End Property
    Sub BeginTransaction() Implements ISimplySqlProvider.BeginTransaction
        If Me.HasTransaction Then Throw New InvalidOperationException("Cannot BEGIN a transaction when one is already in progress.")
        Me.Transaction = Me.Connection.BeginTransaction()
    End Sub
    Sub RollbackTransaction() Implements ISimplySqlProvider.RollbackTransaction
        If Me.HasTransaction Then
            Try
                Me.Transaction.Rollback()
            Finally
                Me.Transaction.Dispose()
                Me.Transaction = Nothing
            End Try
        Else
            Throw New InvalidOperationException("Cannot ROLLBACK when there is no transaction in progress.")
        End If
    End Sub

    Sub CommitTransaction() Implements ISimplySqlProvider.CommitTransaction
        If Me.HasTransaction Then
            Try
                Me.Transaction.Commit()
            Finally
                Me.Transaction.Dispose()
                Me.Transaction = Nothing
            End Try
        Else
            Throw New InvalidOperationException("Cannot COMMIT when there is no transaction in progress.")
        End If
    End Sub
#End Region
#End Region

    Friend Structure SchemaMapItem
        Public Ordinal As Integer
        Public SourceName As String
        Public DestinationName As String
        Public DataType As String
    End Structure
End Class

Public Enum ProviderTypes
    PostGre
    Oracle
    MySql
    MSSQL
    SQLite
End Enum