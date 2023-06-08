CREATE DATABASE pizza_sales;
USE pizza_sales;

# merge columns
SELECT 
    order_id, CONCAT(date, ' ', time) date_and_time
FROM
    orders; 

# Change datetype
ALTER TABLE orders Modify column date_and_time DATETIME;
ALTER TABLE pizzas Modify column pizza_id varchar(20);
ALTER TABLE pizzas Modify column pizza_type_id varchar(20);
ALTER TABLE pizza_types Modify column pizza_type_id varchar(20);
ALTER TABLE order_details Modify column pizza_id varchar(20);

#Q1 What is the total number of orders placed within a specific time period?
SELECT 
    MONTHNAME(date_and_time) months,
    COUNT(order_id) total_orders
FROM
    orders
GROUP BY months;

#Q2 What is the average quantity of pizzas ordered per order?
SELECT 
    AVG(quantity) avg_quantity
FROM
    order_details;
    
#Q3 Which pizza type is the most popular among customers?
SELECT 
    pt.name most_popular, 
    COUNT(o.order_id) total_orders
FROM
    orders o
        JOIN
    order_details od ON od.order_id = o.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY most_popular
ORDER BY total_orders DESC;

#Q4 What is the total revenue generated from pizza orders?
SELECT 
    ROUND(SUM(p.price * od.quantity)) total_revenue
FROM
    order_details od
		JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

#Q5 How does the average order quantity vary based on the pizza size?
SELECT 
    p.size, ROUND(AVG(od.quantity), 2) avg_order_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size;

#Q6 Which category of pizzas (Classic, Chicken, Supreme, Veggie) has the highest sales?
SELECT 
    pt.category, SUM(od.quantity) sales
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category
ORDER BY sales DESC;

#Q7 How does the average price per pizza vary based on the pizza size?
SELECT 
    p.size, ROUND(AVG(p.price),2) avg_price
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size;

#Q8 How does the revenue from pizza orders vary by date or month?
SELECT 
    MONTHNAME(date_and_time) months,
    ROUND(SUM(p.price * od.quantity)) revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY months;

#Q9 Which ingredients are most commonly used across all pizza types?
SELECT 
    pt.ingredients, COUNT(od.order_id) commonly_used
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.ingredients
ORDER BY commonly_used DESC;

#Q10 What are the top most frequently ordered pizzas per month?
WITH total AS(
SELECT 
    MONTH(date_and_time) months,
    pt.name,
    COUNT(od.quantity) quantity,
    ROW_NUMBER() OVER(PARTITION BY MONTH(date_and_time) order BY COUNT(od.quantity) DESC) AS r_n
FROM
    orders o
        JOIN
    order_details od ON od.order_id = o.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY months, pt.name
ORDER BY months ASC, quantity DESC
	)
SELECT months, name FROM total WHERE r_n = 1;