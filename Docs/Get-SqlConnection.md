---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Get-SqlConnection

## SYNOPSIS
Gets the underlying provider connection object.

## SYNTAX

```
Get-SqlConnection [-ConnectionName <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Gets the underlying provider connection object for the current connection or for the connection name specified.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-SqlConnection
```

Returns the provider-specific Connection object.

## PARAMETERS

### -ConnectionName
User defined name for connection.

```yaml
Type: String
Parameter Sets: (All)
Aliases: cn

Required: False
Position: Named
Default value: default
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
