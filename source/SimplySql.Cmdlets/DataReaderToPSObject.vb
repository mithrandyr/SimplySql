Imports System.Data
Imports System.Data.Common
Imports System.Linq.Expressions

Public Class DataReaderToPSObject
    Shared Iterator Function Convert(theDataReader As IDataReader) As IEnumerable(Of PSObject)
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
    End Function

    Shared Iterator Function ConvertUsingExpressionTree(theDataReader As IDataReader) As IEnumerable(Of PSObject)
        Do
            Dim convertFunction = map.CreateFunction(theDataReader)
            While theDataReader.Read
                Yield convertFunction(theDataReader)
            End While
        Loop While theDataReader.NextResult
    End Function

    Friend Class map
        Public Ordinal As Integer = 0
        Public Name As String
        Public Type As String
        Shared Function CreateMappings(dr As IDataReader) As Generic.List(Of map)
            Return Linq.Enumerable.Range(0, dr.FieldCount).Select(Function(ord) New map With {.Ordinal = ord, .Name = dr.GetName(ord), .Type = dr.GetFieldType(ord).ToString}).ToList
        End Function

        Shared Function CreateFunction(dr As IDataReader) As Func(Of IDataRecord, PSObject)
            Dim expList = New List(Of Expression)
            Dim columns = map.CreateMappings(dr)

            Dim paramDR = Expression.Parameter(GetType(IDataRecord), "dr")
            Dim varPso = Expression.Variable(GetType(PSObject), "pso")
            expList.Add(Expression.Assign(varPso, Expression.[New](GetType(PSObject)))) 'Dim pso = New PSObject

            Dim psoProperties = Expression.Property(varPso, GetType(PSObject).GetProperty("Properties"))
            Dim methodPsoPropertiesAdd = GetType(PSMemberInfoCollection(Of PSPropertyInfo)).GetMethod("Add", {GetType(PSNoteProperty)})

            For Each col In columns
                Dim psnName = Expression.Constant(col.Name, GetType(String))
                Dim psnValue = Expression.Call(paramDR, GetType(IDataRecord).GetMethod("GetValue"), {Expression.Constant(col.Ordinal)})

                Dim noteProperty = Expression.[New](GetType(PSNoteProperty).GetConstructor({GetType(String), GetType(Object)}), {psnName, psnValue})
                expList.Add(Expression.Call(psoProperties, methodPsoPropertiesAdd, {noteProperty})) ' pso.Members.Add(New PSNoteProperty(col.Name, dr.GetValue(col.Ordinal))
            Next

            expList.Add(varPso) ' return pso
            Return Expression.Lambda(Of Func(Of IDataRecord, PSObject))(Expression.Block({varPso}, expList), paramDR).Compile
        End Function
    End Class

End Class
