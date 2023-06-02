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
            Throw New KeyNotFoundException($"No connection named '{connectionName}' exists.")
        End Try
    End Function

    Sub OpenAndAddConnection(newProvider As ISimplySqlProvider)
        newProvider.Connection.Open()
        Connections.Add(newProvider.ConnectionName, newProvider)
    End Sub

    Sub CloseAndRemoveConnection(connectionName As String)
        Try
            Dim conn = Connections.First(Function(item) item.Key.Equals(connectionName, StringComparison.OrdinalIgnoreCase)).Value
            If conn.HasTransaction Then conn.RollbackTransaction()
            Try
                conn.Connection.Close()
            Finally
                conn.Connection.Dispose()
                Connections.Remove(conn.ConnectionName)
            End Try
        Catch ioex As InvalidOperationException
            Throw New KeyNotFoundException($"No connection named '{connectionName}' exists.")
        End Try
    End Sub
End Module