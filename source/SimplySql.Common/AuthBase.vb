Imports System.Security

Public Class AuthBase
    Public ReadOnly Property UserName As String
    Public ReadOnly Property Password As SecureString

    Sub New(user As String, pass As SecureString)
        Me.UserName = user
        Me.Password = pass
    End Sub
End Class

Public Class AuthMSSQL
    Inherits AuthBase
    Public ReadOnly Property WindowsAuth As Boolean = False
    Public ReadOnly Property AzureToken As String

    Sub New()
        MyBase.New(Nothing, Nothing)
        Me.WindowsAuth = True
    End Sub

    Sub New(azToken As String)
        MyBase.New(Nothing, Nothing)
        If azToken.StartsWith("bearer ") Then
            Me.AzureToken = azToken.Substring(7)
        Else
            Me.AzureToken = azToken
        End If
    End Sub

End Class