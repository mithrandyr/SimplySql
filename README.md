# SimplySql

## Introduction

[![Powershell Gallery](https://img.shields.io/powershellgallery/v/SimplySql.svg)](https://www.powershellgallery.com/packages/SimplySql/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/SimplySql.svg)](https://www.powershellgallery.com/packages/SimplySql/)

Querying SQL (SQL Server, Oracle, PostgreSql, SQLite, & mySql) the PowerShell way: simple commands... powerful opportunities.

SimplySql is a module that provides an intuitive set of cmdlets for talking to databases that abstracts the vendor specifics, allowing you to focus on getting work done.

The basic pattern is to connect to a database, invoke one or more sql statements and then close your database connection. This module provides cmdlets that map to this basic pattern.  Each Provider has its own 'Open-*Connection' cmdlet, but the remaining cmdlets are provider agnostic (MSSQL: Open-SqlConnection, Oracle: Open-OracleConnection, SQLite: Open-SQLiteConnection, etc).  You can have multiple connections open, just distinguish them through the use of the -ConnectionName parameter on every command (if no ConnectionName is specified, it defaults to 'default').

```Powershell
    Open-*Connection -DataSource "SomeServer" -InitialCatalog "SomeDB"
    $data = Invoke-SqlQuery -query "SELECT * FROM someTable"

    #or using parameters
    $data = Invoke-SqlQuery -query "SELECT * FROM someTable WHERE someCol = @var" -Parameters @{var = 'a value'}
    Close-SqlConnection
```

See the [Wiki](https://github.com/mithrandyr/SimplySql/wiki) for more details

## Status

It has been released to PowerShellGallery.  Installation is as simple as

    Install-Module SimplySql -Scope CurrentUser

This module requires PowerShell Version 5.0 or greater

## Latest Version

### 1.8.0
* Minor Update, enhancing progress notifications for Invoke-SqlBulkCopy, you can now specify -NotifyAction and pass in a scriptblock
### 1.7.0

* Minor update to expose the transaction object to the user via the new `Get-SqlTransaction` cmdlet.

[View Version History](VersionHistory.md)