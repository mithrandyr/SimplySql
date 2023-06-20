﻿Imports SimplySql.Common

<Cmdlet(VerbsCommon.Open, "MySqlConnection", DefaultParameterSetName:="default")>
Public Class OpenMySqlConnection
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
    Public Property Database As String = "mysql"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property Port As Integer = 3306

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    Public Property SSLMode As Common.SslMode = SslMode.Preferred

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

            Dim connDetail As New ConnectionMySql(ConnectionName, CommandTimeout)
            If Credential IsNot Nothing Then connDetail.SetAuthCredential(Credential)

            If Me.ParameterSetName = "conn" Then
                connDetail.ConnectionString = ConnectionString
            Else
                With connDetail
                    .Server = Server
                    .Database = Database
                    .Port = Port
                    .SslMode = SSLMode
                End With
            End If

            Engine.Logic.OpenAndAddConnection(connDetail)
            WriteVerbose($"{ConnectionName} (MySqlConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "OpenMySQLConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
