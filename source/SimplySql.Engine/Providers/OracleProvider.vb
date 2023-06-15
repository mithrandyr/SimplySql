Imports System.Collections.Specialized
Imports System.ComponentModel
Imports Oracle.ManagedDataAccess.Client

Public Class OracleProvider
    Inherits ProviderBase

    Public Overloads ReadOnly Property Connection As OracleConnection
        Get
            Return DirectCast(MyBase.Connection, OracleConnection)
        End Get
    End Property

    Private Sub New(connName As String, timeout As Integer, conn As OracleConnection)
        MyBase.New(connName, ProviderTypes.Oracle, conn, timeout)

        AddHandler Me.Connection.InfoMessage, AddressOf HandleInfoMessage
    End Sub

    Public Overrides Function ConnectionInfo() As OrderedDictionary
        Dim od = MyBase.ConnectionInfo
        With od
            .Add("ServerVersion", Connection.ServerVersion)
            .Add("DataSource", Connection.DataSource)
            .Add("Database", Connection.Database)
            .Add("Privilege", Connection.Credential.DBAPrivilege)
        End With
        Return od
    End Function

    Public Overrides Sub ChangeDatabase(databaseName As String)
        Connection.ChangeDatabase(databaseName)
    End Sub

    Private Sub HandleInfoMessage(sender As Object, e As OracleInfoMessageEventArgs)
        Me.Messages.Enqueue(New SqlMessage(e.Message))
    End Sub
#Region "Shared"
    Shared Sub New()
        OracleConfiguration.BindByName = True 'otherwise oracle commands will bind parameters by position
    End Sub
    Public Shared Function Create(connDetail As ConnectionOracle) As OracleProvider
        Dim sb As OracleConnectionStringBuilder
        Dim conn As OracleConnection
        If connDetail.HasConnectionString Then
            sb = New OracleConnectionStringBuilder(connDetail.ConnectionString)
        Else
            sb = New OracleConnectionStringBuilder()
            If connDetail.HasTnsName Then
                sb.DataSource = connDetail.TnsName
            Else
                sb.DataSource = $"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST={connDetail.Host})(PORT={connDetail.Port}))(CONNECT_DATA=(SERVICE_NAME={connDetail.ServiceName})))"
            End If
        End If

        If connDetail.UseIntegratedSecurity Then
            sb.UserID = "/"
            sb.DBAPrivilege = ConvertToOracleDBAPrivilege(connDetail.Privilege)
            conn = New OracleConnection(sb.ConnectionString)
        Else
            conn = New OracleConnection(sb.ConnectionString, New OracleCredential(connDetail.UserName, connDetail.SecurePassword, ConvertToOracleDBAPrivilege(connDetail.Privilege)))
        End If

        Return New OracleProvider(connDetail.ConnectionName, connDetail.CommandTimeout, conn)
    End Function
    Private Shared Function ConvertToOracleDBAPrivilege(priv As ConnectionOracle.OraclePrivilege) As OracleDBAPrivilege
        Select Case priv
            Case ConnectionOracle.OraclePrivilege.None
                Return OracleDBAPrivilege.None
            Case ConnectionOracle.OraclePrivilege.SYSDBA
                Return OracleDBAPrivilege.SYSDBA
            Case ConnectionOracle.OraclePrivilege.SYSOPER
                Return OracleDBAPrivilege.SYSOPER
            Case ConnectionOracle.OraclePrivilege.SYSASM
                Return OracleDBAPrivilege.SYSASM
            Case Else
                Throw New InvalidEnumArgumentException(NameOf(priv), priv, GetType(OracleDBAPrivilege))
        End Select
    End Function
#End Region
End Class
