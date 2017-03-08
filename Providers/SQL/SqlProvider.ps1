Class SQLProvider : ProviderBase {
    
    SQLProvider([string]$ConnectionName
                , [int]$CommandTimeout
                , [System.Data.SqlClient.SqlConnection]$Connection) {

        $this.ConnectionName = $ConnectionName
        $this.CommandTimeout = $CommandTimeout
        $this.Connection = $Connection

        $this.Connection.add_InfoMessage({Param($sender, [System.Data.SqlClient.SqlInfoMessageEventArgs]$e)
            $this.Messages.Enqueue(([SqlMessage]@{Generated=(Get-Date); Message=$e.Message}))
        })
    }

    [PSCustomObject] ConnectionInfo() {
        return [PSCustomObject]@{
            ConnectionName = $this.ConnectionName
            ConnectionType = "MSSQL"
            ConnectionState = $this.Connection.State
            ConnectionString = $this.Connection.ConnectionString
            ServerVersion = $this.Connection.ServerVersion
            Database = $this.Connection.Database
            CommandTimeout = $this.CommandTimeout
            HasTransaction = $this.Transaction -ne $null
        }
    }

    [System.Data.IDataParameter] CreateParameter([String]$Name, $Value) {
        If($Value) { Return [System.Data.SqlClient.SqlParameter]::new($name, $Value) }
        Else { Return [System.Data.SqlClient.SqlParameter]::new($name, [System.DBNull]::Value) }
    }
    
    [System.Data.DataSet] GetDataSet([System.Data.IDbCommand]$cmd) {
        $ds = [System.Data.DataSet]::new()
        $da = [System.Data.SqlClient.SqlDataAdapter]::new($cmd)
        Try { $da.Fill($ds) }
        Finally { If($da -ne $null) { $da.dispose() } }
        
        Return $ds
    }

    [long] BulkLoad([System.Data.IDataReader]$DataReader
                    , [string]$DestinationTable
                    , [hashtable]$ColumnMap
                    , [int]$BatchSize
                    , [int]$BatchTimeout
                    , [ScriptBlock]$Notify) {
        
        #NOT IMPLEMENTED
        return 0
    }

    static [System.Data.IDbConnection] CreateConnection([hashtable]$ht) {
        If($ht.ParameterSetName -notin @("Default", "Conn", "user", "cred")) {
            Throw [System.InvalidOperationException]::new("Invalid ParameterSet passed to CreateConnection")
        }
        
        $sb = [System.Data.SqlClient.SqlConnectionStringBuilder]::new()
        
        If($ht.ContainsKey("ConnectionString")) { $sb["Connection String"] = $ht.ConnectionString }
        Else {
            If($ht.ContainsKey("DataSource")) { $sb.Server = $ht.DataSource }
            If($ht.ContainsKey("InitialCatalog")) { $sb.Database = $ht.InitialCatalog }
            If($ht.ContainsKey("User")) { $sb["User Id"] = $ht.User }
            If($ht.ContainsKey("Password")) { $sb.Password = $ht.Password }
        }        
        
        $sb["Application Name"] = "PowerShell"
        
        If($ht.ContainsKey("Credential")) {
            [securestring]$sqlCred = $ht.Credential.Password.Copy()
            $sqlCred.MakeReadOnly()

            return [System.Data.SqlClient.SqlConnection]::new($sb.ConnectionString, [System.Data.SqlClient.SqlCredential]::new($ht.Credential.UserName, $sqlCred))
        }
        Else { return [System.Data.SqlClient.SqlConnection]::new($sb.ConnectionString) }
    }
}