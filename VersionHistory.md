# Version History

### 1.9.1
* Updating SQLite library.  Interop Version: 1.0.117.0 & SQLite Server Version: 3.40.0 thanks @JediNite
### 1.9.0
* Updated classes to use `::new()` constructor.  thanks @joalcorn
* Updated MySql provider to use new library (8.0.28).  thanks @twerthi

### 1.8.0
* Minor Update, enhancing progress notifications for Invoke-SqlBulkCopy, you can now specify -NotifyAction and pass in a scriptblock
### 1.7.0

* Minor update to expose the transaction object to the user via the new `Get-SqlTransaction` cmdlet.

### 1.6.2

* added support for .Net Framework 4.6.1 (included library 'DataReaderToPSObject' is compiled against .Net Standard 2.0 which requires shims on .Net 4.6.1).  (@jantari)

### 1.6.1

* added support for Azure Token authentication to SQL Server

### 1.6.0

* Updated DataReaderToObject.dll (@ili101)
* Added -TrustServerCertificate to Open-PostgreConnection (@ili101)
* Added -ProviderTypes to Invoke-SqlQuery (@ili1010)

### 1.5.9

* Fixed issue with `Open-OracleConnection` help (@PaulWalkerUK)
* Added -AsDataTable to Open-SqlQuery (@ili101)
* Added -TrustSSL to Open-PostGreConnection, allowing for self-signed certificates (@ili101)
* Updated -ConnectionName parameter on all cmdlets to no longer allow null or empty strings.
* Added better handling around SqlTransactions when an error is thrown (for SQL Server this happens when the server takes longer than the connectionTimeout, however the transaction action (COMMIT or ROLLBACK) still goes through properly).
* Added default value ("postgres") to -Database for Open-PostGreConnection.
* Added -DBAPrivilege to Open-OracleConnection to allow connecting as SYSOPER or SYSDBA.

### 1.5.4

* Fixed issue with loading the Geometry npgsql extension (Npgsql.NetTopologySuite) when database in connection string did not have PostGIS installed.
* Automatically load geometry npgsql extension on database switch and on re-opening the connection (if current database has PostGIS installed).

### 1.5.3

* Fixed issue with Geometry not being supported in PostGre provider.

### 1.5.2

* Fixed issue with OracleProvider -- binding by position rather than by parameter name. (@Abrechnung1)

### 1.5.1

* Updated tests for Pester v4
* Fixed issue with transactions for MSSQL.
* Fixed issue with ```Show-SqlConnection -all | Close-SqlConnection``` when there are no open connections.
* Updated MySql Provider to 8.0.12, added parameter for SSLmode
* Updated SQLite provider to 1.0.109.1
* Updated Oracle provider to 18.3 (added support for oracleCredential)
* Updated PostGre provider (npgsql) to 4.0.2

### 1.4.1

* Added support for SSL connections to PostGre provider.

### 1.4.0

* Added support for PSCredential on MySql, Oracle and PostGre providers, marking UserName/Password as deprecated.  Sql Provider already had support, added deprecation warning.  SQLite only has -Password, no change to this provider.

### 1.3.8

* Fixed issue with Invoke-SqlQuery throwing an error when there is no resultset, now creates a warning.
* Added Pester tests to cover this scenario.

### 1.3.7

* Fixed issue with SqlConnection not accepting ConnectionStrings (root issue, you can't assign a connection string to an existing SqlConnectionStringBuilder.)
* Fixed issue with MySqlConnection and PostGreConnection, can't assign connection string to *ConnectionStringBuilder, instead simply create the connection object if connectionstring is passed in.

### 1.3.6

* Fixed issue with -Parameters on Invoke-SqlQuery/Scalar/Update, passing in '$false' as a value was failing to pass anything at all.

### 1.3.5

* Fixed issue with Postgre that got released in version 1.3.4.

### 1.3.4

* Updated help: cmdlets and the about_* files (about_SimplySql & about SimplySql_Providers).
* Updated provider DLLs for PostGre, MySql, and SQLite.

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