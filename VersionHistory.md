## Version History
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