Imports SimplySql.Common

Public Module Logic
    ReadOnly Property Connections As New Dictionary(Of String, ISimplySqlProvider)

    Function ConnectionExists(connectionName As String) As Boolean
        Return Connections.Keys.Any(Function(key) key.Equals(connectionName, StringComparison.OrdinalIgnoreCase))
    End Function

    Function GetConnection(connectionName As String) As ISimplySqlProvider
        Try
            Return Connections.First(Function(item) item.Key.Equals(connectionName, StringComparison.OrdinalIgnoreCase)).Value
        Catch ioex As InvalidOperationException
            Throw New IndexOutOfRangeException($"No connection named '{connectionName}' exists.")
        End Try
    End Function

    Sub RemoveConnection(connectionName As String)
        Try
            Dim key = Connections.Keys.First(Function(k) k.Equals(connectionName, StringComparison.OrdinalIgnoreCase))
            Connections.Remove(key)
        Catch ioex As InvalidOperationException
            Throw New IndexOutOfRangeException($"No connection named '{connectionName}' exists.")
        End Try
    End Sub

End Module