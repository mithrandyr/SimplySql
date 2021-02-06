Public MustInherit Class ProviderBase
    Public ReadOnly Property ConnectionName As String
    Public ReadOnly Property Connection As IDbConnection
    Public ReadOnly Property ProviderType As String = Me.GetType.Name
    Private _transaction As IDbTransaction
    Public ReadOnly Property Messages As New Queue(Of SqlMessage)
    Public ReadOnly Property HasTransaction As Boolean = Me.Transaction IsNot Nothing
    Public Property CommandTimeout As Integer = 30
    Public Property Transaction As IDbTransaction
        Private Set(value As IDbTransaction)
            _transaction = value
        End Set
        Get
            Return _transaction
        End Get
    End Property

    Public Sub New(connName As String)
        ConnectionName = connName
    End Sub

#Region "Overrides"
    Public MustOverride Function ConnectionInfo() As SortedDictionary(Of String, Object)
    Public MustOverride Sub ChangeDatabase()
    Public MustOverride Function GetDataSet() As DataSet
#End Region

#Region "Concrete"
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
    Public Function GetCommand(query As String, Optional params As Hashtable = Nothing)
        Return Me.GetCommand(query, Me.CommandTimeout, params)
    End Function
    Public Function GetCommand(query As String, timeout As Integer)
        Return Me.GetCommand(query, timeout, Nothing)
    End Function
#End Region

#Region "GetScalar"
    Public Overridable Function GetScalar(query As String, timeout As Integer, params As Hashtable) As Object
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
    Public Delegate Sub Notify(batchIteration As Int64)

    Public Overridable Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Notify) As Int64
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

#End Region
#End Region

End Class
