Imports System.Net

Public Class ConnectionMySql
    Inherits baseConnectionDetail
    Public Property Server As String
    Public Property Database As String
    Public Property Port As Integer
    Public Property SslMode As String = ""

    Sub New(connName As String, cmdTimeout As Integer)
        MyBase.New(connName, ProviderTypes.MySql, cmdTimeout)
        Me.UseIntegratedSecurity = False
    End Sub

    Sub SetAuthCredential(cred As NetworkCredential)
        Me.UseIntegratedSecurity = False
        Me.Credential = cred
    End Sub
End Class
