Imports System.Globalization
Imports System.Runtime.CompilerServices
Imports System.Runtime.Serialization

Module Dry
    <Extension>
    Function ValidateConnection(this As PSCmdlet, connectionName As String, Optional validateIsOpen As Boolean = True) As Boolean
        Dim result = Engine.ConnectionExists(connectionName, validateIsOpen)
        Select Case result
            Case Engine.ValidateConnectionResult.NotFound
                this.WriteError(New ErrorRecord(New ConnectionNotFound(connectionName), this.MyInvocation.MyCommand.Name, ErrorCategory.ObjectNotFound, connectionName))
                Return False
            Case Engine.ValidateConnectionResult.NotOpen
                this.WriteError(New ErrorRecord(New ConnectionNotOpen(connectionName), this.MyInvocation.MyCommand.Name, ErrorCategory.ResourceUnavailable, connectionName))
                Return False
            Case Engine.ValidateConnectionResult.Found, Engine.ValidateConnectionResult.Open
                Return True
            Case Else
                Throw New NotImplementedException($"ValidateConnectionResult '{result}' is not implemented!")
        End Select
    End Function

    <Extension>
    Sub ErrorOperationFailed(this As PSCmdlet, ex As Exception, connectionName As String, Optional errCategory As ErrorCategory = ErrorCategory.InvalidOperation)
        this.WriteError(New ErrorRecord(ex, this.MyInvocation.MyCommand.Name, errCategory, connectionName))
    End Sub

    <Extension>
    Function ConvertToHashtable(this As PSObject, Optional ignoreNull As Boolean = True) As Hashtable
        Dim ht As New Hashtable
        Dim propQuery = this.Properties.Where(Function(prop) prop.MemberType = PSMemberTypes.Property Or prop.MemberType = PSMemberTypes.AliasProperty Or prop.MemberType = PSMemberTypes.NoteProperty).AsQueryable
        If ignoreNull Then propQuery = propQuery.Where(Function(prop) prop.Value IsNot Nothing)

        Dim nValue As Object
        For Each prop In propQuery
            nValue = prop.Value
            If TypeOf nValue Is PSObject Then nValue = DirectCast(nValue, PSObject).BaseObject
            If Type.GetTypeCode(nValue.GetType()) = TypeCode.Object Then
                If TypeOf nValue Is Xml.XmlNode Then
                    nValue = DirectCast(nValue, Xml.XmlNode).OuterXml
                Else
                    nValue = nValue.ToString()
                End If
            End If
            ht.Add(prop.Name, nValue)
        Next
        Return ht
    End Function

    <Extension>
    Function ConvertToPSObject(this As Data.IDataReader) As IEnumerable(Of PSObject)
        Return DataReaderToPSObject.Convert(this)
    End Function
End Module

#Region "Exceptions"
Public Class ConnectionNotFound
    Inherits Exception
    Public ReadOnly Property ConnectionName As String
    Sub New(connectionName As String)
        MyBase.New($"Connection '{connectionName}' does not exist.")
        Me.ConnectionName = connectionName
    End Sub
    Public Sub New(connectionName As String, innerException As Exception)
        MyBase.New($"Connection '{connectionName}' does not exist.", innerException)
        Me.ConnectionName = connectionName
    End Sub
End Class

Public Class ConnectionNotOpen
    Inherits Exception
    Public ReadOnly Property ConnectionName As String
    Sub New(connectionName As String)
        MyBase.New($"Connection '{connectionName}' is not open.")
        Me.ConnectionName = connectionName
    End Sub
    Public Sub New(connectionName As String, innerException As Exception)
        MyBase.New($"Connection '{connectionName}' is not open.", innerException)
        Me.ConnectionName = connectionName
    End Sub
End Class
#End Region