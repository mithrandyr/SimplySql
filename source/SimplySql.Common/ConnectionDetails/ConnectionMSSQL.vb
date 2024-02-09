Imports System.Net

Public Class ConnectionMSSQL
    Inherits baseConnectionDetail
    Public ReadOnly Property AuthType As AuthMSSQLType = AuthMSSQLType.Credential
    Public ReadOnly Property Token As String
        Get
            If AuthType = AuthMSSQLType.Token Then
                Return Credential.Password
            Else
                Throw New InvalidOperationException($"Cannot return {NameOf(Token)} when {NameOf(AuthType)} is not 'Token'.")
            End If
        End Get
    End Property

    Public Property Server As String
    Public Property Database As String

    Sub New(connName As String, cmdTimeout As Integer)
        MyBase.New(connName, ProviderTypes.MSSQL, cmdTimeout)
        SetAuthWindows()
    End Sub

    Sub SetAuthWindows()
        _AuthType = AuthMSSQLType.Windows
        Me.UseIntegratedSecurity = True
    End Sub
    Sub SetAuthToken(tkn As String)
        _AuthType = AuthMSSQLType.Token
        If tkn.StartsWith("bearer ") Then tkn = tkn.Substring(7)
        Credential = New NetworkCredential(Nothing, tkn)
        Me.UseIntegratedSecurity = False
    End Sub
    Sub SetAuthCredential(cred As NetworkCredential, Optional isAzure As Boolean = False)
        _AuthType = If(isAzure, AuthMSSQLType.AzureCredential, AuthMSSQLType.Credential)
        Credential = cred
        Me.UseIntegratedSecurity = False
    End Sub

    Public Enum AuthMSSQLType
        Windows
        Credential
        AzureCredential
        Token
    End Enum
End Class