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
    Public ReadOnly AuthType As AuthMSSQLType = AuthMSSQLType.UserNamePassword
    Public ReadOnly Property AzureToken As String

    Sub New()
        MyBase.New(Nothing, Nothing)
        Me.AuthType = AuthMSSQLType.Windows
    End Sub

    Sub New(azToken As String)
        MyBase.New(Nothing, Nothing)
        Me.AuthType = AuthMSSQLType.Azure
        If azToken.StartsWith("bearer ") Then
            Me.AzureToken = azToken.Substring(7)
        Else
            Me.AzureToken = azToken
        End If
    End Sub

    Public Enum AuthMSSQLType
        Windows
        Azure
        UserNamePassword
    End Enum
End Class