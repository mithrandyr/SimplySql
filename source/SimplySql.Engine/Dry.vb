Imports System.Data.Common
Imports System.Runtime.CompilerServices
Module Dry
    <Extension>
    Sub AddHashtable(this As DbConnectionStringBuilder, ht As Hashtable)
        If ht IsNot Nothing Then
            For Each key In ht.Keys
                this.Add(key, ht(key))
            Next
        End If
    End Sub
End Module
