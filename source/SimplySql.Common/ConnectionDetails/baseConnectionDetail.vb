Imports System.Net
Imports System.Security
Imports System.Security.Cryptography

Public Class baseConnectionDetail
    Public ReadOnly Property Credential As NetworkCredential
    Public ReadOnly Property UserName As String
        Get
            Return Credential.UserName
        End Get
    End Property
    Public ReadOnly Property Password As String
        Get
            Return Credential.Password
        End Get
    End Property

    Public ReadOnly Property ApplicationName As String
    Public ReadOnly Property UseIntegratedSecurity As Boolean = False

    Public Property CommandTimeout As String

    Sub New(connName As String, Optional cred As NetworkCredential = Nothing)
        If cred Is Nothing Then
            UseIntegratedSecurity = True
        Else
            Me.Credential = cred
        End If

        Me.ApplicationName = $"PowerShell (SimplySql: {connName})"
    End Sub
End Class