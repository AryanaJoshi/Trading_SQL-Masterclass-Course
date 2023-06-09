--What is the earliest and latest date of transactions for all members?
SELECT MAX(txn_date) ,MIN (txn_date)
FROM dbo.transactions
------------------------------------
--What is the range of market_date values available in the prices data?
SELECT MIN(market_date) , MAX(market_date)
FROM dbo.prices
-----------------------------------------
--.Which top 3 mentors have the most Bitcoin quantity as of the 29th of August?

SELECT mem.member_id,mem.first_name
,SUM(CASE WHEN trans.txn_type = 'BUY' Then trans.quantity
WHEN trans.txn_type ='SELL' Then -trans.quantity END) "Quantity"

FROM dbo.members mem

RIGHT JOIN dbo.transactions trans
ON mem.member_id = trans.member_id

WHERE  trans.ticker ='BTC'
GROUP BY mem.member_id,mem.first_name
ORDER BY 3 DESC
LIMIT 3
------------------------------------------
--What is total value of all Ethereum portfolios for each region at the end date? Order the output by descending portfolio value.

WITH cte_finalprice as (
  SELECT ticker,price "price"
  FROM dbo.prices
  WHERE ticker ='ETH'
  AND market_date = '2021-08-29'
  )
   SELECT mem.region
  ,SUM 
  (CASE WHEN trans.txn_type ='BUY' THEN trans.quantity
   		WHEN trans.txn_type ='SELL' THEN -trans.quantity END) * fp.price "Total_ETH_Value"
      
  FROM dbo.transactions trans
  
  INNER JOIN cte_finalprice fp
  ON trans.ticker = fp.ticker
  
  INNER JOIN dbo.members mem
  ON trans.member_id = mem.member_id
  
  WHERE trans.ticker = 'ETH'
  
  GROUP BY mem.region,fp.price
  ORDER BY 2 DESC
  -------------------------------------
 --What is the average value of each Ethereum portfolio in each region? Sort this output in descending order.
 
WITH cte_finalprice as (
  SELECT ticker,price "price"
  FROM dbo.prices
  WHERE ticker ='ETH'
  AND market_date = '2021-08-29'
  ),
   
 cte_calculation as (
   SELECT mem.region
  ,SUM 
  (CASE WHEN trans.txn_type ='BUY' THEN trans.quantity
   		WHEN trans.txn_type ='SELL' THEN -trans.quantity END) * fp.price "Total_ETH_Value"
  ,COUNT(DISTINCT mem.member_id) "Mentor_Count"
  FROM dbo.transactions trans
  
  INNER JOIN cte_finalprice fp
  ON trans.ticker = fp.ticker
  
  INNER JOIN dbo.members mem
  ON trans.member_id = mem.member_id
  
  WHERE trans.ticker = 'ETH'
  GROUP BY mem.region,fp.price
  )
  SELECT *
  ,"Total_ETH_Value" / "Mentor_Count" as "Avg_ETH_Value"
  FROM cte_calculation
  ORDER BY "Avg_ETH_Value" DESC
 -------------------------------------------