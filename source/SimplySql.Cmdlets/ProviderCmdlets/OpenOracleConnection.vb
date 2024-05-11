Imports System.DirectoryServices.ActiveDirectory
Imports System.Runtime.InteropServices.ComTypes

<Cmdlet(VerbsCommon.Open, "OracleConnection", DefaultParameterSetName:="default")>
Public Class OpenOracleConnection
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
    <[Alias]("Host", "DataSource")>
    <PSDefaultValue(Value:="localhost")>
    Public Property Server As String = "localhost"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=1)>
    Public Property ServiceName As String

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    <PSDefaultValue(Value:=1521)>
    Public Property Port As Integer = 1521

    <Parameter(Mandatory:=True, ParameterSetName:="tns", ValueFromPipelineByPropertyName:=True)>
    Public Property TnsName As String

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <ValidateSet("None", "SYSASM", "SYSDBA", "SYSOPER")>
    Public Property Privilege As String = "None"

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

            Dim connDetail As New Engine.ConnectionOracle(ConnectionName, CommandTimeout)
            If Credential IsNot Nothing Then connDetail.SetAuthCredential(Credential)

            Select Case ParameterSetName
                Case "conn"
                    connDetail.ConnectionString = ConnectionString
                Case "tns"
                    connDetail.TnsName = TnsName
                    connDetail.Additional = Additional
                Case Else
                    With connDetail
                        .Host = Server
                        .ServiceName = ServiceName
                        .Port = Port
                        .Privilege = Privilege
                        .Additional = Additional
                    End With
            End Select

            Engine.Logic.OpenAndAddConnection(connDetail)
            WriteVerbose($"{ConnectionName} (OracleConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "OpenOracleConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
