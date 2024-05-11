<Cmdlet(VerbsCommon.Open, "SQLiteConnection", DefaultParameterSetName:="default")>
Public Class OpenSQLiteConnection
    Inherits PSCmdlet

#Region "Cmdlet Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    <PSDefaultValue(Value:="default")>
    Public Property ConnectionName As String = "default"

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <PSDefaultValue(Value:=30)>
    Public Property CommandTimeout As Integer = 30

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=0)>
    <[Alias]("FilePath")>
    <PSDefaultValue(Value:=":memory:")>
    Public Property DataSource As String = ":memory:"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=1)>
    Public Property Password As String

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property Additional As Hashtable

    <Parameter(ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property ConnectionString As String
#End Region

    Protected Overrides Sub ProcessRecord()
        Try
            If Engine.Logic.ConnectionExists(ConnectionName) Then
                Engine.Logic.CloseAndRemoveConnection(ConnectionName)
            End If

            Dim connDetail As New Engine.ConnectionSQLite(ConnectionName, CommandTimeout)
            If Me.ParameterSetName = "conn" Then
                connDetail.ConnectionString = ConnectionString
            Else
                If Not DataSource.Equals(":memory:", StringComparison.OrdinalIgnoreCase) Then
                    DataSource = Me.GetUnresolvedProviderPathFromPSPath(DataSource) 'handle powershell paths using psdrives
                End If
                connDetail.Database = DataSource
                If Not String.IsNullOrWhiteSpace(Password) Then connDetail.Credential = New Net.NetworkCredential(Nothing, Password)
                connDetail.Additional = Additional
            End If

            Engine.Logic.OpenAndAddConnection(connDetail)
            WriteVerbose($"{ConnectionName} (SQLiteConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "OpenSQLiteConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
