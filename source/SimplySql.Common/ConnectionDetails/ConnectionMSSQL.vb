Imports System.Net

Public Class ConnectionMSSQL
    Inherits baseConnectionDetail
    Public ReadOnly AuthType As AuthMSSQLType = AuthMSSQLType.Credential
    Public ReadOnly Property AzureToken As String

    Sub New(connName As String)
        MyBase.New(connName)
        Me.AuthType = AuthMSSQLType.Windows
    End Sub

    Sub New(connName As String, azToken As String)
        MyBase.New(Nothing, Nothing)
        Me.AuthType = AuthMSSQLType.Token
        If azToken.StartsWith("bearer ") Then
            Me.AzureToken = azToken.Substring(7)
        Else
            Me.AzureToken = azToken
        End If
    End Sub

    Sub New(cred As NetworkCredential, Optional isAzure As Boolean = False)
        MyBase.New(cred)
        Me.AuthType = If(isAzure, AuthMSSQLType.AzureCredential, AuthMSSQLType.Credential)
    End Sub

    Public Enum AuthMSSQLType
        Windows
        Credential
        AzureCredential
        Token
    End Enum
End Class