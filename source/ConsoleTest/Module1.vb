Imports System.Linq.Expressions
Imports System.Management.Automation
Imports AgileObjects.ReadableExpressions
Imports EnumerableToDataReader


Module Module1

    Sub Main()
        'Dim fileDr = IO.Directory.GetFiles("c:\users\rober\").AsDataReader

        Dim expList = New List(Of Expression)

        'Dim paramDr = Expression.Parameter(GetType(IDataReader), "dr")
        Dim paramDr = Expression.Parameter(GetType(Integer), "dr")

        Dim varPso = Expression.Parameter(GetType(PSObject), "pso")
        'Dim psoProperties = Expression.Property(varPso, GetType(PSObject).GetProperty("Properties"))

        expList.Add(Expression.Assign(varPso, Expression.[New](GetType(PSObject))))

        expList.Add(Expression.Call(Nothing,
                                    GetType(Console).GetMethod("WriteLine", {GetType(String)}),
                                    Expression.Call(paramDr, GetType(Integer).GetMethod("ToString", {}))))
        expList.Add(varPso)
        Dim block = Expression.Block({varPso}, expList) ' note the first variable in the Block(), it instantiates variables in the scope.

        Dim lambda = Expression.Lambda(Of Func(Of Integer, PSObject))(block, paramDr)
        Console.WriteLine(lambda.ToReadableString)
        Console.WriteLine(lambda.Compile.Invoke(1).GetType.ToString)

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
