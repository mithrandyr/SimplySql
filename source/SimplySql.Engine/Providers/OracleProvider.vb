Imports System.Collections.Specialized
Imports System.ComponentModel
Imports System.Data
Imports Microsoft.Data.SqlClient
Imports NetTopologySuite.Algorithm
Imports System.Reflection
Imports Oracle.ManagedDataAccess.Client

Public Class OracleProvider
    Inherits ProviderBase

    Public Overloads ReadOnly Property Connection As OracleConnection
        Get
            Return DirectCast(MyBase.Connection, OracleConnection)
        End Get
    End Property

    Private Sub New(connName As String, timeout As Integer, conn As OracleConnection)
        MyBase.New(connName, ProviderTypes.Oracle, conn, timeout)

        AddHandler Me.Connection.InfoMessage, AddressOf HandleInfoMessage
    End Sub

    Public Overrides Function ConnectionInfo() As OrderedDictionary
        Dim od = MyBase.ConnectionInfo
        With od
            .Add("ServerVersion", Connection.ServerVersion)
            .Add("HostName", Connection.HostName)
            .Add("ServiceName", Connection.ServiceName)
            .Add("Privilege", Connection.Credential.DBAPrivilege)
            .Add("Database", Connection.Database)
        End With
        Return od
    End Function

    Public Overrides Sub ChangeDatabase(databaseName As String)
        Connection.ChangeDatabase(databaseName)
    End Sub

    Public Overrides Function GetDataset(query As String, cmdTimeout As Integer, params As Hashtable, useProviderTypes As Boolean) As DataSet
        If Not useProviderTypes Then
            Return MyBase.GetDataset(query, cmdTimeout, params, False)
        Else
            Using cmd As OracleCommand = GetCommand(query, cmdTimeout, params)
                Using da As New OracleDataAdapter(cmd)
                    Dim ds As New Data.DataSet
                    da.ReturnProviderSpecificTypes = True
                    Try
                        da.Fill(ds)
                        Return ds
                    Catch ex As Exception
                        ex.Data.Add("Query", query)
                        ex.Data.Add("Parameters", params)
                        Throw ex
                    End Try
                End Using
            End Using
        End If
    End Function

    Public Overrides Function BulkLoad(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Long)) As Long
        If Me.HasTransaction Then
            Return OracleArrayParam(dataReader, destinationTable, columnMap, batchSize, batchTimeout, notify)
        Else
            Return OracleBulkCopy(dataReader, destinationTable, columnMap, batchSize, batchTimeout, notify)
        End If
    End Function

    Private Function OracleBulkCopy(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Long)) As Long
        Using dataReader
            Using bcp As New OracleBulkCopy(Me.Connection) With {.BatchSize = batchSize, .BulkCopyTimeout = batchTimeout, .DestinationTableName = destinationTable}
                GenerateSchemaMap(dataReader, columnMap).ForEach(Sub(x) bcp.ColumnMappings.Add(x.SourceName, x.DestinationName))

                If notify IsNot Nothing Then
                    bcp.NotifyAfter = batchSize
                    AddHandler bcp.OracleRowsCopied, Sub(sender As Object, e As OracleRowsCopiedEventArgs) notify.Invoke(e.RowsCopied)
                End If

                bcp.WriteToServer(dataReader)
                Return RowsCopiedCount(bcp) 'using reflection to get an internal value... not ideal
            End Using
        End Using
    End Function
    Private Function OracleArrayParam(dataReader As IDataReader, destinationTable As String, columnMap As Hashtable, batchSize As Integer, batchTimeout As Integer, notify As Action(Of Long)) As Long
        Dim batchIteration As Long = 0
        Dim schemaMap = GenerateSchemaMap(dataReader, columnMap)
        Dim destColNames = """" + String.Join(""", """, schemaMap.Select(Function(x) x.DestinationName)) + """"
        Dim paramNames = ":Param" + String.Join(", :Param", schemaMap.Select(Function(x) x.Ordinal.ToString))

        Using dataReader
            Using bulkcmd As OracleCommand = GetCommand($"INSERT INTO {destinationTable} ({destColNames}) VALUES ({paramNames})")
                'adding parameters
                For Each sm In schemaMap
                    Dim p As New OracleParameter($"Param{sm.Ordinal}", MapOracleType(sm.DataType)) With {.Value = New ArrayList(batchSize)}
                    bulkcmd.Parameters.Add(p)
                Next

                bulkcmd.ArrayBindCount = batchSize

                While dataReader.Read
                    batchIteration += 1
                    For Each sm In schemaMap
                        DirectCast(bulkcmd.Parameters(sm.Ordinal).Value, ArrayList).Add(dataReader.GetValue(sm.Ordinal))
                    Next

                    If batchIteration Mod batchSize = 0 Then
                        bulkcmd.ExecuteNonQuery()
                        If notify IsNot Nothing Then notify.Invoke(batchIteration)
                        schemaMap.ForEach(Sub(sm) bulkcmd.Parameters(sm.Ordinal).Value = New ArrayList(batchSize))
                    End If
                End While

                Dim remaining = batchIteration Mod batchSize
                If remaining > 0 Then
                    bulkcmd.ArrayBindCount = remaining
                    bulkcmd.ExecuteNonQuery()
                    If notify IsNot Nothing Then notify.Invoke(batchIteration)
                End If
            End Using
        End Using
    End Function

    Private Function MapOracleType(netType As String) As OracleDbType
        'FROM: https://docs.oracle.com/en/database/oracle///oracle-database/23/odpnt/featOraCommand.html#GUID-BBEF52D9-E4E3-4A9C-93F5-3E408A83FC04
        Select Case netType.ToLower
            Case "system.boolean"
                Return OracleDbType.Boolean
            Case "system.byte"
                Return OracleDbType.Byte
            Case "system.byte[]"
                Return OracleDbType.Raw
            Case "system.datetime"
                Return OracleDbType.TimeStamp
            Case "system.datetimeoffset"
                Return OracleDbType.TimeStampTZ
            Case "system.decimal"
                Return OracleDbType.Decimal
            Case "system.double"
                Return OracleDbType.Double
            Case "system.float", "system.single"
                Return OracleDbType.Single
            Case "system.guid"
                Return OracleDbType.Blob
            Case "system.int16"
                Return OracleDbType.Int16
            Case "system.int32"
                Return OracleDbType.Int32
            Case "system.int64"
                Return OracleDbType.Int64
            Case "system.timespan"
                Return OracleDbType.IntervalDS
            Case Else
                Return OracleDbType.Varchar2
        End Select
    End Function

    Private Sub HandleInfoMessage(sender As Object, e As OracleInfoMessageEventArgs)
        Me.Messages.Enqueue(New SqlMessage(e.Message))
    End Sub
#Region "Shared"
    Private Shared _rowsCopiedField As FieldInfo
    Private Shared Function RowsCopiedCount(this As OracleBulkCopy) As Integer
        If _rowsCopiedField Is Nothing Then _rowsCopiedField = GetType(OracleBulkCopy).GetField("_rowsCopied", BindingFlags.NonPublic Or BindingFlags.GetField Or BindingFlags.Instance)
        Return DirectCast(_rowsCopiedField.GetValue(this), Integer)
    End Function
    Shared Sub New()
        OracleConfiguration.BindByName = True 'otherwise oracle commands will bind parameters by position
    End Sub
    Public Shared Function Create(connDetail As ConnectionOracle) As OracleProvider
        Dim sb As OracleConnectionStringBuilder
        Dim conn As OracleConnection
        If connDetail.HasConnectionString Then
            sb = New OracleConnectionStringBuilder(connDetail.ConnectionString)
        Else
            sb = New OracleConnectionStringBuilder()
            If connDetail.HasTnsName Then
                sb.DataSource = connDetail.TnsName
            Else
                sb.DataSource = $"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST={connDetail.Host})(PORT={connDetail.Port}))(CONNECT_DATA=(SERVICE_NAME={connDetail.ServiceName})))"
            End If
        End If

        If connDetail.UseIntegratedSecurity Then
            sb.UserID = "/"
            sb.DBAPrivilege = ConvertToOracleDBAPrivilege(connDetail.Privilege)
            conn = New OracleConnection(sb.ConnectionString)
        Else
            conn = New OracleConnection(sb.ConnectionString, New OracleCredential(connDetail.UserName, connDetail.SecurePassword, ConvertToOracleDBAPrivilege(connDetail.Privilege)))
        End If

        Return New OracleProvider(connDetail.ConnectionName, connDetail.CommandTimeout, conn)
    End Function
    Private Shared Function ConvertToOracleDBAPrivilege(priv As ConnectionOracle.OraclePrivilege) As OracleDBAPrivilege
        Select Case priv
            Case ConnectionOracle.OraclePrivilege.None
                Return OracleDBAPrivilege.None
            Case ConnectionOracle.OraclePrivilege.SYSDBA
                Return OracleDBAPrivilege.SYSDBA
            Case ConnectionOracle.OraclePrivilege.SYSOPER
                Return OracleDBAPrivilege.SYSOPER
            Case ConnectionOracle.OraclePrivilege.SYSASM
                Return OracleDBAPrivilege.SYSASM
            Case Else
                Throw New InvalidEnumArgumentException(NameOf(priv), priv, GetType(OracleDBAPrivilege))
        End Select
    End Function
#End Region
End Class
