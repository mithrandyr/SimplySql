Imports System.Net

Public Class ConnectionOracle
    Inherits baseConnectionDetail

    Public ReadOnly Property HasTnsName As Boolean
        Get
            Return Not String.IsNullOrWhiteSpace(TNSName)
        End Get
    End Property

    Public Property TnsName As String
    Public Property Host As String
    Public Property ServiceName As String
    Public Property Port As Integer
    Public Property Privilege As String = "None"

    Sub New(connName As String, cmdTimeout As Integer)
        MyBase.New(connName, ProviderTypes.Oracle, cmdTimeout)
    End Sub

    Sub SetAuthCredential(cred As NetworkCredential)
        Me.UseIntegratedSecurity = False
        Me.Credential = cred
    End Sub
End Class
