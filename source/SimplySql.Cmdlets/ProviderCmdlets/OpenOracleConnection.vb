Imports System.DirectoryServices.ActiveDirectory
Imports System.Runtime.InteropServices.ComTypes
Imports SimplySql.Common

<Cmdlet(VerbsCommon.Open, "OracleConnection", DefaultParameterSetName:="default")>
Public Class OpenOracleConnection
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
    Public Property ServiceName As String

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property Port As Integer = 1521

    <Parameter(Mandatory:=True, ParameterSetName:="tns", ValueFromPipelineByPropertyName:=True)>
    Public Property TnsName As String

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    Public Property Privilege As SimplySql.Common.ConnectionOracle.OraclePrivilege = ConnectionOracle.OraclePrivilege.None

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=2)>
    <Parameter(ParameterSetName:="tns", ValueFromPipelineByPropertyName:=True)>
    Public Property Credential As PSCredential

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    <Parameter(ParameterSetName:="tns", ValueFromPipelineByPropertyName:=True)>
    Public Property Additional As Hashtable

    <Parameter(Mandatory:=True, ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property ConnectionString As String
#End Region

    Protected Overrides Sub ProcessRecord()
        Try
            If Engine.Logic.ConnectionExists(ConnectionName) Then
                Engine.Logic.CloseAndRemoveConnection(ConnectionName)
            End If

            Dim connDetail As New ConnectionOracle(ConnectionName, CommandTimeout)
            If Credential IsNot Nothing Then connDetail.SetAuthCredential(Credential)

            Select Case ParameterSetName
                Case "conn"
                    connDetail.ConnectionString = ConnectionString
                Case "tns"
                    connDetail.TNSName = TnsName
                Case Else
                    With connDetail
                        .Host = Server
                        .ServiceName = ServiceName
                        .Port = Port
                        .Privilege = Privilege
                    End With
            End Select

            Engine.Logic.OpenAndAddConnection(connDetail)
            WriteVerbose($"{ConnectionName} (OracleConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "OpenOracleConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
