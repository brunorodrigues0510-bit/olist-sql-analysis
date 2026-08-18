-- ============================================================
-- BLOCO 1 — Fundamentos: distribuição geográfica e faturamento
-- ============================================================
 
-- 1. Exploração inicial: pedidos + cidade/estado do cliente
-- Nessa query, utilizando JOIN pela coluna customer_id, trouxemos informações
-- de pedido, status, cidade e estado como base, para a próxima query filtrar
-- pedidos entregues em SP
SELECT o.order_id, o.order_status, c.customer_city, c.customer_state
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
LIMIT 10;
 
-- 2. Mesma base, filtrando pedidos entregues em SP
SELECT o.order_id, o.order_status, c.customer_city, c.customer_state
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND c.customer_state = 'SP'
LIMIT 10;
 
-- 3. Cidades com mais clientes em SP
SELECT c.customer_city, COUNT(*) AS total_pedidos
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND c.customer_state = 'SP'
GROUP BY c.customer_city
ORDER BY total_pedidos DESC
LIMIT 10;
 
-- 4. Valor total de pedidos entregues por cidade em SP
-- Utilizei essa query para descobrir as 10 cidades com maior montante de
-- vendas totais em SP, considerando apenas pedidos entregues
SELECT c.customer_city, SUM(payment_value) AS valor_total
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered' AND c.customer_state = 'SP'
GROUP BY c.customer_city
ORDER BY valor_total DESC
LIMIT 10;
 
-- 5. Total de pedidos por estado (todos os status)
SELECT c.customer_state, COUNT(*) AS pedidos_totais
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY pedidos_totais DESC;
 
-- 6. Estados com mais de 1.000 pedidos
SELECT c.customer_state, COUNT(*) AS pedidos_totais
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING pedidos_totais > 1000
ORDER BY pedidos_totais DESC;
 
-- 7. Estados com mais de 5.000 pedidos, excluindo SP
SELECT c.customer_state, COUNT(*) AS pedidos_totais
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING pedidos_totais > 5000 AND c.customer_state != 'SP'
ORDER BY pedidos_totais DESC;
 
-- 8. Ticket médio por estado (versão inicial, sem tratamento de fan-out)
-- Observação: essa query tem uma limitação identificada depois no Bloco 2,
-- item 9 — um pedido pode ter mais de uma linha em order_payments, o que
-- pode distorcer o AVG. Mantida aqui como registro da evolução do estudo.
SELECT c.customer_state, AVG(payment_value) AS media
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
HAVING media > 150
ORDER BY media DESC;
 
-- 9. Clientes com pagamento acima da média geral da plataforma
-- Utilizei subqueries para descobrir de quais cidades foram os clientes que
-- tiveram pagamento maior que a média geral da plataforma
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
 
 
-- ============================================================
-- BLOCO 2 — JOINs com fan-out, CTEs e qualidade de métrica
-- ============================================================
 
-- 10. Nota média de review por categoria de produto
-- Pergunta de negócio: qual a nota média de avaliação por categoria de
-- produto, considerando só pedidos entregues e categorias com mais de
-- 100 pedidos?
--
-- Problema identificado: JOIN direto entre order_items (N itens por pedido)
-- e order_reviews (pode ter mais de 1 review por pedido) causa fan-out —
-- duplicação de linhas que infla COUNT(*) e pode distorcer a base do AVG.
--
-- Solução: CTE pré-agregando a nota média por pedido antes do JOIN com os
-- itens, garantindo 1 linha de nota por pedido.
WITH reviews_por_pedido AS (
    SELECT order_id, AVG(review_score) AS nota_pedido
    FROM olist_order_reviews
    GROUP BY order_id
)
SELECT product_category_name, COUNT(*), AVG(price), AVG(nota_pedido) AS nota_media
FROM olist_order_items
JOIN olist_products
    ON olist_order_items.product_id = olist_products.product_id
JOIN olist_orders
    ON olist_order_items.order_id = olist_orders.order_id
JOIN reviews_por_pedido
    ON reviews_por_pedido.order_id = olist_order_items.order_id
WHERE order_status = 'delivered'
GROUP BY product_category_name
HAVING COUNT(*) > 100
ORDER BY nota_media;
 
-- 11. Ticket médio por estado do cliente (versão corrigida)
-- Pergunta de negócio: qual o valor médio pago por pedido, por estado do
-- cliente, considerando só pedidos entregues?
--
-- Problema identificado: um pedido pode ter várias linhas em
-- order_payments (ex: pagamento parcial em voucher + cartão de crédito),
-- e cada linha representa só uma parte do valor total — o mesmo tipo de
-- fan-out do item 10, aplicado a pagamentos.
--
-- Solução: CTE somando o valor total pago por pedido (SUM) antes de juntar
-- e calcular a média por estado (AVG).
WITH valor_total_pago AS (
    SELECT order_id, SUM(payment_value) AS total_do_pedido
    FROM olist_order_payments
    GROUP BY order_id
)
SELECT customer_state, AVG(total_do_pedido) AS total_do_pedido_final
FROM olist_orders
JOIN olist_customers
    ON olist_customers.customer_id = olist_orders.customer_id
JOIN valor_total_pago
    ON valor_total_pago.order_id = olist_orders.order_id
WHERE order_status = 'delivered'
GROUP BY customer_state
ORDER BY total_do_pedido_final DESC;
 
-- 12. Tempo médio de entrega por vendedor (seller)
-- Pergunta de negócio: quais vendedores têm o maior tempo médio de entrega
-- (aprovação do pagamento até a entrega ao cliente), considerando só
-- pedidos entregues?
--
-- Cálculo: datas armazenadas como TEXT, convertidas com JULIANDAY() para
-- obter a diferença em dias entre order_approved_at e
-- order_delivered_customer_date.
--
-- Problema identificado (1): "ambiguous column name" — seller_id existe em
-- olist_sellers e olist_order_items. Resolvido especificando tabela.coluna.
--
-- Problema identificado (2): sellers com poucos pedidos (1 ou 2) geravam
-- médias extremas (até 189 dias) por causa de um único caso isolado, sem
-- volume para diluir o número. Resolvido filtrando sellers com mais de 20
-- pedidos via HAVING, reduzindo a base de ~2.970 para 855 sellers e trazendo
-- o range de tempo médio para valores realistas (4 a 31 dias).
SELECT
    olist_sellers.seller_id,
    AVG(julianday(order_delivered_customer_date) - julianday(order_approved_at)) AS tempo_medio_entrega,
    COUNT(olist_sellers.seller_id) AS qtd_pedidos
FROM olist_sellers
JOIN olist_order_items
    ON olist_order_items.seller_id = olist_sellers.seller_id
JOIN olist_orders
    ON olist_orders.order_id = olist_order_items.order_id
WHERE order_status = 'delivered'
GROUP BY olist_sellers.seller_id
HAVING qtd_pedidos > 20
ORDER BY tempo_medio_entrega DESC;

-- 13. Frete médio por categoria de produto
Pergunta: qual o frete médio por categoria de produto, considerando só pedidos entregues?
Técnicas: JOIN (3 tabelas), AVG, GROUP BY, WHERE, ORDER BY
-- Observação: diferente das análises anteriores (review e pagamento), aqui não existe fan-out
-- Cada linha de order_items já representa um item físico com seu próprio frete alocado, não uma informação duplicada por JOIN.
-- Investiguei isso comparando pedidos com múltiplos itens e confirmando que os valores de frete variam por item, não se repetem artificialmente
SELECT product_category_name, AVG(freight_value) AS media_do_frete
FROM olist_order_items
JOIN olist_products
	ON olist_products.product_id = olist_order_items.product_id
JOIN olist_orders
	ON olist_orders.order_id = olist_order_items.order_id
WHERE order_status = 'delivered'
GROUP BY product_category_name
ORDER BY media_do_frete DESC
