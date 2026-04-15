Análise de Dados — Dataset Olist com SQL
Projeto de estudos de SQL utilizando o Brazilian E-Commerce Public Dataset by Olist, disponível no Kaggle.
O dataset contém dados reais de aproximadamente 100 mil pedidos realizados entre 2016 e 2018 em múltiplos marketplaces do Brasil.
Ferramentas utilizadas

SQLite
DB Browser for SQLite

Estrutura do dataset
O banco de dados é composto por 9 tabelas relacionadas:
TabelaDescriçãoolist_ordersPedidos (status, datas)olist_order_itemsItens de cada pedido (preço, frete)olist_order_paymentsPagamentos (tipo, parcelas, valor)olist_order_reviewsAvaliações dos clientesolist_customersClientes (cidade, estado)olist_sellersVendedoresolist_productsProdutos (categoria, dimensões)olist_geolocationCEPs com coordenadas geográficasproduct_category_name_translationTradução das categorias pt → en
Análises realizadas
1. Distribuição de clientes por estado
Total de clientes agrupados por estado, ordenado do maior para o menor.
Técnicas: JOIN, COUNT, GROUP BY, ORDER BY
2. Cidades com mais clientes em SP
Ranking das cidades do estado de São Paulo com maior número de clientes.
Técnicas: JOIN, COUNT, GROUP BY, WHERE, ORDER BY
3. Pedidos entregues por cidade em SP
Total de pedidos com status delivered por cidade no estado de SP.
Técnicas: JOIN, COUNT, GROUP BY, WHERE, ORDER BY
4. Valor total de pedidos entregues por cidade em SP
Análise de faturamento por cidade — quais cidades de SP geraram mais receita em pedidos entregues.
Técnicas: JOIN (3 tabelas), SUM, GROUP BY, WHERE, ORDER BY
5. Filtro por volume mínimo de pedidos (HAVING)
Estados com mais de 1.000 e mais de 5.000 pedidos, excluindo SP.
Técnicas: JOIN, COUNT, GROUP BY, HAVING, ORDER BY
6. Ticket médio por estado
Valor médio de pedido por estado, considerando apenas pedidos entregues e estados com média acima de R$ 150.
Técnicas: JOIN (3 tabelas), AVG, GROUP BY, WHERE, HAVING, ORDER BY
7. Clientes acima da média geral de valor
Cidades dos clientes que realizaram pelo menos um pedido acima do valor médio geral da plataforma.
Técnicas: Subquery aninhada, AVG, IN, DISTINCT
Conceitos praticados

SELECT, WHERE, GROUP BY, ORDER BY, LIMIT
COUNT, SUM, AVG
JOIN com múltiplas tabelas
HAVING
Subqueries (incluindo subquery dentro de subquery)
DISTINCT
Aliases de tabelas e colunas (AS)
