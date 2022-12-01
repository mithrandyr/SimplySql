﻿Imports System.Management.Automation.Language

<Cmdlet(VerbsCommon.Get, "SqlTransaction", SupportsShouldProcess:=True)>
Public Class GetSqlTransaction
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            ErrorConnectionNotFound(ConnectionName)
        Else
            If Me.ShouldProcess(ConnectionName, "Get Sql Transaction") Then
                Try
                    WriteObject(Engine.Logic.GetConnection(ConnectionName).Transaction)
                Catch ex As Exception
                    ErrorOperationFailed(ex, ConnectionName)
                End Try
            End If
        End If
    End Sub
End Class
