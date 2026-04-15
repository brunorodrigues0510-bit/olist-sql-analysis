-- Nessa query, utilizando JOIN pela coluna customer_id, trouxemos informações de pedido, status, cidade e estado como base, para a próxima query filtrar pedidos entregues em SP
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




-- Utilizei essa query para descobrir as 10 cidades com maior montante de vendas totais em SP, considerando apenas pedidos entregues
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



-- Utilizei subqueries para descobrir de quais cidades foram os clientes que tiveram pagamento maior que a média geral da plataforma
SELECT DISTINCT c.customer_city, c.customer_state
FROM olist_customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM olist_orders o
    JOIN olist_order_payments p ON o.order_id = p.order_id
    WHERE p.payment_value > (
        SELECT AVG(payment_value)
        FROM olist_order_payments
    )
)
LIMIT 10;  
