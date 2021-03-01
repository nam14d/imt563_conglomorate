-- 1. Create a stored procedure which takes one or more parameters and returns rows from your table based on your given parameters.

-- If this procedure exists, drop it
IF OBJECT_ID ('dbo.nmarangi_moreVotesThanX', 'P') IS NOT NULL
    DROP PROCEDURE dbo.nmarangi_moreVotesThanX;
GO
-- Create the procedure
CREATE PROCEDURE dbo.nmarangi_moreVotesThanX
    @vote_count INT
AS
    SELECT
        *
    FROM
        [dbo].[nmarangi_spookymovies]
    WHERE
        @vote_count >= votes
GO

--EXEC dbo.nmarangi_moreVotesThanX @vote_count = 19456
--GO

-- 2. Create a stored procedure which allows you to insert a new row into your table.
IF OBJECT_ID('dbo.nmarangi_insertRecord','P') IS NOT NULL
    DROP PROCEDURE dbo.nmarangi_insertRecord;
GO
--Create Procedure
CREATE PROCEDURE dbo.nmarangi_insertRecord
    @title varchar(100), 
    @release_year INT, 
    @age_rating VARCHAR(10), 
    @runtime INT, 
    @rating FLOAT, 
    @metascore INT, 
    @director VARCHAR(50), 
    @votes INT, 
    @gross_profit INT
AS
    BEGIN TRAN T1
        INSERT INTO [dbo].[nmarangi_spookymovies](title, release_year, age_rating, runtime, rating, metascore, director, votes, gross_profit)
        VALUES(@title, @release_year, @age_rating, @runtime, @rating, @metascore, @director, @votes, @gross_profit)
    IF @@ERROR <> 0
        ROLLBACK TRAN T1
    ELSE
        COMMIT TRAN T1
GO

-- EXEC dbo.nmarangi_insertRecord @title = 'Dead Space', @release_year = 2008, @age_rating = 'M', @runtime = 600, @rating = 9.5, @metascore = 86, @director = 'Glen Schofield', @votes = 1234567, @gross_profit = 60000000

-- 3. Create a function which performs some sort of aggregation and grouping of your data based on one or more passed in parameters and return the resulting rows.
IF OBJECT_ID('dbo.nmarangi_topTenByYear','F') IS NOT NULL
    DROP FUNCTION dbo.nmarangi_topTenByYear;
GO
-- Create Function
CREATE FUNCTION dbo.nmarangi_topTenByYear
    (@column VARCHAR(12))
RETURNS TABLE
AS
    RETURN(
        SELECT
            *,
            RANK() OVER(PARTITION BY release_year ORDER BY @column DESC) AS YearlyRank
        FROM 
            [dbo].[nmarangi_spookymovies]
    )
GO

-- 4. Create a function which performs one or more validation checks on one or more columns of your table and then also create a Check Constraint which utilizes this function.
IF OBJECT_ID('dbo.nmarangi_checkPositiveGross','F') IS NOT NULL
    DROP FUNCTION dbo.nmarangi_checkPositiveGross;
GO
-- Create Function
CREATE FUNCTION dbo.nmarangi_checkPositiveGross()
RETURNS INT
AS
    BEGIN
    DECLARE @isPositive INT = 0
    IF EXISTS(
        SELECT
        *
        FROM
        [dbo].[nmarangi_spookymovies]
        WHERE gross_profit >= -5
    )
        BEGIN 
        SET @isPositive = 1 
        END
RETURN @isPositive
END
GO

ALTER TABLE [dbo].[nmarangi_spookymovies]
ADD CONSTRAINT PositiveSales
CHECK(dbo.nmarangi_checkPositiveGross() = 1)
GO



ALTER TABLE dbo.nmarangi_spookymovies
INSERT CONSTRAINT(dbo.nmarangi_checkNegativeGross = 0)

