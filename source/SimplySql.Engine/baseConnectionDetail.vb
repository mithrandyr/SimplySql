Imports System.Net
Imports System.Security
Imports System.Security.Cryptography

Public Class baseConnectionDetail
    Public ReadOnly Property ConnectionName As String
    Public ReadOnly Property ConnectionType As ProviderTypes
    Public ReadOnly Property UserName As String
        Get
            Return Credential?.UserName
        End Get
    End Property
    Public ReadOnly Property Password As String
        Get
            Return Credential?.Password
        End Get
    End Property
    Public ReadOnly Property SecurePassword As SecureString
        Get
            Return Credential?.SecurePassword
        End Get
    End Property
    Public ReadOnly Property HasConnectionString As Boolean
        Get
            Return Not String.IsNullOrWhiteSpace(ConnectionString)
        End Get
    End Property

    Public Property Credential As NetworkCredential
    Public Property UseIntegratedSecurity As Boolean
    Public Property ConnectionString As String
    Public ReadOnly Property CommandTimeout As Integer
    Public Property Additional As Hashtable

    Sub New(connName As String, conntype As ProviderTypes, cmdTimeout As Integer)
        Me.ConnectionName = connName
        Me.ConnectionType = conntype
        Me.CommandTimeout = cmdTimeout
    End Sub

    Public Function ApplicationName() As String
        Return $"PowerShell (SimplySql: {ConnectionName})"
    End Function
End Class