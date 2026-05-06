--1. Get the number of orders placed by C_001, C_002, C_003. All the three customer_ids
--   and the numbers of orders should be present in the result separately.
select customer_id, count(order_id) as orders_count
from Orders
where customer_id in ('c_001', 'c_002', 'c_003')
group by customer_id

--2. Which customer_id has the highest spends?
select top 1 customer_id, sum(amount_paid) as Spend
from Orders
group by customer_id
order by Spend DESC

-- 3. Which product_id has been bought the most?
select top 5 product_id, count(order_id) as Order_Count
from Orders
 group by product_id
 order by Order_Count desc

-- 4. Which product_id has generated the highest revenue?
select top 1 product_id, sum(amount_paid) as Revenue
from Orders
group by product_id
order by Revenue desc

-- 5. In our inventory, which product category has the lowest no of items? Which should
--    we add more of?
select category, product_name, sum(amount_paid) as order_count
from Products as P
inner join Orders as O
on P.product_id = O.product_id
group by category, product_name
order by category, order_count desc

-- 6. What is the cheapest price in each of the product category?
SELECT *
FROM (
	select category, product_name, price,
	DENSE_RANK() OVER( PARTITION BY CATEGORY ORDER BY PRICE ASC) AS RANKS
	from Products
) AS x
WHERE RANKS = 1

-- 7. Month on Month count of orders & revenue
SELECT DATEPART(MONTH, order_datetimestamp) AS MONTHS, 
FORMAT(order_datetimestamp, 'MMMM') AS MONTH_NAMES,
COUNT(order_id) AS ORDER_COUNT,SUM(amount_paid) AS REVENUE
FROM Orders
GROUP BY DATEPART(MONTH, order_datetimestamp), FORMAT(order_datetimestamp, 'MMMM')

-- 8. Month on Month count of sign ups
SELECT DATEPART(MONTH, created_at) AS MONTHS, COUNT(cusomter_id) AS SIGN_UPS
FROM Users
GROUP BY DATEPART(MONTH, created_at)

-- 9. Figure out who purchased the highest in each month.
SELECT MONTHS, customer_id, PURCHASE
FROM (
	SELECT MONTH(order_datetimestamp) AS MONTHS, customer_id, SUM(amount_paid) AS PURCHASE,
	DENSE_RANK() OVER(PARTITION BY MONTH(order_datetimestamp) 
					  ORDER BY SUM(AMOUNT_PAID) DESC) AS RANKS
	FROM Orders
	GROUP BY MONTH(order_datetimestamp), customer_id
) AS X
WHERE RANKS = 1

-- 10. Get the list of customer_ids which has spends more than 100
SELECT customer_id, SUM(amount_paid) AS SPEND
FROM Orders
GROUP BY customer_id
HAVING SUM(amount_paid) > 100

--11. Get the month with revenue more than 2100 and orders volume more than 30
SELECT MONTH(order_datetimestamp) AS MONTHS, SUM(amount_paid) AS REVENUE,
COUNT(order_id) AS ORDER_VOLUME
FROM Orders
GROUP BY MONTH(order_datetimestamp)
HAVING SUM(amount_paid) > 2100
		   AND
       COUNT(order_id) > 30

-- 12. Get the numbers of orders placed by each customer in month of Jan.
SELECT customer_id, COUNT(order_id) AS ORDER_COUNT
FROM Orders
WHERE MONTH(order_datetimestamp) = 1
GROUP BY customer_id

-- 13. Get the name of the customer who has spent the most with us
SELECT TOP 1 U.cusomter_id ,CONCAT(first_name, ' ', last_name) AS CUST_NAME, 
SUM(amount_paid) AS SPEND
FROM Users AS U
INNER JOIN Orders AS O
ON U.cusomter_id = O.customer_id
GROUP BY U.cusomter_id , CONCAT(first_name, ' ', last_name)
ORDER BY SPEND DESC

-- 14. Get all the users who has not purchased any orders.
select u.*
from Users as u
left join Orders as o
on u.cusomter_id = o.customer_id
where order_id is null

-- 15. For the customer has spent the most, figure out which product category have they 
--     spent the most

select top 1  customer_id, category, sum(amount_paid) as Spend
from Products as P
inner join Orders as O
on P.product_id = o.product_id
where customer_id in (
				select top 1 customer_id --, sum(amount_paid) as Spend
				from Orders
				group by customer_id
				order by sum(amount_paid) desc
)
group by customer_id, category
order by Spend desc