Imports System.Data
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

    <Extension>
    Sub AddQueryDetails(this As Exception, query As String, ht As Hashtable)
        this.Data.Add("Query", query)
        Try
            this.Data.Add("Parameters", ht)
        Catch ex As Exception
            this.Data.Add("ParameterExceptionMessage", ex.Message)
        End Try
    End Sub

    <Extension>
    Sub AddQueryDetails(this As Exception, query As String, sqlParams As IDataParameterCollection)
        this.Data.Add("Query", query)
        Try
            this.Data.Add("Parameters", sqlParams)
        Catch ex As Exception
            this.Data.Add("ParameterExceptionMessage", ex.Message)
        End Try
    End Sub
End Module
