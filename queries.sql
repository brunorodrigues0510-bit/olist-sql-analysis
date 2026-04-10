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





SELECT c.customer_state, COUNT (*) AS pedidos_totais
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY pedidos_totais DESC




SELECT c.customer_state, COUNT(*) AS pedidos_totais
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING pedidos_totais > 1000
ORDER BY pedidos_totais DESC




SELECT c.customer_state, COUNT(*) AS pedidos_totais
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING pedidos_totais > 5000 AND c.customer_state != 'SP'
ORDER BY pedidos_totais DESC




SELECT c.customer_state, AVG(payment_value) AS media
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING media > 150
ORDER BY media DESC
