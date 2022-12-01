Imports System.Runtime.CompilerServices
Module Dry
    <Extension>
    Sub ErrorConnectionNotFound(this As PSCmdlet, connectionName As String)
        Dim ex As New ArgumentException($"'{connectionName}' does not exist as connection.", "ConnectionName")
        this.WriteError(New ErrorRecord(ex, this.MyInvocation.MyCommand.Name, ErrorCategory.ObjectNotFound, connectionName))
    End Sub

    <Extension>
    Sub ErrorOperationFailed(this As PSCmdlet, ex As Exception, connectionName As String, Optional errCategory As ErrorCategory = ErrorCategory.InvalidOperation)
        this.WriteError(New ErrorRecord(ex, this.MyInvocation.MyCommand.Name, errCategory, connectionName))
    End Sub

    <Extension>
    Function ConvertToHashtable(this As PSObject, Optional ignoreNull As Boolean = True) As Hashtable
        Dim ht As New Hashtable
        Dim propQuery = this.Properties.Where(Function(prop) prop.MemberType = PSMemberTypes.Property Or prop.MemberType = PSMemberTypes.AliasProperty Or prop.MemberType = PSMemberTypes.NoteProperty).AsQueryable
        If ignoreNull Then propQuery = propQuery.Where(Function(prop) prop.Value IsNot Nothing)

        For Each prop In propQuery
            ht.Add(prop.Name, prop.Value)
        Next
        Return ht
    End Function

    <Extension>
    Function ConvertToPSObject(this As Data.IDataReader) As IEnumerable(Of PSObject)
        Return DataReaderToPSObject.Convert(this)
    End Function
End Module
