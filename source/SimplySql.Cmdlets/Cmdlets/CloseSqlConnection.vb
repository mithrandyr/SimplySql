﻿<Cmdlet(VerbsCommon.Close, "SqlConnection", SupportsShouldProcess:=True)>
<[Alias]("csc")>
Public Class CloseSqlConnection
    Inherits PSCmdlet
#Region "Parameters"
    <Parameter(ValueFromPipelineByPropertyName:=True)>
    <[Alias]("cn")>
    <ValidateNotNullOrEmpty()>
    Public Property ConnectionName As String = "default"
#End Region

    Protected Overrides Sub ProcessRecord()
        If Not Engine.Logic.ConnectionExists(ConnectionName) Then
            WriteError(ConnectionNotFoundError(ConnectionName))
        Else
            If Me.ShouldProcess(ConnectionName) Then
                Try
                    Engine.Logic.CloseAndRemoveConnection(ConnectionName)
                    WriteVerbose($"SQL Connection '{ConnectionName}' closed.")
                Catch ex As Exception
                    WriteError(New ErrorRecord(ex, MyInvocation.MyCommand.Name, ErrorCategory.CloseError, ConnectionName))
                End Try
            End If
        End If
    End Sub
End Class