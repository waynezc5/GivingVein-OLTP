# GivingVein-OLTP

This repository contains the design and T-SQL implementation of a OLTP relational database designed to manage the blood donations, donors and lab orders of a fictitious non-profit organization.

## Database Design
The database design is represented in the following Entity-Relationship Diagram (ERD):

![ERD Diagram](https://github.com/waynezc5/GivingVein-OLTP/blob/main/GivingVein%20Database%20Diagram.jpeg)

## Files Included

### GivingVein.sql

The DDL statements create the tables, indexes, and constraints and foreign key relationships necessary to maintain data integrity. Also includes DML statements for adding data.


### GivingVein.bak

Backup file can be restored to a SQL Server instance using the SQL Server Management Studio or other compatible tool.

## Usage
To use the GivingVein database, either run the GivingVein.sql script against a SQL Server instance or simply restore the backup file.
