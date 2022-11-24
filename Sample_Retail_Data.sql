--- Preview the tables
select  TOP 100 * from SalesLT.SalesOrderDetail
select TOP 100 *  from SalesLT.SalesOrderHeader
select TOP 100 * from SalesLT.Product

select TOP 100 * from SalesLT.Product
where Name like '%Sport-100%'

--- Find the years that the sales data spans
select distinct year(OrderDate) as Year_Data from SalesLT.SalesOrderHeader

-- Finding the total number of orders
select count(1) as total_number_of_orders from SalesLT.SalesOrderDetail

-- Find the products customers ordered
select p.Name items_ordered, count(1) as Quantity from SalesLT.SalesOrderDetail s
inner join SalesLT.Product p
on s.ProductID=p.ProductID
group by p.Name 
order by count(1) desc

-- Find the products customers didnt order
select p.Name as items_not_ordered from SalesLT.SalesOrderDetail s
right join SalesLT.Product p
on s.ProductID=p.ProductID
where s.SalesOrderID is null
group by p.Name 
order by count(1) desc

--- Product revenues as a percentage of the total revenue

with revenue as (
    select p.Name,
    count(1) as total_items_sold,
    ((sum(s.LineTotal)/(select sum(LineTotal) from SalesLT.SalesOrderDetail))*100) as Percentage_of_Total_revenue
    from SalesLT.SalesOrderDetail s
    join SalesLT.Product p
    on s.ProductID=p.ProductID
    group by p.Name
)

select *,(Percentage_of_Total_revenue/total_items_sold) as percentage_per_item from revenue
order by  (Percentage_of_Total_revenue/total_items_sold) desc

--- Cost of item ordered  against the price sold and profit made per sale
select p.Name,p.StandardCost,od.UnitPrice as Price_Sold_For,od.OrderQty,(od.UnitPrice-p.StandardCost) as Profit
from SalesLT.Product p
inner join SalesLT.SalesOrderDetail od 
on od.ProductID=p.ProductID
where p.ProductID in (select ProductID from SalesLT.SalesOrderDetail)

--Total cost of Items sold

select p.Name,p.StandardCost,od.UnitPrice,od.OrderQty,(od.UnitPrice-p.StandardCost) as Profit
into #cost_table
from SalesLT.Product p
inner join SalesLT.SalesOrderDetail od 
on od.ProductID=p.ProductID
where p.ProductID in (select ProductID from SalesLT.SalesOrderDetail)
DECLARE @TOTAL_COST FLOAT
SET @TOTAL_COST =(select sum(e.OrderQty*e.StandardCost) as total_cost from #cost_table e)
PRINT 'TOTAL COST: ' + CAST(@TOTAL_COST AS VARCHAR)


--Total revenue collected per product
select coalesce(p.Name,'Totals'),sum(s.LineTotal) as Total_Revenue 
from SalesLT.SalesOrderDetail s
join SalesLT.Product p
on s.ProductID=p.ProductID
group by
    cube(p.Name)
order by sum(s.LineTotal) asc

--Total revenue collected 
DECLARE @TOTAL_SALES FLOAT
SET @TOTAL_SALES =(select sum(od.LineTotal) as Total_revenue_collected from SalesLT.SalesOrderDetail od )
PRINT 'TOTAL SALES: ' + CAST(@TOTAL_SALES AS VARCHAR)

--Total profit/loss made
DECLARE @TOTAL_COST FLOAT
SET @TOTAL_COST =(select sum(e.OrderQty*e.StandardCost) as total_cost from #cost_table e)
PRINT 'TOTAL COST: ' + CAST(@TOTAL_COST AS VARCHAR)

DECLARE @TOTAL_SALES FLOAT
SET @TOTAL_SALES =(select sum(od.LineTotal) as Total_revenue_collected from SalesLT.SalesOrderDetail od )
PRINT 'TOTAL SALES: ' + CAST(@TOTAL_SALES AS VARCHAR)

IF @TOTAL_SALES>@TOTAL_COST 
BEGIN  
    PRINT 'PROFIT MADE: ' + CAST((@TOTAL_SALES-@TOTAL_COST) AS VARCHAR)
END
IF  @TOTAL_SALES<@TOTAL_COST
BEGIN  
    PRINT 'LOSS MADE: ' + CAST((@TOTAL_COST-@TOTAL_SALES) AS VARCHAR)
END
ELSE
BEGIN 
    PRINT 'BREAK EVEN POINT:'
END





