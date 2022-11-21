Imports System.Data

Public Class DataReaderToPSObject
    Shared Iterator Function Convert(theDataReader As IDataReader) As IEnumerable(Of PSObject)
        Dim columns As New Generic.List(Of Tuple(Of Integer, String, String))
        For Each row In theDataReader.GetSchemaTable().Rows
            columns.Add(New Tuple(Of Integer, String, String)(row("ColumnOrdinal"), row("ColumnName"), row("DataType")))
        Next

        'Get list of columns -- Name & Type, then get the ordinal for each column
        'Build expression that uses the appropriate Get<Type>(forOrdinalPosition) function
        'to construct the PSObject
        'Invoke that function against DataReader (For each row)


    End Function

End Class
