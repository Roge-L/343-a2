-- Best and Worst Categories

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
    month TEXT NOT NULL,
    highestCategory TEXT NOT NULL,
    highestSalesValue FLOAT NOT NULL,
    lowestCategory TEXT NOT NULL,
    lowestSalesValue FLOAT NOT NULL
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS Purchases2020 CASCADE;
DROP VIEW IF EXISTS MonthlySales2020 CASCADE;
DROP VIEW IF EXISTS MaxPerMonth CASCADE;
DROP VIEW IF EXISTS MinPerMonth CASCADE;
DROP VIEW IF EXISTS MaxCategories CASCADE;
DROP VIEW IF EXISTS MinCategories CASCADE;
DROP VIEW IF EXISTS Question4Answer CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW Purchases2020 AS
    SELECT Purchase.PID, Purchase.CID, Item.IID, Item.category, Purchase.d, EXTRACT(MONTH FROM Purchase.d) AS month, Item.price * LineItem.quantity AS saleprice
    FROM Purchase
        JOIN LineItem ON Purchase.PID = LineItem.PID
        JOIN Item ON LineItem.IID = Item.IID
    WHERE EXTRACT(YEAR FROM d) = 2020;

CREATE VIEW MonthlySales2020 AS
    SELECT category, month, SUM(saleprice) AS sales
    FROM Purchases2020
    GROUP BY category, month;

CREATE VIEW MaxPerMonth AS
    SELECT month, MAX(sales) as maxSales
    FROM MonthlySales2020
    GROUP BY month;

CREATE VIEW MinPerMonth AS
    SELECT month, MIN(sales) as minSales
    FROM MonthlySales2020
    GROUP BY month;

CREATE VIEW MaxCategories AS
    SELECT category AS highestCategory, MonthlySales2020.month, maxSales AS highestSalesValue
    FROM MonthlySales2020
        JOIN MaxPerMonth ON MonthlySales2020.sales = MaxPerMonth.maxSales AND MonthlySales2020.month = MaxPerMonth.month;

CREATE VIEW MinCategories AS
    SELECT category AS lowestCategory, MonthlySales2020.month, minSales AS lowestSalesValue
    FROM MonthlySales2020
        JOIN MinPerMonth ON MonthlySales2020.sales = MinPerMonth.minSales AND MonthlySales2020.month = MinPerMonth.month;

CREATE VIEW Question4Answer AS
    SELECT maxcategories.month, highestcategory, highestsalesvalue, lowestcategory, lowestsalesvalue
    FROM maxcategories JOIN mincategories ON maxcategories.month = mincategories.month;

-- Your query that answers the question goes below the "insert into" line:
insert into q4 (SELECT * FROM Question4Answer);