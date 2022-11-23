Imports System.Linq.Expressions
Imports System.Management.Automation
Imports System.Management.Automation.Language
Imports AgileObjects.ReadableExpressions
Imports EnumerableToDataReader


Module Module1

    Sub Main()
        Dim fileDr = (New IO.DirectoryInfo(Environment.CurrentDirectory)).GetFiles.AsDataReader

        Dim expList = New List(Of Expression)

        Dim paramDr = Expression.Parameter(GetType(IDataRecord), "dr")
        Dim varPso = Expression.Parameter(GetType(PSObject), "pso")
        expList.Add(Expression.Assign(varPso, Expression.[New](GetType(PSObject))))

        Dim psoProperties = Expression.Property(varPso, GetType(PSObject).GetProperty("Properties"))
        Dim methodPsoPropertiesAdd = GetType(PSMemberInfoCollection(Of PSPropertyInfo)).GetMethod("Add", {GetType(PSNoteProperty), GetType(Boolean)})

        For Each columnOrdinal In Enumerable.Range(0, fileDr.FieldCount - 1)
            Dim psnName = Expression.Constant(fileDr.GetName(columnOrdinal))
            'GetType(IDataRecord).GetMethod("GetValue")
            Dim psnValue = Expression.Call(paramDr, GetType(IDataRecord).GetMethod("GetValue"), {Expression.Constant(columnOrdinal)})

            Dim noteProperty = Expression.[New](GetType(PSNoteProperty).GetConstructor({GetType(String), GetType(Object)}), {psnName, psnValue})
            expList.Add(Expression.Call(psoProperties, methodPsoPropertiesAdd, {noteProperty, Expression.Constant(True)}))
        Next

        expList.Add(varPso)
        Dim block = Expression.Block({varPso}, expList) ' note the first variable in the Block(), it instantiates variables in the scope.

        Dim lambda = Expression.Lambda(Of Func(Of IDataRecord, PSObject))(block, paramDr)
        Console.WriteLine(lambda.ToReadableString)
        'Console.WriteLine(lambda.Compile.Invoke(15).GetType.ToString)

        Console.WriteLine("enter to exit")
        Console.ReadLine()
    End Sub

    Private Sub old()
        Dim value As ParameterExpression =
    Expression.Parameter(GetType(Integer), "value")

        ' Creating an expression to hold a local variable.
        Dim result As ParameterExpression =
    Expression.Parameter(GetType(Integer), "result")

        ' Creating a label to jump to from a loop.  
        Dim label As LabelTarget = Expression.Label(GetType(Integer))

        ' Creating a method body.  
        Dim block As BlockExpression = Expression.Block(
                New ParameterExpression() {result},
                Expression.Assign(result, Expression.Constant(1)),
                Expression.Loop(
                    Expression.IfThenElse(
                        Expression.GreaterThan(value, Expression.Constant(1)),
                        Expression.MultiplyAssign(result,
                            Expression.PostDecrementAssign(value)),
                        Expression.Break(label, result)
                    ),
                    label
                )
            )

    End Sub

End Module
