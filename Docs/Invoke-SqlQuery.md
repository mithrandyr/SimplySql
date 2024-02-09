---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Invoke-SqlQuery

## SYNOPSIS
Executes a query and returns data.

## SYNTAX

### object (Default)
```
Invoke-SqlQuery [-ConnectionName <String>] [-Query] <String[]> [-CommandTimeout <Int32>]
 [[-ParamObject] <PSObject>] [-Stream] [-AsDataTable] [-UseTypesFromProvider] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### hashtable
```
Invoke-SqlQuery [-ConnectionName <String>] [-Query] <String[]> [-Parameters] <Hashtable>
 [-CommandTimeout <Int32>] [-Stream] [-AsDataTable] [-UseTypesFromProvider] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Executes a query against the targeted connection and returns the data.  This can handle multiple result sets (if underlying provider supports it).  If there are multiple result sets, the output is datatables, otherwise datarows.

If the -Stream switch is used, only the first result set is returned and the output is a PSObject for each row in the result set.

Supports piping in objects, which will be converted to parameters and the query will be executed for once for each object piped in.

## EXAMPLES

### Example 1
```powershell
PS C:\> Invoke-SqlQuery -Query "SELECT * FROM TABLE"
```

Run a simple query and return the output

### Example 2
```powershell
PS C:\> Invoke-SqlQuery -Query "SELECT * FROM TABLE WHERE col1=@id' AND colb > @someDate" -Parameters @{id = 1; someDate = (Get-Date)}
```

Runs a simple query with parameters

## PARAMETERS

### -AsDataTable
Forces the return objects to be one or more datatables. If combined with -Stream, -AsDataTable will be ignored.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandTimeout
The timeout, in seconds, for this SQL statement, defaults to the command timeout for the SqlConnection.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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

### -Parameters
Parameters required by the query. Key matches the parameter name, Value is the value of the parameter.

```yaml
Type: Hashtable
Parameter Sets: hashtable
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParamObject
The object that contains the parameters for the query, member names match the parameter name.

```yaml
Type: PSObject
Parameter Sets: object
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Query
SQL statement to run.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Stream
Uses a datareader to stream PSObject representing the results of the query to the pipeline, results will appear as soon as the connection begins returning data.  Only returns the first resultset if there are multiples. If combined with -AsDataTable, -AsDataTable will be ignored.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseTypesFromProvider
Will attempt to return the provider specific data types instead of standard .NET datatypes.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ProviderTypes

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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
### System.Management.Automation.PSObject
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
