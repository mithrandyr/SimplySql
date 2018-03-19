# SimplySql
## Introduction
Querying SQL (SQL Server, Oracle, PostgreSql, SQLite, & mySql) the PowerShell way: simple commands... powerful opportunities.

SimplySql is a module that provides an intuitive set of cmdlets for talking to databases that abstracts the vendor specifics, allowing you to focus on getting work done.

The basic pattern is to connect to a database, invoke one or more sql statements and then close your database connection. This module provides cmdlets that map to this basic pattern.  Each Provider has its own 'Open-*Connection' cmdlet, but the remaining cmdlets are provider agnostic (MSSQL: Open-SqlConnection, Oracle: Open-OracleConnection, SQLite: Opqn-SQLiteConnection, etc).  You can have multiple connections open, just distinguish them through the use of the -ConnectionName parameter on every command (if no ConnectionName is specified, it defaults to 'default').

    Open-*Connection -DataSource "SomeServer" -InitialCatalog "SomeDB"
    $data = Invoke-SqlQuery -query "SELECT * FROM someTable"
    Close-SqlConnection

## Status
Version 1.1.x is in the repository, supports SQL Server, SQLite, MySql, Oracle and PostGreSql.  Please note that this project is actively in development and should be considered beta, though perfectly usuable.

It has been released to PowerShellGallery.  Installation is as simple as 

    Install-Module SimplySql

This module requires PowerShell Version 5.0 or greater

## Version History
### 1.3.3
* Fixed issue where -ConnectionString was not working properly with the Oracle Provider.
### 1.3.2
* Fixed issue with help missing from the open-*connection cmdlets.
* removed unnecessary files from the Functions subfolder.
### 1.3.1
* Fixed minor issues with SQLBulkCopy: -notify is not required and if SQLBulkCopy errors, Identity Insert will be turned off.
### 1.3.0
* Added support for Azure AD auth for Azure SQL Dbs
* Fix issue in PostGre when using the -stream parameter and querying scalar data without a table, select "1, 2, 3"
### 1.2.0
* Updated providers
### 1.1.1
* Removed a debugging message from the base Provider.BulkLoad method (only showed up in sqlite)
* Added functionality to retrieve the underlying provider connection object via Get-SqlConnection (gsc)
* Updated information in the about files.
### 1.1.0
* Added support for non standard column names (ie those that might include spaces, etc) in Invoke-SqlBulkCopy.
* Changed Open-MySqlConnection to no longer require setting the database, defaults to "mysql"
