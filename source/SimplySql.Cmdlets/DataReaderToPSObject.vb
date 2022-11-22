Imports System.Data
Imports System.Data.Common
Imports System.Linq.Expressions

Public Class DataReaderToPSObject
    Shared Iterator Function ConvertOld(theDataReader As IDataReader) As IEnumerable(Of PSObject)
        Do
            Dim columns = map.CreateMappings(theDataReader)
            While theDataReader.Read
                Dim pso As New PSObject

                For Each col In columns
                    If theDataReader.IsDBNull(col.Ordinal) Then
                        pso.Properties.Add(New PSNoteProperty(col.Name, Nothing), True)
                    Else
                        Select Case col.Type
                            Case "System.Boolean"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetBoolean(col.Ordinal)), True)
                            Case "System.Byte"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetByte(col.Ordinal)), True)
                            Case "System.Char"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetChar(col.Ordinal)), True)
                            Case "System.DateTime"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetDateTime(col.Ordinal)), True)
                            Case "System.Decimal"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetDecimal(col.Ordinal)), True)
                            Case "System.Double"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetDouble(col.Ordinal)), True)
                            Case "System.Single"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetFloat(col.Ordinal)), True)
                            Case "System.Guid"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetGuid(col.Ordinal)), True)
                            Case "System.Int16"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetInt16(col.Ordinal)), True)
                            Case "System.Int32"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetInt32(col.Ordinal)), True)
                            Case "System.Int64"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetInt64(col.Ordinal)), True)
                            Case "System.String"
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetString(col.Ordinal)), True)
                            Case Else
                                pso.Properties.Add(New PSNoteProperty(col.Name, theDataReader.GetValue(col.Ordinal)))
                        End Select
                    End If
                Next
                Yield pso
            End While
        Loop While theDataReader.NextResult

        'Get list of columns -- Name & Type, then get the ordinal for each column
        'Build expression that uses the appropriate Get<Type>(forOrdinalPosition) function
        'to construct the PSObject
        'Invoke that function against DataReader (For each row)


    End Function

    Shared Iterator Function Convert(theDataReader As IDataReader) As IEnumerable(Of PSObject)

    End Function


    Public Class map
        Public Ordinal As Integer = 0
        Public Name As String
        Public Type As String
        Shared Function CreateMappings(dr As IDataReader) As Generic.List(Of map)
            Return Linq.Enumerable.Range(0, dr.FieldCount).Select(Function(ord) New map With {.Ordinal = ord, .Name = dr.GetName(ord), .Type = dr.GetFieldType(ord).ToString}).ToList
        End Function

        Shared Function CreateFunction(dr As IDataReader) As Func(Of IDataReader)
            Dim expList = New List(Of Expression)
            Dim columns = map.CreateMappings(dr)

            Dim paramDataReader = Expression.Parameter(GetType(IDataReader), "dr")
            Dim varPso = Expression.Variable(GetType(PSObject), "pso")
            Dim psoProperties = Expression.Property(varPso, GetType(PSObject).GetProperty("Properties"))

            expList.Add(Expression.Assign(varPso, Expression.[New](GetType(PSObject))))

            Dim drGetExp As Reflection.MethodInfo
            Dim mName As String
            For Each col In columns
                Dim paramOrd = Expression.Constant(col.Ordinal, GetType(Integer))
                Dim paramName = Expression.Constant(col.Name, GetType(String))
                Select Case col.Type
                    Case "System.Boolean"
                        drGetExp = GetType(IDataRecord).GetMethod("GetBoolean")
                    Case "System.Byte"
                        drGetExp = GetType(IDataRecord).GetMethod("GetByte")
                    Case "System.Char"
                        drGetExp = GetType(IDataRecord).GetMethod("GetChar")
                    Case "System.DateTime"
                        drGetExp = GetType(IDataRecord).GetMethod("GetDateTime")
                    Case "System.Decimal"
                        drGetExp = GetType(IDataRecord).GetMethod("GetDecimal")
                    Case "System.Double"
                        drGetExp = GetType(IDataRecord).GetMethod("GetDouble")
                    Case "System.Single"
                        drGetExp = GetType(IDataRecord).GetMethod("GetFloat")
                    Case "System.Guid"
                        drGetExp = GetType(IDataRecord).GetMethod("GetGuid")
                    Case "System.Int16"
                        drGetExp = GetType(IDataRecord).GetMethod("GetInt16")
                    Case "System.Int32"
                        drGetExp = GetType(IDataRecord).GetMethod("GetInt32")
                    Case "System.Int64"
                        drGetExp = GetType(IDataRecord).GetMethod("GetInt64")
                    Case "System.String"
                        drGetExp = GetType(IDataRecord).GetMethod("GetString")
                    Case Else
                        drGetExp = GetType(IDataRecord).GetMethod("GetValue")
                End Select
                drGetExp = GetType(IDataRecord).GetMethod("GetValue")
                Dim drGetValue = Expression.Call(paramDataReader, drGetExp, paramOrd)
                Dim newPSNote = Expression.[New](GetType(PSNoteProperty).GetConstructor({GetType(String), GetType(Object)}), {paramName, drGetValue})
                expList.Add(Expression.Call(psoProperties, GetType(PSMemberInfoCollection(Of PSPropertyInfo)).GetMethod("Add"), newPSNote))
            Next

            Dim lambda = Expression.Lambda(Of Func(Of IDataReader))(Expression.Block(expList), paramDataReader).Compile
            Console.WriteLine(lambda.ToString)
            Return lambda
        End Function
    End Class

End Class
