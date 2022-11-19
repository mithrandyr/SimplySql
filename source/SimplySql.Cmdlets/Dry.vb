Imports System.Runtime.CompilerServices
Module Dry
    <Extension>
    Function ConnectionNotFoundError(this As PSCmdlet, connectionName As String) As ErrorRecord
        Dim ex As New ArgumentException($"{connectionName} is not present.", "ConnectionName")
        Return New ErrorRecord(ex, $"{this.MyInvocation.MyCommand.Name}:ConnectionNameInvalid", ErrorCategory.InvalidArgument, connectionName)
    End Function

End Module
