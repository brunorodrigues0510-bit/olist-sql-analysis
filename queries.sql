SELECT o.order_id, o.order_status, c.customer_city, c.customer_state
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
LIMIT 10;



SELECT o.order_id, o.order_status, c.customer_city, c.customer_state
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' and c.customer_state = 'SP'
LIMIT 10;



SELECT c.customer_city, COUNT(*) AS total_pedidos
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND c.customer_state = 'SP'
GROUP BY c.customer_city
ORDER BY total_pedidos DESC
LIMIT 10;





SELECT c.customer_city, sum (payment_value) as valor_total
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered' AND c.customer_state = 'SP'
GROUP BY c.customer_city
ORDER BY valor_total DESC
LIMIT 10;