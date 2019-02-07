Class SqlMessage { [datetime]$Received; [string]$Message }

Class ProviderBase {
    [string]$ConnectionName
    [int]$CommandTimeout = 30
    [System.Data.IDbConnection]$Connection
    [System.Data.IDbTransaction]$Transaction
    [System.Collections.Generic.Queue[SqlMessage]]$Messages = (New-Object 'System.Collections.Generic.Queue[SqlMessage]')

    ProviderBase() { If($this.GetType().Name -eq "ProviderBase") { Throw [System.InvalidOperationException]::new("ProviderBase must be inherited!") } }
    
    [PSCustomObject] ConnectionInfo() { Throw [System.NotImplementedException]::new("ProviderBase.ConnectionInfo must be overloaded!") }

    [void] ChangeDatabase([string]$DatabaseName) { Throw [System.NotImplementedException]::new("ProviderBase.ChangeDatabase must be overloaded!") }

    [string] ProviderType() { Throw [System.NotImplementedException]::new("ProviderBase.ProviderType must be overloaded!") }

    [System.Data.IDbCommand] GetCommand([string]$Query, [int]$cmdTimeout, [hashtable]$Parameters) {
        If($cmdTimeout -lt 0) { $cmdTimeout = $this.CommandTimeout }
        $cmd = $this.Connection.CreateCommand()
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

    [System.Object] GetScalar([string]$Query, [int]$cmdTimeout, [hashtable]$Parameters) {
        $cmd = $this.GetCommand($Query, $cmdTimeout, $Parameters)
        Try { return $cmd.ExecuteScalar() }
        Catch { Throw $_ }
        Finally { $cmd.Dispose() }
    }

    [System.Data.IDataReader] GetReader([string]$Query, [int]$cmdTimeout, [hashtable]$Parameters) {
        Return $this.GetCommand($Query, $cmdTimeout, $Parameters).ExecuteReader()
    }

    [long] Update([string]$Query, [int]$cmdTimeout, [hashtable]$Parameters) {
        $cmd = $this.GetCommand($Query, $cmdTimeout, $Parameters)
        Try { return $cmd.ExecuteNonQuery() }
        Catch { Throw $_ }
        Finally { $cmd.Dispose() }
    }
    
    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd, [Boolean]$ProviderTypes) { Throw [System.NotImplementedException]::new("ProviderBase.GetDataSet must be overloaded!") }
    
    [long] BulkLoad([System.Data.IDataReader]$DataReader
                    , [string]$DestinationTable
                    , [hashtable]$ColumnMap = @{}
                    , [int]$BatchSize
                    , [int]$BatchTimeout
                    , [ScriptBlock]$Notify) {

        $SchemaMap = @()
        [long]$batchIteration = 0
        [int]$ord = 0
        $DataReader.GetSchemaTable().Rows | Sort-Object ColumnOrdinal | ForEach-Object { $SchemaMap += [PSCustomObject]@{Ordinal = $ord; SrcName = $_["ColumnName"]; DestName = $_["ColumnName"]}; $ord += 1}

        If($ColumnMap -and $ColumnMap.Count -gt 0) {
            $SchemaMap = $SchemaMap |
                Where-Object SrcName -In $ColumnMap.Keys |
                ForEach-Object { $_.DestName = $ColumnMap[$_.SrcName]; $_ }
        }

        [string[]]$DestNames = $SchemaMap | Select-Object -ExpandProperty DestName
        [string]$InsertSql = "INSERT INTO {0} ([{1}]) VALUES (@Param{2})" -f $DestinationTable, ($DestNames -join "], ["), (($SchemaMap | ForEach-Object Ordinal) -join ", @Param")

        $bulkCmd = $this.GetCommand($InsertSql, -1, @{})
        Try {
            $bulkCmd.Transaction = $this.Connection.BeginTransaction()
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            [bool]$hasPrepared = $false
            While($DataReader.Read()) {
                
                If(-not $hasPrepared) {
                    ForEach($sm in $SchemaMap) {
                        $param = $bulkCmd.CreateParameter()
                        $param.ParameterName = "Param{0}" -f $sm.Ordinal
                        $param.Value = $DataReader.GetValue($sm.Ordinal)
                        $bulkCmd.Parameters.Add($param) | Out-Null
                    }
                    $bulkCmd.Prepare()
                    $hasPrepared = $true
                }
                Else { ForEach($sm in $SchemaMap) { $bulkCmd.Parameters[$sm.Ordinal].Value = $DataReader.GetValue($sm.Ordinal) } }
                
                $batchIteration += 1
                $null = $bulkCmd.ExecuteNonQuery()
                
                If($sw.Elapsed.TotalSeconds -gt $BatchTimeout) { Throw [System.TimeoutException]::new(("Batch took longer than {0} seconds to complete." -f $BatchTimeout)) }
                If($batchIteration % $BatchSize -eq 0) {
                    $bulkCmd.Transaction.Commit()
                    $bulkCmd.Transaction.Dispose()
                    If($Notify) { $Notify.Invoke($batchIteration) }
                    $bulkCmd.Transaction = $this.Connection.BeginTransaction()
                    $sw.Restart()
                }
            }
            $bulkCmd.Transaction.Commit()
            $bulkCmd.Transaction.Dispose()
            $bulkCmd.Transaction = $null
        }
        Finally {
            If($bulkCmd.Transaction) { $bulkCmd.Transaction.Dispose() }
            $bulkCmd.Dispose()
            $DataReader.Close()
            $DataReader.Dispose()
        }
        Return $batchIteration
    }

    [SqlMessage] GetMessage() { Return $this.Messages.Dequeue() }
    [Void] ClearMessages() { $this.Messages.Clear() }
    [bool] HasMessages() { Return $this.Messages.Count -gt 0 }
    [bool] HasTransaction() { Return $this.Transaction -ne $null }

    [void] BeginTransaction() { 
        If($this.Transaction) { Throw [System.InvalidOperationException]::new("Cannot BEGIN a transaction when one is already in progress.") }
        $this.Transaction = $this.Connection.BeginTransaction()
    }

    [void] RollbackTransaction() {
        If($this.Transaction) {
            $this.Transaction.Rollback()
            $this.Transaction.Dispose()
            $this.Transaction = $null
        }
        Else { Throw [System.InvalidOperationException]::new("Cannot ROLLBACK when there is no transaction in progress.") }
    }

    [void] CommitTransaction() {
        If($this.Transaction) {
            $this.Transaction.Commit()
            $this.Transaction.Dispose()
            $this.Transaction = $null
        }
        Else { Throw [System.InvalidOperationException]::new("Cannot COMMIT when there is no transaction in progress.") }
    }

    [void] AttachCommand([System.Data.IDbCommand]$Command) {
        $Command.Connection = $this.Connection
        If($this.Transaction) { $Command.Transaction = $this.Transaction }
    }

    static [System.Data.IDbConnection] CreateConnection([hashtable]$ht) {
        Throw [System.NotImplementedException]::new("ProviderBase.CreateConnection must be overloaded!")
    }
}