# consider adding custom bulk implementation using array binding
# http://www.oracle.com/technetwork/issue-archive/2009/09-sep/o59odpnet-085168.html
Function MapDbType([string]$dbType) {
    Switch ($dbType){
        "System.Boolean" { "Int16" }
        "System.Byte" { "Byte" }
        "System.Byte[]" { "Raw" }
        "System.Datetime" { "TimeStamp" }
        "System.Decimal" { "Decimal" }
        "System.Double" { "Double" }
        "System.Float" { "Single" }
        "System.Single" { "Single" }
        "System.Int16" { "Int16" }
        "System.Int32" { "Int32" }
        "System.Int64" { "Int64" }
        "System.TimeSpan" { "IntervalDS" }
        default { "Varchar2" }        
    }
}

Class OracleProvider : ProviderBase {
    
    OracleProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [Oracle.ManagedDataAccess.Client.OracleConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection

        $messages = $this.Messages
        $handler = {Param($sender, [Oracle.ManagedDataAccess.Client.OracleInfoMessageEventArgs]$e)
            $messages.Enqueue(([SqlMessage]@{Received=(Get-Date); Message=$e.Message}))
        }.GetNewClosure()

        $this.Connection.add_InfoMessage([Oracle.ManagedDataAccess.Client.OracleInfoMessageEventHandler]$handler)
    }

    [string] ProviderType() { return "Oracle" }
    
    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ProviderType = $this.ProviderType()
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            HostName = $this.Connection.HostName
            ServiceName = $this.Connection.ServiceName
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.HasTransaction()
        }
    }

    [System.Data.IDbCommand] GetCommand([string]$Query, [int]$cmdTimeout, [hashtable]$Parameters) {
        If($cmdTimeout -lt 0) { $cmdTimeout = $this.CommandTimeout }
        $cmd = $this.Connection.CreateCommand()
        $cmd.BindByName = $true #otherwise oracle will bind by position!
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = $cmdTimeout
        if($this.HasTransaction()) { $cmd.Transaction = $this.Transaction } # apply transaction to command if connection has transaction
        
        ForEach($de in $Parameters.GetEnumerator()) {
            $param = $cmd.CreateParameter()
            $param.ParameterName = $de.Name
            If($de.Value -ne $null) { $param.Value = $de.Value }
            Else { $param.Value = [System.DBNull]::Value }
            $cmd.Parameters.Add($param)
        }
        
        Return $cmd
    }

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd, [Boolean]$ProviderTypes) {
        $ds = [System.Data.DataSet]::new()
        $da = [Oracle.ManagedDataAccess.Client.OracleDataAdapter]::new($cmd)
        if ($ProviderTypes) {
            $da.ReturnProviderSpecificTypes = $true
        }
        Try {
            $da.Fill($ds)
            return $ds 
        }
        Catch { Throw $_ }
        Finally { $da.dispose() }
    }

    [long] BulkLoad([System.Data.IDataReader]$DataReader
                    , [string]$DestinationTable
                    , [hashtable]$ColumnMap = @{}
                    , [int]$BatchSize
                    , [int]$BatchTimeout
                    , [ScriptBlock]$Notify) {

        $SchemaMap = @()
        [long]$batchIteration = 0
        
        $DataReader.GetSchemaTable().Rows | ForEach-Object { $SchemaMap += [PSCustomObject]@{Ordinal = $_["ColumnOrdinal"]; SrcName = $_["ColumnName"]; DestName = $_["ColumnName"]; DataType = $_["DataType"]}}

        If($ColumnMap -and $ColumnMap.Count -gt 0) {
            $SchemaMap = $SchemaMap |
                Where-Object SrcName -In $ColumnMap.Keys |
                ForEach-Object { $_.DestName = $ColumnMap[$_.SrcName]; $_ }
        }

        [string[]]$DestNames = $SchemaMap | Select-Object -ExpandProperty DestName
        [string]$InsertSql = 'INSERT INTO {0} ("{1}") VALUES (:Param{2})' -f $DestinationTable, ($DestNames -join '", "'), (($SchemaMap | ForEach-Object Ordinal) -join ", :Param")

        $bulkCmd = $this.GetCommand($InsertSql, -1, @{})
        Try {
            ForEach($sm in $SchemaMap) {
                $param = $bulkCmd.CreateParameter()
                $param.ParameterName = "Param{0}" -f $sm.Ordinal
                $param.OracleDbType = MapDbType -dbType $sm.DataType
                $bulkCmd.Parameters.Add($param) | Out-Null                
            }
            ForEach($sm in $SchemaMap) { $bulkCmd.Parameters[$sm.Ordinal].Value = @() }
            $bulkCmd.ArrayBindCount = $BatchSize
            
            While($DataReader.Read()) {
                $batchIteration += 1
                ForEach($sm in $SchemaMap) { $bulkCmd.Parameters[$sm.Ordinal].Value += $DataReader.GetValue($sm.Ordinal) }
                
                If($batchIteration % $BatchSize -eq 0) {
                    $null = $bulkCmd.ExecuteNonQuery()
                    If($Notify) { $Notify.Invoke($batchIteration) }
                    ForEach($sm in $SchemaMap) { $bulkCmd.Parameters[$sm.Ordinal].Value = @() }
                }
            }
            
            $r = $batchIteration % $BatchSize
            If($r -ne 0) {
                $bulkCmd.ArrayBindCount = $r
                $null = $bulkCmd.ExecuteNonQuery()
            }
        }
        Finally {
            $bulkCmd.Dispose()
            $DataReader.Close()
            $DataReader.Dispose()
        }
        Return $batchIteration
    }
}