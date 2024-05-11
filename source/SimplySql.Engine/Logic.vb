Imports System.Management.Automation

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
                provider = CreateProviderMSSQL(connDetail)
            Case ProviderTypes.MySql
                provider = CreateProviderMySQL(connDetail)
            Case ProviderTypes.Oracle
                provider = CreateProviderOracle(connDetail)
            Case ProviderTypes.PostGre
                provider = CreateProviderPostGre(connDetail)
            Case ProviderTypes.SQLite
                provider = CreateProviderSQLite(connDetail)
            Case Else
                Throw New ArgumentOutOfRangeException(NameOf(connDetail), connDetail.ConnectionType, $"'{connDetail.ConnectionType}' is not a supported provider.")
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

#Region "Provider Create Functions"
    Private Function CreateProviderMSSQL(connDetail As baseConnectionDetail) As ISimplySqlProvider
        Return MSSQLProvider.Create(connDetail)
    End Function
    Private Function CreateProviderMySql(connDetail As baseConnectionDetail) As ISimplySqlProvider
        Return MySqlProvider.Create(connDetail)
    End Function
    Private Function CreateProviderOracle(connDetail As baseConnectionDetail) As ISimplySqlProvider
        Return OracleProvider.Create(connDetail)
    End Function
    Private Function CreateProviderPostGre(connDetail As baseConnectionDetail) As ISimplySqlProvider
        Return PostGreProvider.Create(connDetail)
    End Function
    Private Function CreateProviderSQLite(connDetail As baseConnectionDetail) As ISimplySqlProvider
        Return SQLiteProvider.Create(connDetail)
    End Function
#End Region
End Module