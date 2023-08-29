--Create a temporary table that joins the orders, order_products, and products tables to get information about each order,
--including the products that were purchased and their department and aisle information.
CREATE TEMPORARY TABLE order_info AS
SELECT o.order_id, o.order_number, o.order_dow, o.order_hour_of_day,
       op.product_id, op.add_to_cart_order, op.reordered,
	   p.product_name, p.aisle_id, p.department_id	   
FROM orders AS o
JOIN order_products AS op
ON o.order_id = op.order_id
JOIN products AS p
ON op.product_id = p.product_id;

--Create a temporary table that groups the orders by product and finds the total number of times each product was purchased,
--the total number of times each product was reordered, and the average number of times each product was added to a cart.

CREATE TEMPORARY TABLE product_order_summary AS 
SELECT product_id, product_name, COUNT(order_id)as total_orders,
       COUNT(CASE WHEN reordered > 0 THEN 1 ELSE NULL END) as total_reordered,
	   CAST(AVG(add_to_cart_order) AS INTEGER) AS avg_add_to_cart
FROM order_info 
GROUP BY  product_id, product_name;


--Create a temporary table that groups the orders by department and finds the total number of products purchased, 
--the total number of unique products purchased, the total number of products purchased on weekdays vs weekends,and 
--the average time of day that products in each department are ordered.

CREATE TEMPORARY TABLE department_order_summary AS
SELECT department_id, COUNT(order_id) as total_orders, COUNT(product_id) as total_products_purchase,
       COUNT(DISTINCT(product_id)) as total_unique_product,
	   COUNT(CASE WHEN order_dow < 6 THEN 1 ELSE NULL END) AS product_purchase_on_weekdays,
	   COUNT(CASE WHEN order_dow >= 6 THEN 1 ELSE NULL END) AS product_purchase_on_weekend,
       CAST(AVG(order_hour_of_day) AS INTEGER) as avg_order_hour_of_day
FROM order_info
GROUP BY department_id;


--Create a temporary table that groups the orders by aisle and finds the top 10 most popular aisles, 
--including the total number of products purchased and the total number of unique products purchased from each aisle.

CREATE TEMPORARY TABLE aisle_order_summary AS
SELECT aisle_id, 
       COUNT(product_id) AS total_product_purchase,
	   COUNT(DISTINCT(product_id)) AS unique_product_purchase
FROM order_info
GROUP BY aisle_id
ORDER BY COUNT(*) DESC
LIMIT 10;

--Combine the information from the previous temporary tables into a 
--final table that shows the product ID, product name, department ID, department name, aisle ID, aisle name, total number of times purchased, 
--total number of times reordered, average number of times added to cart, 
--total number of products purchased, total number of unique products purchased, 
--total number of products purchased on weekdays, 
--total number of products purchased on weekends, and average time of day products are ordered in each department.


SELECT oi.product_id, oi.product_name, oi.department_id, d.department, oi.aisle_id, aisle,
       pos.total_orders, pos.total_reordered, pos.avg_add_to_cart,
	   dos.total_products_purchase, dos.total_unique_product, dos.product_purchase_on_weekdays, dos.product_purchase_on_weekend,
	   dos.avg_order_hour_of_day
       
FROM order_info AS oi
JOIN product_order_summary AS pos ON oi.product_id = pos.product_id
JOIN department_order_summary AS dos ON oi.department_id = dos.department_id
JOIN departments AS d ON oi.department_id = d.department_id
JOIN aisle ON oi.aisle_id = aisle.aisle_id





