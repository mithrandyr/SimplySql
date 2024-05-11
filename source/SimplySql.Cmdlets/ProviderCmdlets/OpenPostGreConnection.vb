<Cmdlet(VerbsCommon.Open, "PostGreConnection", DefaultParameterSetName:="default")>
Public Class OpenPostGreConnection
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
    <[Alias]("Host")>
    <PSDefaultValue(Value:="localhost")>
    Public Property Server As String = "localhost"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=1)>
    <[Alias]("InitialCatalog")>
    <PSDefaultValue(Value:="postgres")>
    Public Property Database As String = "postgres"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    <PSDefaultValue(Value:=5432)>
    Public Property Port As Integer = 5432

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    <PSDefaultValue(Value:=25)>
    Public Property MaxAutoPrepare As Integer = 25

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    <PSDefaultValue(Value:="Preferred")>
    <ValidateSet("Disable", "Prefer", "Require", "VerifyCA", "VerifyFull")>
    Public Property SSLMode As String = "Prefer"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=2)>
    <Parameter(ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property Credential As PSCredential

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property Additional As Hashtable

    <Parameter(Mandatory:=True, ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property ConnectionString As String
#End Region

    Protected Overrides Sub ProcessRecord()
        Try
            If Engine.Logic.ConnectionExists(ConnectionName) Then
                Engine.Logic.CloseAndRemoveConnection(ConnectionName)
            End If

            Dim connDetail As New Engine.ConnectionPostGre(ConnectionName, CommandTimeout) With {.Additional = Additional}
            If Credential IsNot Nothing Then connDetail.SetAuthCredential(Credential)

            If Me.ParameterSetName = "conn" Then
                connDetail.ConnectionString = ConnectionString
            Else
                With connDetail
                    .Host = Server
                    .Database = Database
                    .Port = Port
                    .MaxAutoPrepare = MaxAutoPrepare
                    .SslMode = SSLMode
                    .Additional = Additional
                End With
            End If

            Engine.Logic.OpenAndAddConnection(connDetail)
            WriteVerbose($"{ConnectionName} (PostGreConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "OpenPostGreConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
