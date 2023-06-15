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
    Public Property Privilege As OraclePrivilege

    Sub New(connName As String, cmdTimeout As Integer)
        MyBase.New(connName, ProviderTypes.Oracle, cmdTimeout)
        SetAuthIntegrated()
    End Sub

    Sub SetAuthCredential(cred As NetworkCredential)
        Me.UseIntegratedSecurity = False
        Me.Credential = cred
    End Sub
    Sub SetAuthIntegrated()
        Me.UseIntegratedSecurity = True
    End Sub

    Public Enum OraclePrivilege
        None
        SYSDBA
        SYSOPER
        SYSASM
    End Enum
End Class
