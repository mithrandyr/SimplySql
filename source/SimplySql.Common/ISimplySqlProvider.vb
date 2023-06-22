Imports System.Collections.Specialized
Imports System.Data
Public Interface ISimplySqlProvider
    ReadOnly Property ConnectionName As String
    ReadOnly Property Connection As IDbConnection
    ReadOnly Property ProviderName As String
    Property CommandTimeout As Integer
    Function ConnectionInfo() As OrderedDictionary
    Sub ChangeDatabase(databaseName As String)

#Region "DataAccess"
    Function GetScalar(query As String, cmdTimeout As Integer, parameters As Hashtable) As Object
    Function GetCommand(query As String, cmdTimeout As Integer, parameters As Hashtable) As IDbCommand
    Function GetDataSet(query As String, cmdTimeout As Integer, parameters As Hashtable, useProviderTypes As Boolean) As DataSet
    Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Int64)) As Int64
    Function GetDataReader(query As String, parameters As Hashtable, Optional cmdTimeout As Integer = -1) As IDataReader
    Function Update(cmd As IDbCommand) As Int64
    Function Update(query As String, cmdTimeout As Integer, parameters As Hashtable) As Int64
#End Region

#Region "Messages"
    ReadOnly Property Messages As Queue(Of SqlMessage)
    ReadOnly Property HasMessages As Boolean
    Function GetMessage() As SqlMessage
    Sub ClearMessages()
#End Region

#Region "Transaction"
    Property Transaction As IDbTransaction
    ReadOnly Property HasTransaction As Boolean
    Sub BeginTransaction()
    Sub CommitTransaction()
    Sub RollbackTransaction()
#End Region
End Interface
