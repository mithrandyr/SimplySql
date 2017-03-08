Class ProviderBase {
    [string]$ConnectionName
    [int]$CommandTimeout = 30
    [System.Data.IDbConnection]$Connection
    [System.Data.IDbTransaction]$Transaction
    [System.Collections.Generic.Queue[SqlMessage]]$Messages = (New-Object 'System.Collections.Generic.Queue[SqlMessage]')

    ProviderBase() { If($this.GetType().Name -eq "ProviderBase") { Throw [System.InvalidOperationException]::new("ProviderBase must be inherited!") } }
    
    [PSCustomObject] ConnectionInfo() { Throw [System.NotImplementedException]::new("ProviderBase.ConnectionInfo must be overloaded!") }

    [System.Data.IDbCommand] GetCommand([string]$Query, [int]$cmdTimeout, [hashtable]$Parameters = @{}) {
        If($cmdTimeout -lt 0) { $cmdTimeout = $this.CommandTimeout }
        $cmd = $this.Connection.CreateCommand()
        $cmd.CommandText = $Query
        $cmd.CommandTimeout = $cmdTimeout
        ForEach($de in $Parameters.GetEnumerator()) {
            $cmd.Parameters.Add($this.CreateParameter($de.Key, $de.Value))
        }
        Return $cmd
    }

    [System.Data.IDbCommand] GetCommand([string]$Query, [hashtable]$Parameters = @{}) {
        Return $this.GetCommand($Query, $this.CommandTimeout, $Parameters)
    }

    [System.Data.IDataParameter] CreateParameter([String]$Name, $Value) { Throw [System.NotImplementedException]::new("ProviderBase.CreateParameter must be overloaded!") }
    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd) { Throw [System.NotImplementedException]::new("ProviderBase.GetDataSet must be overloaded!") }
    
    [long] BulkLoad([System.Data.IDataReader]$DataReader
                    , [string]$DestinationTable
                    , [hashtable]$ColumnMap
                    , [int]$BatchSize
                    , [int]$BatchTimeout
                    , [ScriptBlock]$Notify) {
        Throw [System.NotImplementedException]::new("ProviderBase.BulkLoad must be overloaded!")
    }

    [SqlMessage] GetMessage() { Return $this.Messages.Dequeue() }
    [Void] ClearMessages() { $this.Messages.Clear() }
    [bool] HasMessages() { Return $this.Messages.Count -gt 0 }

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
        Else { Throw [System.InvalidOperationException]::new("Cannot ROLLBACK when there is no transaction in progress." }
    }

    [void] CommitTransaction() {
        If($this.Transaction) {
            $this.Transaction.Commit()
            $this.Transaction.Dispose()
            $this.Transaction = $null
        }
        Else { Throw [System.InvalidOperationException]::new("Cannot COMMIT when there is no transaction in progress." }
    }

    [void] AttachCommand([System.Data.IDbCommand]$Command) {
        $Command.Connection = $this.Connection
        If($this.Transaction) { $Command.Transaction = $this.Transaction }
    }

    static [System.Data.IDbConnection] CreateConnection([hashtable]$ht) {
        Throw [System.NotImplementedException]::new("ProviderBase.CreateConnection must be overloaded!")
    }
}