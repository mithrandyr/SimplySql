Imports System.Net
Imports System.Security
Imports System.Security.Cryptography

Public Class AuthClasses
    Public ReadOnly Property UserName As String
    Public ReadOnly Property Password As SecureString

    Sub New(user As String, pass As SecureString)
        Me.UserName = user
        Me.Password = pass
    End Sub
End Class

Public Class AuthMSSQL
    Inherits AuthClasses
    Public ReadOnly AuthType As AuthMSSQLType = AuthMSSQLType.Credential
    Public ReadOnly Property AzureToken As String
    Public ReadOnly Property Credential As NetworkCredential

    Sub New()
        MyBase.New(Nothing, Nothing)
        Me.AuthType = AuthMSSQLType.Windows
    End Sub

    Sub New(azToken As String)
        MyBase.New(Nothing, Nothing)
        Me.AuthType = AuthMSSQLType.Token
        If azToken.StartsWith("bearer ") Then
            Me.AzureToken = azToken.Substring(7)
        Else
            Me.AzureToken = azToken
        End If
    End Sub

    Sub New(cred As NetworkCredential, Optional isAzure As Boolean = False)
        MyBase.New(Nothing, Nothing)
        Me.AuthType = If(isAzure, AuthMSSQLType.AzureCredential, AuthMSSQLType.Credential)
        Me.Credential = cred
    End Sub

    Public Enum AuthMSSQLType
        Windows
        Credential
        AzureCredential
        Token
    End Enum
End Class