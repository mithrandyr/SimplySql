---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Open-SQLiteConnection

## SYNOPSIS
Open a connection to a SQLite database file.

## SYNTAX

### default (Default)
```
Open-SQLiteConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [[-DataSource] <String>]
 [[-Password] <String>] [-Additional <Hashtable>] [<CommonParameters>]
```

### conn
```
Open-SQLiteConnection [-ConnectionName <String>] [-CommandTimeout <Int32>] [-ConnectionString <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Open a connection to a SQLite database file.
SQLite Development Team @ https://sqlite.org/
.NET Provider @ http://system.data.sqlite.org/

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

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DataSource
The datasource for the connection.

```yaml
Type: String
Parameter Sets: default
Aliases: FilePath

Required: False
Position: 0
Default value: :memory:
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
Password for the database file.

```yaml
Type: String
Parameter Sets: default
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Int32
### System.Collections.Hashtable
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
