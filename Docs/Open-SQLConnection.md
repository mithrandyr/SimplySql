---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Open-SQLConnection

## SYNOPSIS
Open a connection to a SQL Server.

## SYNTAX

### default (Default)
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-Database] <String>] [-Additional <Hashtable>] [<CommonParameters>]
```

### credential
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-Database] <String>] [[-Credential] <PSCredential>] [-AzureAD] [-Additional <Hashtable>]
 [<CommonParameters>]
```

### token
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Server] <String>]
 [[-Database] <String>] [-AzureToken <String>] [-Additional <Hashtable>] [<CommonParameters>]
```

### conn
```
Open-SQLConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-Credential] <PSCredential>]
 [-AzureToken <String>] -ConnectionString <String> [<CommonParameters>]
```

## DESCRIPTION
Open a connection to a SQL Server.  Default authentication is Integrated Windows Authetication.

Microsoft.Data.SqlClient.

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
Parameter Sets: default, credential, token
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AzureAD
Use this when connecting to an Azure SQL Database and you are using Azure AD credentials. You can specify the credentials by passing in a credential object to the Credential parameter.

```yaml
Type: SwitchParameter
Parameter Sets: credential
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AzureToken
Pass in Azure Token (make sure you use the proper resource). If your token begins with "bearer " that will be stripped off first.

```yaml
Type: String
Parameter Sets: token, conn
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
Parameter Sets: credential, conn
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Database
The database to connect to.

```yaml
Type: String
Parameter Sets: default, credential, token
Aliases: SqlDatabase, InitialCatalog

Required: False
Position: 1
Default value: master
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Server
The server to connect to

```yaml
Type: String
Parameter Sets: default, credential, token
Aliases: SqlInstance, SqlServer, DataSource

Required: False
Position: 0
Default value: localhost
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Int32
### System.Management.Automation.PSCredential
### System.Management.Automation.SwitchParameter
### System.Collections.Hashtable
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
