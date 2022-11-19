﻿<Cmdlet(VerbsLifecycle.Invoke, "SqlScalar", SupportsShouldProcess:=True)>
Public Class InvokeSqlScalar
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
                    Engine.Logic.GetConnection(ConnectionName).ClearMessages()
                    WriteVerbose($"SQL Messages cleared from '{ConnectionName}'.")
                Catch ex As Exception
                    WriteWarning($"[{ConnectionName}] {ex.Message}")
                End Try
            End If
        End If
    End Sub

End Class
