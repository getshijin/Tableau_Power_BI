

create database [data profiling]

use [data profiling]

CREATE TABLE EmployeeData (
    EmployeeID INT,
    FullName NVARCHAR(100) NOT NULL,
    Age INT NULL,
    HireDate DATE NULL,
    Salary DECIMAL(10, 2) DEFAULT 0.00,
    IsActive BIT NOT NULL,
    Department NVARCHAR(50) NULL,
    PerformanceScore FLOAT NULL,
    Position NVARCHAR(100) NOT NULL,
    ManagerID INT NULL
);

INSERT INTO EmployeeData (EmployeeID, FullName, Age, HireDate, Salary, IsActive, Department, PerformanceScore, Position, ManagerID)
VALUES
(1, 'Alice Smith', 30, '2020-06-01', 60000.00, 1, 'Development', 4.5, 'Senior Developer', NULL),
(2, 'Bob Johnson', NULL, NULL, 75000.00, 1, 'Management', 4.2, 'Project Manager', 1),
(3, 'Charlie Brown', 28, '2021-09-10', 0.00, 1, 'Development', 4.0, 'Junior Developer', 1),
(5, 'Ethan Hunt', 50, '2015-03-22', 90000.00, 1, 'Management', 4.8, 'Director', 1),
(6, 'Fiona Gallagher', 29, '2022-01-10', 48000.00, 1, 'Intern', 3.9, 'Intern', 3),
(7, 'Bob Johnson', 45, '2019-04-15', 75000.00, 1, 'Management', 4.2, 'Project Manager', 1), -- Duplicate
(8, 'Hannah Baker', 33, NULL, 52000.00, 1, 'Quality Assurance', 4.1, 'Tester', 4),
(9, 'Ian Malcolm', NULL, '2016-05-10', 55000.00, 1, 'Analysis', 4.4, 'Analyst', 2),
(10, 'Jack Sparrow', 44, '2014-07-20', 72000.00, 1, 'Management', 4.7, 'Captain', 5);


----------------------------





select * from EmployeeData

select * from INFORMATION_SCHEMA.columns where TABLE_NAME like 'employeedata'

select column_name,ordinal_position, data_type, character_maximum_length into #1
from INFORMATION_SCHEMA.columns where TABLE_NAME like 'employeedata'

select * from #1
select * from EmployeeData

alter table #1 add maximum nvarchar(max)
alter table #1 add minimum nvarchar(max)
alter table #1 add nulls int
alter table #1 add distinct_count int
alter table #1 add mean float
alter table #1 add median float
alter table #1 add mode nvarchar(max)
alter table #1 add SD float
alter table #1 add Zero_Values int



-----------------------------------------------------------------------

DECLARE @sql NVARCHAR(MAX);
DECLARE @i INT = 1;  -- Start from 1 to match ordinal_position
DECLARE @j INT;
SET @j = (SELECT max(ORDINAL_POSITION) FROM #1);  -- Get the number of rows

DECLARE @columnName NVARCHAR(MAX);
DECLARE @dataType NVARCHAR(MAX);

WHILE @i <= @j
BEGIN
    -- Get the column name and data type for the current ordinal position
    SELECT @columnName = column_name, @dataType = DATA_TYPE 
    FROM #1 
    WHERE ordinal_position = @i;

    -- Handle numeric columns
    IF @dataType IN ('int', 'float', 'real', 'decimal', 'numeric', 'money', 'smallint', 'tinyint')
    BEGIN
        -- Construct the dynamic SQL for calculating max, min, mean, stddev, nulls, distinct count, and zero count
        SET @sql = 'UPDATE #1 SET maximum = (SELECT MAX(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET minimum = (SELECT MIN(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET mean = (SELECT AVG(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET SD = (SELECT STDEV(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET nulls = (SELECT COUNT(*) FROM EmployeeData WHERE ' + @columnName + ' IS NULL) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET distinct_count = (SELECT COUNT(DISTINCT ' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET zero_values = (SELECT COUNT(*) FROM EmployeeData WHERE ' + @columnName + ' = 0) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        -- Add logic for Median
        SET @sql = 'UPDATE #1 SET median = (
            SELECT AVG(CAST(' + @columnName + ' AS FLOAT))
            FROM (
                SELECT ' + @columnName + ',
                       ROW_NUMBER() OVER (ORDER BY ' + @columnName + ') AS RowAsc,
                       COUNT(*) OVER () AS TotalCount
                FROM EmployeeData
                WHERE ' + @columnName + ' IS NOT NULL
            ) AS OrderedValues
            WHERE RowAsc IN ((TotalCount + 1) / 2, (TotalCount + 2) / 2)
        ) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        -- Add logic for Mode
        SET @sql = 'UPDATE #1 SET mode = (
            SELECT TOP 1 ' + @columnName + '
            FROM EmployeeData
            GROUP BY ' + @columnName + '
            ORDER BY COUNT(*) DESC
        ) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;
    END

    -- Handle date columns
    IF @dataType IN ('date', 'datetime', 'datetime2', 'smalldatetime', 'time')
    BEGIN
        -- Calculate max and min
        SET @sql = 'UPDATE #1 SET maximum = (SELECT MAX(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET minimum = (SELECT MIN(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        -- Nulls and distinct counts
        SET @sql = 'UPDATE #1 SET nulls = (SELECT COUNT(*) FROM EmployeeData WHERE ' + @columnName + ' IS NULL) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET distinct_count = (SELECT COUNT(DISTINCT ' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        -- Count zero values for dates (assuming a specific zero date, e.g., '1900-01-01')
        SET @sql = 'UPDATE #1 SET zero_values = (SELECT COUNT(*) FROM EmployeeData WHERE ' + @columnName + ' = ''1900-01-01'') WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        -- Add logic for Mode
        SET @sql = 'UPDATE #1 SET mode = (
            SELECT TOP 1 CONVERT(NVARCHAR, ' + @columnName + ', 120)
            FROM EmployeeData
            GROUP BY ' + @columnName + '
            ORDER BY COUNT(*) DESC
        ) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;
    END

    -- Handle non-numeric columns for max and min
    IF @dataType IN ('varchar', 'nvarchar', 'text', 'char', 'nchar')
    BEGIN
        SET @sql = 'UPDATE #1 SET maximum = (SELECT MAX(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        SET @sql = 'UPDATE #1 SET minimum = (SELECT MIN(' + @columnName + ') FROM EmployeeData) WHERE ordinal_position = ' + CAST(@i AS VARCHAR(MAX));
        EXEC sp_executesql @sql;

        -- No mean, median, or standard deviation for non-numeric columns
    END

    -- Increment to the next column
    SET @i = @i + 1;  
END

-- Select the updated profiling results
SELECT * FROM #1;

-- Clean up
DROP TABLE #1;
