# SimplySql

## Introduction

[![Powershell Gallery](https://img.shields.io/powershellgallery/v/SimplySql.svg)](https://www.powershellgallery.com/packages/SimplySql/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/SimplySql.svg)](https://www.powershellgallery.com/packages/SimplySql/)

**Update (2/8/2024):** V2 is Released!!!.

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

## Breaking Changes for 2.0
- UserName/Password parameters are no longer present on `Open-*Connection` cmdlets.  Instead, provide a PSCredential object.

## Status

It has been released to PowerShellGallery.  Installation is as simple as

    Install-Module SimplySql -Scope CurrentUser

This module requires PowerShell Version 5.0 or greater

## Database Providers

- Microsoft Sql Server : [Microsoft.Data.SqlClient 5.1.5](https://www.nuget.org/packages/Microsoft.Data.SqlClient/5.1.5)
- MySQL : [MySqlConnector 2.3.5](https://www.nuget.org/packages/MySqlConnector/2.3.5)
- Oracle : [Oracle.ManagedDataAccess.Core 2.19.220](https://www.nuget.org/packages/Oracle.ManagedDataAccess.Core/2.19.220) (this is the latest version supporting .NET Standard 2.0)
- SQLite : [System.Data.SQLite.Core 1.0.118](https://www.nuget.org/packages/System.Data.SQLite.Core/1.0.118)
- PostgreSQL : [Npgsql (8.0.1)](https://www.nuget.org/packages/Npgsql/8.0.1)

## Latest Version

### 2.0.67
* First release to support Windows PowerShell 5.1, PS Core and PS7.
* Migrated the base provider class to .Net & all providers
* Updated to latest versions of providers (that support .NET Standard 2.0)
* Leveraged Optimized BulkCopy functionality in each provider.

[View Version History](VersionHistory.md)