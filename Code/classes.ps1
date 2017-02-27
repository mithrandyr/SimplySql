Class SqlMap {
    [int]$Ordinal
    [string]$Name
    [bool]$AllowNull
    [type]$DataType
    [string]$MappedName
}

Class SqlMessage { [datetime]$Generated; [string]$Message }

Class ProviderConfig {
    [string]$ShortDescription
    [string]$HelpText
    [scriptblock]$CreateProvider
    [System.Management.Automation.RuntimeDefinedParameterDictionary]$Parameters = (New-Object System.Management.Automation.RuntimeDefinedParameterDictionary)
}

Class ProviderBase {
    [string]$ConnectionName
    [int]$CommandTimeout = 30
    [System.Data.IDbConnection]$Connection
    #[string]$ProviderName
    [System.Collections.Generic.Queue[SqlMessage]]$Messages = (New-Object 'System.Collections.Generic.Queue[SqlMessage]')

    ProviderBase([string]$ConnectionName, [int]$CommandTimeout, [System.Data.IDbConnection]$Connection) {
        If($this.GetType().Name -eq "Parent") { Throw [System.InvalidOperationException]::new("ProviderBase must be inherited!") }
        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection
    }
    
    [PSCustomObject] ConnectionInfo() { Throw [System.NotImplementedException]::new("ProviderBase.ConnectionInfo must be overloaded!") }

    [System.Data.IDbCommand] GetCommand([string]$Query, [int]$CommandTimeout, [hashtable]$Parameters = @{}) {
         Throw [System.NotImplementedException]::new("ProviderBase.GetCommand(Query, CommandTimeout, Parameters) must be overloaded!") 
    }

    [System.Data.IDbCommand] GetCommand([string]$Query, [hashtable]$Parameters = @{}) {
        Return $this.GetCommand($Query, $this.CommandTimeout, $Parameters)
    }

    [System.Data.IDataParameter] GetParameter() { Throw [System.NotImplementedException]::new("ProviderBase.GetParameter must be overloaded!") }
    [System.Data.DataSet] GetDataSet() { Throw [System.NotImplementedException]::new("ProviderBase.GetDataSet must be overloaded!") }
    
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

    [void] BeginTransaction() { Throw [System.NotImplementedException]::new("ProviderBase.BeginTransaction must be overloaded!") }
    [void] RollbackTransaction() { Throw [System.NotImplementedException]::new("ProviderBase.RollbackTransaction must be overloaded!") }
    [void] CommitTransaction() { Throw [System.NotImplementedException]::new("ProviderBase.CommitTransaction must be overloaded!") }
    [void] AttachTransaction([System.Data.IDbCommand]$Command) { Throw [System.NotImplementedException]::new("ProviderBase.AttachTransaction must be overloaded!") }

}