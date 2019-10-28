--------------------------------------------------------------------------------- 
-- DEMO 4 --
-- Create WhoIsActive table to collect logging data out of sp_WhoIsActive
---------------------------------------------------------------------------------

SET NOCOUNT ON

USE DBA;
GO

-- Declaring variables
DECLARE 
        @destination_table VARCHAR(500) = 'WhoIsActive'
        ,@destination_database sysname = 'DBA'
        ,@schema VARCHAR(MAX)
        ,@SQL NVARCHAR(4000)
        ,@parameters NVARCHAR(500)
        ,@exists BIT;

SET @destination_table = @destination_database + '.dbo.' + @destination_table;

-- Creating the logging table
IF OBJECT_ID(@destination_table) IS NULL
    BEGIN;
        EXEC dbo.sp_WhoIsActive 
            @get_transaction_info = 1,
            @get_outer_command = 1,
            @get_plans = 1,
            @return_schema = 1,
            @schema = @schema OUTPUT;
        SET @schema = REPLACE(@schema, '<table_name>', @destination_table);
        EXEC ( @schema );
    END;

-- Creating index on collection_time
SET @SQL
    = 'USE ' + QUOTENAME(@destination_database)
      + '; IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(@destination_table) AND name = N''cx_collection_time'') SET @exists = 0';
SET @parameters = N'@destination_table varchar(500), @exists bit OUTPUT';
EXEC sys.sp_executesql @SQL, @parameters, @destination_table = @destination_table, @exists = @exists OUTPUT;

IF @exists = 0
    BEGIN;
        SET @SQL = 'CREATE CLUSTERED INDEX cx_collection_time ON ' + @destination_table + '(collection_time ASC)';
        EXEC ( @SQL );
    END;

SELECT 'WhoIsActive table has been created in DBA database';