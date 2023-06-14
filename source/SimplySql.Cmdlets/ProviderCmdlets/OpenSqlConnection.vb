﻿Imports System.Management.Automation.Language
Imports System.Net.Http.Headers
Imports System.Runtime.InteropServices.ComTypes
Imports Azure.Identity
Imports Microsoft.Identity.Client.Platforms.Features.DesktopOs.Kerberos
Imports NetTopologySuite.Operation.Distance
Imports SimplySql.Common

<Cmdlet(VerbsCommon.Open, "SQLConnection", DefaultParameterSetName:="default")>
Public Class OpenSqlConnection
    Inherits PSCmdlet

#Region "Cmdlet Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"

    <Parameter(ValueFromPipelineByPropertyName:=True)>
    Public Property CommandTimeout As Integer = 30

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=0)>
    <Parameter(ParameterSetName:="credential", ValueFromPipelineByPropertyName:=True, Position:=0)>
    <Parameter(ParameterSetName:="token", ValueFromPipelineByPropertyName:=True, Position:=0)>
    <[Alias]("SqlInstance", "SqlServer", "DataSource")>
    Public Property Server As String = "localhost"

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True, Position:=1)>
    <Parameter(ParameterSetName:="credential", ValueFromPipelineByPropertyName:=True, Position:=1)>
    <Parameter(ParameterSetName:="token", ValueFromPipelineByPropertyName:=True, Position:=1)>
    <[Alias]("SqlDatabase", "InitialCatalog")>
    Public Property Database As String = "master"

    <Parameter(ParameterSetName:="credential", ValueFromPipelineByPropertyName:=True, Position:=2)>
    <Parameter(ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property Credential As PSCredential

    <Parameter(ParameterSetName:="credential", ValueFromPipelineByPropertyName:=True)>
    Public Property AzureAD As SwitchParameter

    <Parameter(ParameterSetName:="token", ValueFromPipelineByPropertyName:=True)>
    <Parameter(ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property AzureToken As String

    <Parameter(ParameterSetName:="default", ValueFromPipelineByPropertyName:=True)>
    <Parameter(ParameterSetName:="token", ValueFromPipelineByPropertyName:=True)>
    <Parameter(ParameterSetName:="credential", ValueFromPipelineByPropertyName:=True)>
    Public Property Additional As Hashtable

    <Parameter(Mandatory:=True, ParameterSetName:="conn", ValueFromPipelineByPropertyName:=True)>
    Public Property ConnectionString As String
#End Region

    Protected Overrides Sub ProcessRecord()
        Try
            If Engine.Logic.ConnectionExists(ConnectionName) Then
                Engine.Logic.CloseAndRemoveConnection(ConnectionName)
            End If

            Dim connDetail As New ConnectionMSSQL(ConnectionName, CommandTimeout)
            Select Case Me.ParameterSetName
                Case "credential"
                    connDetail.SetAuthCredential(Credential, AzureAD.IsPresent)
                Case "token"
                    connDetail.SetAuthToken(AzureToken)
            End Select

            If Me.ParameterSetName = "conn" Then
                connDetail.ConnectionString = ConnectionString
            Else
                With connDetail
                    .Server = Server
                    .Database = Database
                End With
            End If

            Engine.Logic.OpenAndAddConnection(connDetail)
            WriteVerbose($"{ConnectionName} (SQLConnection) opened.")
        Catch ex As Exception
            WriteError(New ErrorRecord(ex, "OpenSQLConnection.Error", ErrorCategory.OpenError, ConnectionName))
        End Try
    End Sub
End Class
