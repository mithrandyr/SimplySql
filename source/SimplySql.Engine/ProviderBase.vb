Imports System.Data
Imports SimplySql.Common
Public MustInherit Class ProviderBase
    Implements ISimplySqlProvider
    Public ReadOnly Property ConnectionName As String Implements ISimplySqlProvider.ConnectionName

    Private _providerType As Common.ProviderTypes
    Public ReadOnly Property ProviderType As String Implements ISimplySqlProvider.ProviderName
        Get
            Return _providerType.ToString()
        End Get
    End Property

    Public ReadOnly Property Connection As IDbConnection Implements ISimplySqlProvider.Connection
    Public Property CommandTimeout As Integer = 30 Implements ISimplySqlProvider.CommandTimeout
    Public Sub New(connName As String, providerType As Common.ProviderTypes, conn As IDbConnection, timeout As Integer)
        ConnectionName = connName
        _providerType = providerType
        Connection = conn
        CommandTimeout = timeout
    End Sub

#Region "Overrides"
    Public MustOverride Function ConnectionInfo() As SortedDictionary(Of String, Object) Implements ISimplySqlProvider.ConnectionInfo
    Public MustOverride Sub ChangeDatabase() Implements ISimplySqlProvider.ChangeDatabase
    Public MustOverride Function GetDataSet(cmd As Data.IDbCommand, Optional useProviderTypes As Boolean = False) As DataSet

    Public MustOverride Function CreateConnection(ht As Hashtable) As IDbConnection
#End Region

#Region "Concrete"
    Public Sub AttachCommand(cmd As IDbCommand)
        cmd.Connection = Me.Connection
        If Me.HasTransaction Then cmd.Transaction = Me.Transaction
    End Sub
#Region "GetCommand"
    Public Overridable Function GetCommand(query As String, timeout As Integer, params As Hashtable) As IDbCommand
        Dim cmd As IDbCommand = Me.Connection.CreateCommand()
        cmd.CommandText = query
        cmd.CommandTimeout = timeout
        If Me.HasTransaction Then cmd.Transaction = Me.Transaction

        If params IsNot Nothing Then
            For Each de As DictionaryEntry In params
                Dim param As IDbDataParameter = cmd.CreateParameter()
                param.ParameterName = de.Key
                param.Value = If(de.Value, DBNull.Value)
                cmd.Parameters.Add(param)
            Next
        End If

        Return cmd
    End Function
    Public Function GetCommand(query As String, Optional params As Hashtable = Nothing) As IDbCommand
        Return Me.GetCommand(query, Me.CommandTimeout, params)
    End Function
    Public Function GetCommand(query As String, timeout As Integer) As IDbCommand
        Return Me.GetCommand(query, timeout, Nothing)
    End Function
#End Region

#Region "GetScalar"
    Public Overridable Function GetScalar(query As String, timeout As Integer, params As Hashtable) As Object Implements ISimplySqlProvider.GetScalar
        Using cmd As IDbCommand = GetCommand(query, timeout, params)
            Try
                Return cmd.ExecuteScalar()
            Catch ex As Exception
                ex.Data.Add("Query", query)
                ex.Data.Add("Parameters", params)
                Throw ex
            End Try
        End Using
    End Function
    Public Function GetScalar(query As String, Optional params As Hashtable = Nothing) As Object
        Return Me.GetScalar(query, Me.CommandTimeout, params)
    End Function
    Public Function GetScalar(query As String, timeout As Integer) As Object
        Return Me.GetScalar(query, timeout, Nothing)
    End Function
#End Region

#Region "GetReader"
    Public Overridable Function GetReader(query As String, timeout As Integer, params As Hashtable) As IDataReader
        Using cmd As IDbCommand = Me.GetCommand(query, timeout, params)
            Try
                Return cmd.ExecuteReader()
            Catch ex As Exception
                ex.Data.Add("Query", query)
                ex.Data.Add("Parameters", params)
                Throw ex
            End Try
        End Using
    End Function
    Public Function GetReader(query As String, Optional params As Hashtable = Nothing) As IDataReader
        Return Me.GetReader(query, Me.CommandTimeout, params)
    End Function
    Public Function GetReader(query As String, timeout As Integer) As IDataReader
        Return Me.GetReader(query, timeout, Nothing)
    End Function
#End Region

#Region "Update"
    Public Overridable Function Update(query As String, timeout As Integer, params As Hashtable) As Int64
        Using cmd As IDbCommand = Me.GetCommand(query, timeout, params)
            Try
                Return cmd.ExecuteNonQuery()
            Catch ex As Exception
                ex.Data.Add("Query", query)
                ex.Data.Add("Parameters", params)
                Throw ex
            End Try
        End Using
    End Function
    Public Function Update(query As String, Optional params As Hashtable = Nothing) As Int64
        Return Me.Update(query, Me.CommandTimeout, params)
    End Function
    Public Function Update(query As String, timeout As Integer) As Int64
        Return Me.Update(query, timeout, Nothing)
    End Function
#End Region

#Region "BulkLoad"
    Public Overridable Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Int64)) As Int64 Implements ISimplySqlProvider.BulkLoad
        Dim batchIteration As Int64 = 0
        Dim ord As Integer = 0
        Dim hasPrepared As Boolean = False
        Dim schemaMap As New List(Of SchemaMapItem)
        For Each dr In dataReader.GetSchemaTable().Rows.Cast(Of DataRow).OrderBy(Function(x) x("ColumnOrdinal"))
            schemaMap.Add(New SchemaMapItem(ord, dr("ColumnName"), dr("ColumnName")))
            ord += 1
        Next

        If columnMap IsNot Nothing AndAlso columnMap.Count > 0 Then
            Dim columnMapDictionary As Dictionary(Of String, String) = columnMap.Cast(Of DictionaryEntry).ToDictionary(Function(x) x.Key.ToString, Function(x) x.Value.ToString)
            schemaMap = schemaMap.Where(Function(x) columnMapDictionary.ContainsKey(x.SourceName)).Select(Function(x) New SchemaMapItem(x.Ordinal, x.SourceName, columnMapDictionary(x.SourceName)))
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
                            schemaMap.ForEach(Sub(x) bulkCmd.Parameters(x.Ordinal) = dataReader.GetValue(x.Ordinal))
                        End If
                        batchIteration += 1
                        bulkCmd.ExecuteNonQuery()

                        If sw.Elapsed.TotalSeconds > batchTimeout Then
                            Dim ex As New TimeoutException(String.Format("Batch took longer than {0} seconds to complete.", batchTimeout))
                            ex.Data.Add("Query", insertSql)
                            ex.Data.Add("Parameters", bulkCmd.Parameters)
                            Throw ex
                        End If

                        If batchIteration Mod batchSize = 0 Then
                            bulkCmd.Transaction.Commit()
                            bulkCmd.Transaction.Dispose()
                            If notify IsNot Nothing Then notify(batchIteration)
                            bulkCmd.Transaction = Me.Connection.BeginTransaction()
                            sw.Restart()
                        End If
                    End While

                    bulkCmd.Transaction.Commit()
                Catch ex As Exception
                    ex.Data.Add("Query", insertSql)
                    ex.Data.Add("Parameters", bulkCmd.Parameters)
                    Throw ex
                Finally
                    If bulkCmd.Transaction IsNot Nothing Then bulkCmd.Transaction.Dispose()
                End Try
            End Using
        End Using
        Return batchIteration
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

    Public ReadOnly Property HasMessages() As Boolean Implements ISimplySqlProvider.HasMessages
        Get
            Return Me.Messages.Count > 0
        End Get
    End Property
#End Region

#Region "Transactions"
    Private _transaction As IDbTransaction
    Public Property Transaction As IDbTransaction Implements ISimplySqlProvider.Transaction
        Private Set(value As IDbTransaction)
            _transaction = value
        End Set
        Get
            Return _transaction
        End Get
    End Property
    Public ReadOnly Property HasTransaction As Boolean = Me.Transaction IsNot Nothing Implements ISimplySqlProvider.HasTransaction
    Sub BeginTransaction() Implements ISimplySqlProvider.BeginTransaction
        If Me.HasTransaction Then Throw New InvalidOperationException("Cannot BEGIN a transaction when one is already in progress.")
        Me.Transaction = Me.Connection.BeginTransaction()
    End Sub
    Sub RollbackTransaction() Implements ISimplySqlProvider.RollbackTransaction
        If Me.HasTransaction Then
            Me.Transaction.Rollback()
            Me.Transaction.Dispose()
            Me.Transaction = Nothing
        Else
            Throw New InvalidOperationException("Cannot ROLLBACK when there is no transaction in progress.")
        End If
    End Sub

    Sub CommitTransaction() Implements ISimplySqlProvider.CommitTransaction
        If Me.HasTransaction Then
            Me.Transaction.Commit()
            Me.Transaction.Dispose()
            Me.Transaction = Nothing
        Else
            Throw New InvalidOperationException("Cannot COMMIT when there is no transaction in progress.")
        End If
    End Sub

#End Region
#End Region

    Private Class SchemaMapItem
        Public ReadOnly Ordinal As Integer
        Public ReadOnly SourceName As String
        Public ReadOnly DestinationName As String
        Public Sub New(ord As Integer, src As String, dst As String)
            Me.Ordinal = ord
            Me.SourceName = src
            Me.DestinationName = dst
        End Sub
    End Class
End Class


