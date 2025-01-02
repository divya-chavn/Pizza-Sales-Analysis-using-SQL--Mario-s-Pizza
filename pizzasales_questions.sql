use pizzahut
-- Retrieve the total number of orders placed.
select count(distinct order_id) as 'total_ordersPlaced' from dbo.orders;

--Calculate the total revenue generated from pizza sales.

select round(sum(det.quantity * piz.price),2) as 'total_revenue_from_pizzaSales'
from dbo.order_details as det
join dbo.pizzas as piz
on det.pizza_id = piz.pizza_id;

-- Identify the highest-priced pizza.

select top 1
typ.name,
piz.price
from dbo.pizza_types as typ
join dbo.pizzas as piz
on typ.pizza_type_id = piz.pizza_type_id
order by piz.price desc;

-- Identify the most common pizza size ordered.

select top 1
piz.size, count(det.order_id) as 'most_common size ordered'
from dbo.pizzas as piz
join dbo.order_details as det
on piz.pizza_id = det.pizza_id
group by piz.size
order by count(size) desc;

-- List the top 5 most ordered pizza types along with their quantities.

select top 5
typ.name,
sum(det.quantity) as 'Total_quantity'
from dbo.pizza_types as typ
join dbo.pizzas as piz on typ.pizza_type_id = piz.pizza_type_id
join dbo.order_details as det on piz.pizza_id = det.pizza_id
group by 
typ.name
order by sum(det.quantity) desc;

-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.

select
typ.category,
sum(det.quantity) as 'total quantity'
from dbo.pizza_types as typ
join dbo.pizzas as piz on typ.pizza_type_id = piz.pizza_type_id
join dbo.order_details as det on det.pizza_id = piz.pizza_id
group by
typ.category
order by 'total quantity' desc;

-- Determine the distribution of orders by hour of the day.

select 
datepart(hh, time) as 'hours', 
count(order_id) as 'orders/hrs' 
from dbo.orders
group by datepart(hh, time) 
order by count(order_id) desc;

-- Join relevant tables to find the category-wise distribution of pizzas.

select 
category,
count(name) as 'pizzas/category'
from dbo.pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(quantity) as "Avg pizzas ordered/day" 
from
(select 
ord.date,
sum(det.quantity) as "quantity"
from dbo.orders as ord
join dbo.order_details as det on ord.order_id = det.order_id
group by 
ord.date) 
as "order_quantity";


-- Determine the top 3 most ordered pizza types based on revenue.

select top 3
typ.name,
sum((det.quantity * piz.price)) as "Revenue"
from dbo.pizza_types as typ 
join dbo.pizzas as piz on typ.pizza_type_id = piz.pizza_type_id
join dbo.order_details as det on piz.pizza_id = det.pizza_id
group by 
typ.name
order by Revenue desc ;

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.

select
typ.category,
Round( sum((det.quantity * piz.price)) / (select sum(det.quantity * piz.price) 
from dbo.pizza_types as typ join dbo.pizzas as piz on typ.pizza_type_id = piz.pizza_type_id
join dbo.order_details as det on piz.pizza_id = det.pizza_id ) * 100, 2) as "Revenue"

from dbo.pizza_types as typ 
join dbo.pizzas as piz on typ.pizza_type_id = piz.pizza_type_id
join dbo.order_details as det on piz.pizza_id = det.pizza_id
group by 
typ.category
order by Revenue desc;


-- Analyze the cumulative revenue generated over time.

select date, sum(Revenue)
over(order by date) as "Cumulative Revenue"
from
(select 
ord.date,
sum((det.quantity * piz.price)) as "Revenue"
from dbo.order_details as det
join dbo.pizzas as piz on det.pizza_id = piz.pizza_id
join dbo.orders as ord on ord.order_id = det.order_id
group by
ord.date) 
as "sales";

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue
from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from
(select 
typ.category,
typ.name,
sum((det.quantity * piz.price)) as "revenue"
from dbo.pizza_types as typ
join dbo.pizzas as piz on typ.pizza_type_id = piz.pizza_type_id
join dbo.order_details as det on piz.pizza_id = det.pizza_id
group by 
typ.category,
typ.name ) as a) as b
where rn <= 3;


















