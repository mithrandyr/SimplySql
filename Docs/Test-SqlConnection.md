---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Test-SqlConnection

## SYNOPSIS
Tests to see if there is a connection.

## SYNTAX

### single (Default)
```
Test-SqlConnection [[-ConnectionName] <String>] [-Detailed] [<CommonParameters>]
```

### all
```
Test-SqlConnection [-All] [<CommonParameters>]
```

## DESCRIPTION
Tests to see if there is a connection, use the -All switch to determine if there are any connections.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -All
Returns true if there are any connections, otherwise false.

```yaml
Type: SwitchParameter
Parameter Sets: all
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConnectionName
User defined name for connection.

```yaml
Type: String
Parameter Sets: single
Aliases: cn

Required: False
Position: 0
Default value: default
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Detailed
If present, will only return return if connection is found and in an Open state.

```yaml
Type: SwitchParameter
Parameter Sets: single
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
