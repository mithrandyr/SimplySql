Public Module Logic
    ReadOnly Property Connections As New Dictionary(Of String, ISimplySqlProvider)

    Function ConnectionExists(connectionName As String, Optional checkIsOpen As Boolean = True) As ValidateConnectionResult
        If Not Connections.Keys.Any(Function(key) key.Equals(connectionName, StringComparison.OrdinalIgnoreCase)) Then
            Return ValidateConnectionResult.NotFound
        Else
            If Not checkIsOpen Then
                Return ValidateConnectionResult.Found
            Else
                If Not GetConnection(connectionName).Connection.State = Data.ConnectionState.Open Then
                    Return ValidateConnectionResult.NotOpen
                Else
                    Return ValidateConnectionResult.Open
                End If
            End If
        End If
    End Function
    Function GetConnection(connectionName As String) As ISimplySqlProvider
        Try
            Return Connections.First(Function(item) item.Key.Equals(connectionName, StringComparison.OrdinalIgnoreCase)).Value
        Catch ioex As InvalidOperationException
            Throw New KeyNotFoundException($"No connection named '{connectionName}' exists.")
        End Try
    End Function

    Sub OpenAndAddConnection(connDetail As baseConnectionDetail)
        Dim provider As ISimplySqlProvider
        Select Case connDetail.ConnectionType
            Case ProviderTypes.MSSQL
                provider = MSSQLProvider.Create(connDetail)
            Case ProviderTypes.MySql
                provider = MySqlProvider.Create(connDetail)
            Case ProviderTypes.Oracle
                provider = OracleProvider.Create(connDetail)
            Case ProviderTypes.PostGre
                provider = PostGreProvider.Create(connDetail)
            Case ProviderTypes.SQLite
                provider = SQLiteProvider.Create(connDetail)
        End Select
        provider.Connection.Open()
        Connections.Add(connDetail.ConnectionName, provider)
    End Sub

    Sub OpenAndAddConnection(newProvider As ISimplySqlProvider)
        ' ideally, this should take the type and the base Connection details (abstraction) and handle provider creation and returning it.
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