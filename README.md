# SimplySql
## Introduction
Querying SQL (SQL Server, Oracle, PostgreSql, SQLite, & mySql) the PowerShell way: simple commands... powerful opportunities.

SimplySql is a module that provides an intuitive set of cmdlets for talking to databases that abstracts the vendor specifics, allowing you to focus on getting work done.

The basic pattern is to connect to a database, invoke one or more sql statements and then close your database connection. This module provides cmdlets that map to this basic pattern.

    Open-Connection -Provider SQL -DataSource "SomeServer" -InitialCatalog "SomeDB"
    $data = Invoke-SqlQuery -query "SELECT * FROM someTable"
    Close-SqlConnection

## Status
Version .2.1 is in the repository, supports SQL Server and SQLite.  Please note that this project is actively in development and should be considered beta.

It has been released to PowerShellGallery.  Installation is as simple as 

    Install-Module SimplySql

This module requires PowerShell Version 5.0 or greater