#Load Up Oracle libraries
Add-Type -Path "$PSScriptRoot\Oracle.ManagedDataAccess.dll"

#Provider Class
. "$PSScriptRoot\provider.ps1"

#Open Cmdlet
Function Open-OracleConnection {
    <#
    .Synopsis
        Open a connection to a Oracle Database.

    .Description
        Open a connection to a Oracle Database.
        
        Oracle (Oracle.ManagedDataAccess)
        Oracle Managed Data Access @ http://www.oracle.com/technetwork/topics/dotnet/index-085163.html
        Provider for .NET @ https://www.nuget.org/packages/Oracle.ManagedDataAccess/

    .Parameter ConnectionName
        The name to associate with the newly created connection.
        This connection will be used with other cmdlets when specifying
        -ConnectionName <name>.  If you don't specify one, it will be
        set to the default.

    .Parameter ConnectionString
        Specifies a provider specific connectionstring to be used.

    .Parameter CommandTimeout
        The default command timeout to be used for all commands executed against this connection.

    .Parameter DataSource
        The datasource for the connection.

    .Parameter ServiceName
        Oracle ServiceName (SID).

    .Parameter Port
        Port to connect on, defaults to 1521.

    .Parameter UserName
        User to authenticate as.

    .Parameter Password
        Password for the user.
    
    .Parameter DBPrivilege
        Specify either SYSOPER or SYSDBA.

    #>
    [CmdletBinding(DefaultParameterSetName="default")]
    Param([Parameter(ValueFromPipelineByPropertyName)][Alias("cn")][string]$ConnectionName = "default"
        , [Parameter(ValueFromPipelineByPropertyName)][int]$CommandTimeout = 30
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default", Position=0)]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass", Position=0)]
            [string]$DataSource = "localhost"
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="default", Position=1)]
            [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="userpass", Position=1)]
            [string]$ServiceName
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass")]
            [int]$Port = 1521
        , [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="default")]
            [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="userpass")]
            [ValidateSet("SYSOPER","SYSDBA")][string]$DBAPrivilege
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="default")][pscredential]$Credential
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="userpass")][string]$UserName
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="userpass")][string]$Password
        , [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="Conn")][string]$ConnectionString)

    If($Script:Connections.ContainsKey($ConnectionName)) { Close-SqlConnection $ConnectionName }
    
    $sb = [Oracle.ManagedDataAccess.Client.OracleConnectionStringBuilder]::new()
    
    If($PSCmdlet.ParameterSetName -eq "Conn") { $conn = [Oracle.ManagedDataAccess.Client.OracleConnection]::new($ConnectionString) }
    Else {
        $sb["Data Source"] = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST={0})(PORT={1}))(CONNECT_DATA=(SERVICE_NAME={2})))" -f $DataSource, $Port, $ServiceName
        $sb["Statement Cache Size"] = 5
        
        if($DBAPrivilege) { $sb["DBA Privilege"] = $DBAPrivilege.ToLower() }
        
        If($Credential) {
            $secPwd = $Credential.Password
            $secPwd.MakeReadOnly()
            $oracleCred = [Oracle.ManagedDataAccess.Client.OracleCredential]::new($Credential.UserName, $secPwd)
            $conn = [Oracle.ManagedDataAccess.Client.OracleConnection]::new($sb.ConnectionString, $oracleCred)
        }
        Else {
            Write-Warning "You are using -UserName and -Password, these options are deprecated and will be removed in the future.  Please consider using -Credential."
            $sb["User Id"] = $UserName
            $sb.Password = $Password
            $conn = [Oracle.ManagedDataAccess.Client.OracleConnection]::new($sb.ConnectionString)
        }
        $sb.Clear()
        $sb = $null
        Remove-Variable sb
    }

    Try { $conn.Open() }
    Catch {
        $conn.Dispose()
        Throw $_
    }
    $Script:Connections.$ConnectionName = [OracleProvider]::new($ConnectionName, $CommandTimeout, $conn)
}

Export-ModuleMember -Function Open-OracleConnection