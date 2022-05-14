Class MySqlProvider : ProviderBase {
    
    MySqlProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [MySql.Data.MySqlClient.MySqlConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection

        $messages = $this.Messages
        $handler = {Param($sender, [MySql.Data.MySqlClient.MySqlInfoMessageEventArgs]$e)
            $messages.Enqueue(([SqlMessage]@{Received=(Get-Date); Message=$e.Message}))
        }.GetNewClosure()

        $this.Connection.add_InfoMessage([MySql.Data.MySqlClient.MySqlInfoMessageEventHandler]$handler)
    }

    [string] ProviderType() { return "MySql" }
    
    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ProviderType = $this.ProviderType()
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            DataSource = $this.Connection.DataSource
            Database = $this.Connection.Database
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.HasTransaction()
        }
    }

    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd, [Boolean]$ProviderTypes) {
        $ds = [System.Data.DataSet]::new()
        $da = [MySql.Data.MySqlClient.MySqlDataAdapter]::new($cmd)
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

    [void] ChangeDatabase([string]$DatabaseName) { $this.Connection.ChangeDatabase($DatabaseName) }

    [long] BulkLoad([System.Data.IDataReader]$DataReader
                    , [string]$DestinationTable
                    , [hashtable]$ColumnMap = @{}
                    , [int]$BatchSize
                    , [int]$BatchTimeout
                    , [ScriptBlock]$Notify) {

        $BatchSize -= $BatchSize % 10
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
        [string]$ValueSql = (1..10 | ForEach-Object { "(@Param" + (($SchemaMap | ForEach-Object Ordinal) -join ("_{0}, @Param" -f $_)) + ("_{0})" -f $_) }) -join ", "
        [string]$InsertSql = 'INSERT INTO {0} (`{1}`) VALUES {2}' -f $DestinationTable, ($DestNames -join '`, `'), $ValueSql

        $bulkCmd = $this.GetCommand($InsertSql, -1, @{})
        $bulkCmd.Prepare()
        Try {
            $bulkCmd.Transaction = $this.Connection.BeginTransaction()
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            While($DataReader.Read()) {                
                $batchIteration += 1
                $r = $batchIteration % 10
                If($r -eq 0) { $r = 10 }
                If($batchIteration -le 10) {
                    $SchemaMap.ForEach({
                        $p = 'Param{0}_{1}' -f $_.Ordinal, $r
                        $bulkCmd.Parameters.AddWithValue($p, $DataReader.GetValue($_.Ordinal))
                    })
                }
                Else {
                    $SchemaMap.ForEach({
                        $p = 'Param{0}_{1}' -f $_.Ordinal, $r
                        $bulkCmd.Parameters[$p].Value = $DataReader.GetValue($_.Ordinal)
                    })
                }

                If($r -eq 10) { $null = $bulkCmd.ExecuteNonQuery() }
                If($sw.Elapsed.TotalSeconds -gt $BatchTimeout) { Throw [System.TimeoutException]::new(("Batch took longer than {0} seconds to complete." -f $BatchTimeout)) }
                
                If($batchIteration % $BatchSize -eq 0) {
                    $bulkCmd.Transaction.Commit()
                    $bulkCmd.Transaction.Dispose()
                    If($Notify) { $Notify.Invoke($batchIteration) }
                    $bulkCmd.Transaction = $this.Connection.BeginTransaction()
                    $sw.Restart()
                }
            }
            $r = $batchIteration % 10
            If($r -eq 0) { $r = 10 }
            If($r -ne 10) {
                [string]$ValueSql = ((1..$r) | ForEach-Object { "(@Param" + (($SchemaMap | ForEach-Object Ordinal) -join ("_{0}, @Param" -f $_)) + ("_{0})" -f $_) }) -join ", "
                [string]$InsertSql = 'INSERT INTO {0} (`{1}`) VALUES {2}' -f $DestinationTable, ($DestNames -join '`, `'), $ValueSql
                $bulkCmd.CommandText = $InsertSql
                $bulkCmd.Prepare()
                [int]$mr = $r * $SchemaMap.Count
                While($bulkCmd.Parameters.Count -gt $mr){ $null = $bulkCmd.Parameters.RemoveAt($mr) }
                $null = $bulkCmd.ExecuteNonQuery()
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
}