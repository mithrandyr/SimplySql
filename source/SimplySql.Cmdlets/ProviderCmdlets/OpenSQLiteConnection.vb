<Cmdlet(VerbsCommon.Open, "SQLiteConnection", DefaultParameterSetName:="default")>
Public Class OpenSQLiteConnection
    Inherits PSCmdlet

#Region "Cmdlet Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    Public Property CommandTimeout As Integer = 30

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=0)>
    <[Alias]("FilePath")>
    Public Property DataSource As String = ":memory:"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=1)>
    Public Property Password As String

    <Parameter(ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property ConnectionString As String
#End Region

    Protected Overrides Sub ProcessRecord()
        Try
            If Engine.Logic.ConnectionExists(ConnectionName) Then
                Engine.Logic.CloseAndRemoveConnection(ConnectionName)
            End If

            Dim newProvider As Engine.SQLiteProvider
            If Me.ParameterSetName = "conn" Then
                newProvider = Engine.SQLiteProvider.Create(ConnectionName, ConnectionString, CommandTimeout)
            Else
                If Not DataSource.Equals(":memory:", StringComparison.OrdinalIgnoreCase) Then
                    DataSource = Me.GetUnresolvedProviderPathFromPSPath(DataSource) 'handle powershell paths using psdrives
                End If
                newProvider = Engine.SQLiteProvider.Create(ConnectionName, DataSource, Password, CommandTimeout)
            End If

            Engine.Logic.OpenAndAddConnection(newProvider)
            WriteVerbose($"{ConnectionName} (SQLiteConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "NewSQLiteConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
