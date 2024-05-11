---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Open-MySqlConnection

## SYNOPSIS
Open a connection to a MySql Database.

## SYNTAX

### default (Default)
```
Open-MySqlConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-Database] <String>] [-Port <Int32>] [-SSLMode <String>] [[-Credential] <PSCredential>]
 [-Additional <Hashtable>] [<CommonParameters>]
```

### conn
```
Open-MySqlConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Credential] <PSCredential>]
 -ConnectionString <String> [<CommonParameters>]
```

## DESCRIPTION
Open a connection to a MySql Database.
        
MySqlConnector: High Performance .NET MySQL Driver @ https://mysqlconnector.net/
.NET Provider @ https://www.nuget.org/packages/MySqlConnector/

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Additional
Hashtable to provide additional connection parameters.

```yaml
Type: Hashtable
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CommandTimeout
The default command timeout to be used for all commands executed against this connection.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 30
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectionName
User defined name for connection.

```yaml
Type: String
Parameter Sets: (All)
Aliases: cn

Required: False
Position: Named
Default value: default
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConnectionString
Specifies a provider specific connectionstring to be used.

```yaml
Type: String
Parameter Sets: conn
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
A PSCredential object providing the proper credentials to access to the datasource (if required).

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Database
Database name.

```yaml
Type: String
Parameter Sets: default
Aliases: InitialCatalog

Required: False
Position: 1
Default value: mysql
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Port
Port to connect on, if different from default (3306).

```yaml
Type: Int32
Parameter Sets: default
Aliases:

Required: False
Position: Named
Default value: 3306
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
The Server for the connection.

```yaml
Type: String
Parameter Sets: default
Aliases: Host

Required: False
Position: 0
Default value: localhost
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SSLMode
Which SLLMode to use (defaults to Preferred)
Disabled: (equivalent to 'None') Do not use SSL.
Preferred: Use SSL if the server supports it.
Required: Always use SSL. Deny connection if server does not support SSL. Does not validate CA or hostname.
VerifyCA: Always use SSL. Validates the CA but tolerates hostname mismatch.
VerifyFull: Always use SSL. Validates CA and hostname.

```yaml
Type: String
Parameter Sets: default
Aliases:
Accepted values: Disabled, Preferred, Required, VerifyCA, VerifyFull

Required: False
Position: Named
Default value: Preferred
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Int32
### SimplySql.Common.SslMode
### System.Management.Automation.PSCredential
### System.Collections.Hashtable
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
