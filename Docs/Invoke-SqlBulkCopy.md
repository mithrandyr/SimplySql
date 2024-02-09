---
external help file: SimplySql.Cmdlets.dll-Help.xml
Module Name: SimplySql
online version:
schema: 2.0.0
---

# Invoke-SqlBulkCopy

## SYNOPSIS
Executes a bulk copy between two connections.

## SYNTAX

### hashtable (Default)
```
Invoke-SqlBulkCopy [-SourceConnectionName <String>] [-DestinationConnectionName <String>]
 [-ColumnMap <Hashtable>] [-BatchSize <Int32>] [-BatchTimeout <Int32>] [-Notify] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### table
```
Invoke-SqlBulkCopy [-SourceConnectionName <String>] [-DestinationConnectionName <String>]
 [-DestinationTable <String>] -SourceTable <String> [-ColumnMap <Hashtable>] [-BatchSize <Int32>]
 [-BatchTimeout <Int32>] [-Notify] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### query
```
Invoke-SqlBulkCopy [-SourceConnectionName <String>] [-DestinationConnectionName <String>]
 -DestinationTable <String> -SourceQuery <String[]> [-SourceParameters <Hashtable>] [-ColumnMap <Hashtable>]
 [-BatchSize <Int32>] [-BatchTimeout <Int32>] [-Notify] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Executes a bulk copy operation between two connections.  This is highly optimized if the destination has a managed bulkcopy implemenation, otherwise it is only generally optimized.  For example, SQL Server has a bulk copy class (SqlBulkCopy) that is easily implemented and provides an efficient means of inserting data into SQL Server.

The default implemenation, if the provider does not provider a managed bulk copy mechanism is to prepare the sql insert, and wrap multiple inserts into a single transaction (batching).  This provides a significant performance improvement over looping with Invoke-SqlUpdate.

CONSIDERATIONS
* You must specify either a SourceConnectionName or DestinationConnectionName, whichever one is not specified will use 'default', not specifying either will cause an error.      
* If you don't specify DestinationTable, it will use SourceTable; however DestinationTable is required if you use SourceQuery.
* If you specify ColumnMap and Source Table, then the select against the SourceConnection will be limited to the columns you specified in ColumnMap.

Returns number of rows copied.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -BatchSize
How many inserts are batched together at one time.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 500
Accept pipeline input: False
Accept wildcard characters: False
```

### -BatchTimeout
How long, in seconds, that each batch can take. Defaults to the command timeout for the source connection.

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

### -ColumnMap
Key is the column name in the source connection.  Value is the column name in the destination connection.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DestinationConnectionName
User defined name for connection where data will be inserted to.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DstCN

Required: False
Position: Named
Default value: default
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationTable
The name of the table to write to in the destination connection.  If not specified, will be taken from SourceTable parameter.

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: query
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Notify
If present, as each batch completes a progress notification will be generated with the total number of rows inserted so far.

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

### -SourceConnectionName
User defined name for connection where data will be queried from.

```yaml
Type: String
Parameter Sets: (All)
Aliases: SrcCN

Required: False
Position: Named
Default value: default
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceParameters
Parameters needed for the source query.

```yaml
Type: Hashtable
Parameter Sets: query
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceQuery
The query to determine the source data, instead of specifying a table.

```yaml
Type: String[]
Parameter Sets: query
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SourceTable
The name of the table in the source connection.

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
### System.String[]
### System.Collections.Hashtable
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
