select * from bakery;
-- 1 What is the total number of transactions in the bakery?
select count(transactionno) as total_transaction from bakery;
-- 2 How many unique items are listed in the bakery?
select count(distinct (items)) from bakery;
-- 3 What is the most common day part for transactions?
select daypart , count(daypart) as ct from bakery group by daypart;
-- 4 How many transactions occurred on weekends?
select count(transactionno) from bakery where daytype = 'weekend';
-- 5 What is the earliest transaction date in the dataset?
select min(datetime) as earliest from bakery;
-- 6 How many transactions were made on weekdays?
select count(transactionno) from bakery where daytype = 'weekday';
-- 7 What is the most common day type for transactions?
select daytype , count(daytype) as ct from bakery group by daytype;
-- 8 What is the total number of transactions for each item?
select count(transactionno) as c , items from bakery group by items order by c desc;
-- 9 What is the average number of transactions per day?
select avg(ct) as avg_no_transaction from (
select count(transactionno) as ct, date(datetime) as dt from bakery group by dt) t;
-- 10 How many transactions were recorded on the most frequent day?
select count(transactionno) as ct, date(datetime) as dt from bakery group by dt order by ct desc limit 1;
-- 11 What percentage of transactions occurred during the evening day part?

set @a= (select count(transactionno) from bakery );
select ct/ @a * 100 from(
select daypart , count(transactionno)as ct from bakery where daypart = 'Evening')t;
------------
SELECT 
    (COUNT(CASE WHEN Daypart = 'Evening' THEN 1 END) / COUNT(*)) * 100 AS PercentageOfEveningTransactions
FROM bakery;
-- 12 How many transactions were made on night?
select count(transactionno) from bakery where daypart='night';
-- 13 What is the distribution of transactions across different day parts?
select count(transactionno) , daypart from bakery group by daypart;
-- 14 What is the most frequent transaction date and its count?
select count(date(datetime)) as dt ,date(datetime) as d from bakery group by date(datetime) order by dt desc limit 1;
-- 15 How many unique transaction numbers are there for each item?
select count(distinct(transactionno)) as t , items from bakery group by items order by t desc;
-- 16 What is the average number of transactions per daypart?
select avg(t) as t1,daypart from  (
select count(transactionno) as t , daypart from bakery group by daypart,Date(DateTime)) t 
group by daypart;
-- 17 How does the number of transactions vary by day type?
 SELECT 
    DayType,
    COUNT(*) AS TotalTransactions,
    AVG(ct) AS AverageTransactionsPerDay,
    MAX(ct) AS MaxTransactionsPerDay,
    MIN(ct) AS MinTransactionsPerDay
FROM (
select count(transactionno) as ct, Date(DateTime),daytype from bakery group by daytype,Date(DateTime)) t
GROUP BY DayType;
-- 18 Which item has the highest number of transactions on weekdays?
select items , count(transactionno) as n from bakery where daytype = 'weekday' group by items,date(datetime) order by n desc limit 1;
-- 19 What is the median transaction count for each day part?
WITH RankedCounts AS (
    SELECT 
        Daypart,
        COUNT(*) AS TransactionCount,
        ROW_NUMBER() OVER (PARTITION BY Daypart ORDER BY COUNT(*) ASC) AS RowAsc,
        COUNT(*) OVER (PARTITION BY Daypart) AS TotalCount
    FROM bakery
    GROUP BY Daypart, Date(DateTime)
),
MedianCounts AS (
    SELECT
        Daypart,
        AVG(TransactionCount) AS MedianTransactionCount
    FROM RankedCounts
    WHERE RowAsc in ((TotalCount+1)/2,(TotalCount+2)/2)
    GROUP BY Daypart
)
SELECT
    Daypart,
    MedianTransactionCount
FROM MedianCounts;
-- 20 What day part has the least number of transactions?
select min(t) as minTransaction, daypart from(
select count(transactionno) as t , daypart from bakery group by daypart, date(datetime))t
group by daypart;
-- 30 Can you identify any patterns or trends in transaction frequency over time?
SELECT 
    Date(DateTime) AS Date,
    COUNT(*) AS DailyTransactionCount
FROM bakery
GROUP BY Date(DateTime)
ORDER BY Date(DateTime);

SELECT 
    YEARWEEK(Date(DateTime)) AS week,
    COUNT(*) AS DailyTransactionCount
FROM bakery
GROUP BY YEARWEEK(Date(DateTime))
ORDER BY week;

select hour(datetime) , count(*) from bakery group by hour(datetime) order by hour(datetime);

SELECT 
    DATE_FORMAT(Date(DateTime), '%Y-%m') AS Month,
    COUNT(*) AS MonthlyTransactionCount
FROM bakery
GROUP BY DATE_FORMAT(Date(DateTime), '%Y-%m')
ORDER BY Month;

-- 21 What is the peak hour for transactions during each day part?
with cte as(
select count(*) as t , hour(datetime) as h,daypart from bakery group by h , daypart),
cte1 as (
select max(t) as max_transaction,daypart from cte group by  daypart)
select max_transaction,c.daypart,h from cte1 c1 join cte c on c.t = c1.max_transaction;

-- 22  Are there any correlations between items and day types?
SELECT
    items,
    daytype,
    COUNT(*) AS TransactionCount
FROM bakery
GROUP BY items, daytype
ORDER BY items, daytype;

SELECT
    items,
    daytype,
    AVG(TransactionCount) AS AverageTransactionCount
FROM (
    SELECT
        items,
        daytype,
        COUNT(*) AS TransactionCount
    FROM bakery
    GROUP BY items, daytype, DATE(DateTime)
) AS DailyCounts
GROUP BY items, daytype
ORDER BY items, daytype;

-- 23 How do transactions vary with respect to daypart and day type?
SELECT
    Daypart,
    Daytype,
    COUNT(*) AS TransactionCount
FROM bakery
GROUP BY Daypart, Daytype
ORDER BY Daypart, Daytype;

SELECT
    Daypart,
    Daytype,
    AVG(DailyTransactionCount) AS AvgTransactionCount
FROM (
    SELECT
        Daypart,
        Daytype,
        DATE(DateTime) AS Date,
        COUNT(*) AS DailyTransactionCount
    FROM bakery
    GROUP BY Daypart, Daytype, Date
) AS DailyCounts
GROUP BY Daypart, Daytype
ORDER BY Daypart, Daytype;

SELECT
    Daypart,
    SUM(TransactionCount) AS TotalTransactionCount
FROM (
    SELECT
        Daypart,
        Daytype,
        COUNT(*) AS TransactionCount
    FROM bakery
    GROUP BY Daypart, Daytype
) AS AggregatedCounts
GROUP BY Daypart
ORDER BY Daypart;

-- 24  How do transaction patterns differ between weekdays and weekends for each item?  in sql

SELECT
    item,
    Daytype,
    COUNT(*) AS TotalTransactions
FROM bakery
GROUP BY item, Daytype
ORDER BY item, Daytype;

SELECT
    item,
    Daytype,
    AVG(DailyTransactionCount) AS AvgTransactionsPerDay
FROM (
    SELECT
        item,
        Daytype,
        DATE(DateTime) AS Date,
        COUNT(*) AS DailyTransactionCount
    FROM bakery
    GROUP BY item, Daytype, Date
) AS DailyCounts
GROUP BY item, Daytype
ORDER BY item, Daytype;


