Imports System.Data
Imports System.Linq.Expressions
Imports EnumerableToDataReader
Imports SimplySql.Cmdlets.DataReaderToPSObject
Imports AgileObjects.ReadableExpressions

<Cmdlet("Test", "Greeting")>
Public Class test
    Inherits PSCmdlet

    <Parameter(ValueFromPipeline:=True, Position:=0)>
    Public Property Name As String
    <Parameter()>
    Public Property ThrowError As SwitchParameter
    <Parameter()>
    Public Property ThrowErrorTerm As SwitchParameter
    <Parameter()>
    Public Property Path As String

    <Parameter(ValueFromPipeline:=True)>
    Public ObjectToHash As PSObject

    Protected Overrides Sub ProcessRecord()
        If ThrowError.IsPresent Then
            WriteError(New ErrorRecord(New Exception("throwing an error"), Nothing, Nothing, Nothing))
            'use this and then exit if you want it to processing to stop
        End If

        If ObjectToHash IsNot Nothing Then
            WriteObject(ObjectToHash.ConvertToHashtable)
            Exit Sub
        End If

        If Not String.IsNullOrWhiteSpace(Path) Then
            WriteObject($"Path: {Path}")
            WriteObject($"Processed: {Me.GetUnresolvedProviderPathFromPSPath(Path)}")
        End If
        WriteObject(Engine.Test.Greet(Name))
    End Sub

End Class

<Cmdlet("Test", "SimplySql")>
Public Class testSimplySql
    Inherits PSCmdlet

    <Parameter(ValueFromPipeline:=True)>
    Public Property Item As PSObject()

    Private itemList As New List(Of PSObject)

    Protected Overrides Sub ProcessRecord()
        If Item IsNot Nothing Then itemList.AddRange(Item)
    End Sub

    Protected Overrides Sub EndProcessing()
        Dim dr As IDataReader = itemList.AsDataReader

        Dim expList = New List(Of Expression)
        Dim columns = map.CreateMappings(dr)

        Dim paramDataReader = Expression.Parameter(GetType(IDataReader), "dr")
        Dim varPso = Expression.Variable(GetType(PSObject), "pso")
        Dim psoProperties = Expression.Property(varPso, GetType(PSObject).GetProperty("Properties"))

        expList.Add(Expression.Assign(varPso, Expression.[New](GetType(PSObject))))

        Dim drGetExp As Reflection.MethodInfo
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
            'Dim drGetValue = Expression.Call(paramDataReader, "GetValue", paramOrd)
            'Dim newPSNote = Expression.[New](GetType(PSNoteProperty).GetConstructor({GetType(String), GetType(Object)}), {paramName, drGetValue})
            'expList.Add(Expression.Call(psoProperties, GetType(PSMemberInfoCollection(Of PSPropertyInfo)).GetMethod("Add"), newPSNote))
        Next
        'expList.Add(Expression.Return())

        Dim lambda = Expression.Lambda(Of Func(Of IDataReader, PSObject))(Expression.Block(expList), paramDataReader)


        WriteObject(lambda.ToReadableString)
    End Sub
End Class



