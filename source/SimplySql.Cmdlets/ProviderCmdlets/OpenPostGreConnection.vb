Imports System.Management.Automation.Language
Imports System.Net.Http.Headers
Imports System.Runtime.InteropServices.ComTypes
Imports Azure.Identity
Imports Microsoft.Identity.Client.Platforms.Features.DesktopOs.Kerberos
Imports NetTopologySuite.Operation.Distance
Imports SimplySql.Common

<Cmdlet(VerbsCommon.Open, "PostGreConnection", DefaultParameterSetName:="default")>
Public Class OpenPostGreConnection
    Inherits PSCmdlet

#Region "Cmdlet Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    Public Property CommandTimeout As Integer = 30

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=0)>
    <[Alias]("Host")>
    Public Property Server As String = "localhost"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=1)>
    <[Alias]("InitialCatalog")>
    Public Property Database As String = "postgres"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property Port As Integer = 5432

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property MaxAutoPrepare As Integer = 25

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property RequireSSL As SwitchParameter

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property TrustSSL As SwitchParameter

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

            Dim connDetail As New ConnectionPostGre(ConnectionName, CommandTimeout)
            If Credential IsNot Nothing Then connDetail.SetAuthCredential(Credential)

            If Me.ParameterSetName = "conn" Then
                connDetail.ConnectionString = ConnectionString
            Else
                With connDetail
                    .Host = Server
                    .Database = Database
                    .Port = Port
                    .MaxAutoPrepare = MaxAutoPrepare
                    .RequireSSL = RequireSSL.IsPresent
                    .TrustServerCertificate = TrustSSL.IsPresent
                End With
            End If

            Engine.Logic.OpenAndAddConnection(connDetail)
            WriteVerbose($"{ConnectionName} (SQLConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "OpenSQLConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
