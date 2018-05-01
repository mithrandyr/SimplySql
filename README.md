# SimplySql
## Introduction
[![Powershell Gallery](https://img.shields.io/powershellgallery/v/SimplySql.svg)](https://www.powershellgallery.com/packages/SimplySql/)

Querying SQL (SQL Server, Oracle, PostgreSql, SQLite, & mySql) the PowerShell way: simple commands... powerful opportunities.

SimplySql is a module that provides an intuitive set of cmdlets for talking to databases that abstracts the vendor specifics, allowing you to focus on getting work done.

The basic pattern is to connect to a database, invoke one or more sql statements and then close your database connection. This module provides cmdlets that map to this basic pattern.  Each Provider has its own 'Open-*Connection' cmdlet, but the remaining cmdlets are provider agnostic (MSSQL: Open-SqlConnection, Oracle: Open-OracleConnection, SQLite: Opqn-SQLiteConnection, etc).  You can have multiple connections open, just distinguish them through the use of the -ConnectionName parameter on every command (if no ConnectionName is specified, it defaults to 'default').

    Open-*Connection -DataSource "SomeServer" -InitialCatalog "SomeDB"
    $data = Invoke-SqlQuery -query "SELECT * FROM someTable"
    Close-SqlConnection

See the [Wiki](https://github.com/mithrandyr/SimplySql/wiki) for more details

## Status
Version 1.3.x is in the repository, supports SQL Server, SQLite, MySql, Oracle and PostGreSql.  Please note that this project is actively in development and should be considered beta, though perfectly usuable.

It has been released to PowerShellGallery.  Installation is as simple as 

    Install-Module SimplySql -Scope CurrentUser

This module requires PowerShell Version 5.0 or greater

## Latest Version
### 1.3.6
* Fixed issue with -Parameters on Invoke-SqlQuery/Scalar/Update, passing in '$false' as a value was failing to pass anything at all.
### 1.3.5
* Fixed issue with Postgre that got released in version 1.3.4.
### 1.3.4
* Updated help: cmdlets and the about_* files (about_SimplySql & about SimplySql_Providers).
* Updated provider DLLs for PostGre, MySql, and SQLite.

[View Version History](VersionHistory.md)