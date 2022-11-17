Imports System.Data
Public Interface ISimplySqlProvider
    ReadOnly Property ConnectionName As String
    ReadOnly Property Connection As IDbConnection
    ReadOnly Property ProviderName As String
    ReadOnly Property Messages As Queue(Of SqlMessage)
    ReadOnly Property HasTransaction As Boolean
    Property CommandTimeout As Integer

    Property Transaction As IDbTransaction
    Function ConnectionInfo() As SortedDictionary(Of String, Object)
    Sub ChangeDatabase()

    Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Int64)) As Int64
    Function GetMessage() As SqlMessage
    Sub ClearMessages()
    ReadOnly Property HasMessages As Boolean


End Interface
