Imports System.Data
Imports System.Linq.Expressions
Imports EnumerableToDataReader
Imports SimplySql.Cmdlets.DataReaderToPSObject
Imports AgileObjects.ReadableExpressions
Imports System.Reflection

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

    Private itemList As New List(Of Object)

    Protected Overrides Sub ProcessRecord()
        If Item IsNot Nothing Then
            itemList.AddRange(Item.Select(Function(i) i.BaseObject))
        End If
    End Sub

    Protected Overrides Sub EndProcessing()
        If itemList.Count = 0 Then Exit Sub
        Dim convertType = itemList(0).GetType
        Dim dr As IDataReader = itemList.AsDataReader(convertType)

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
        Dim lambda = Expression.Lambda(Of Func(Of IDataRecord, PSObject))(Expression.Block({varPso}, expList), paramDR)
        WriteVerbose(lambda.ToReadableString)
        Dim converter = lambda.Compile

        While dr.Read
            WriteObject(converter(dr))
        End While
    End Sub
End Class



