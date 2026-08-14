Análise de Dados — Dataset Olist com SQL

Projeto de estudos de SQL utilizando o Brazilian E-Commerce Public Dataset by Olist, disponível no Kaggle. O dataset contém dados reais de aproximadamente 100 mil pedidos realizados entre 2016 e 2018 em múltiplos marketplaces do Brasil.

Ferramentas utilizadas
SQLite / DB Browser for SQLite
Estrutura do dataset

O banco de dados é composto por 9 tabelas relacionadas:

Tabela	Descrição
olist_orders	Pedidos (status, datas)
olist_order_items	Itens de cada pedido (preço, frete, vendedor)
olist_order_payments	Pagamentos (tipo, parcelas, valor)
olist_order_reviews	Avaliações dos clientes
olist_customers	Clientes (cidade, estado)
olist_sellers	Vendedores
olist_products	Produtos (categoria, dimensões)
olist_geolocation	CEPs com coordenadas geográficas
product_category_name_translation	Tradução das categorias pt → en
Análises realizadas
Bloco 1 — Fundamentos: distribuição geográfica e faturamento

1. Distribuição de clientes por estado Total de clientes agrupados por estado, ordenado do maior para o menor. Técnicas: JOIN, COUNT, GROUP BY, ORDER BY

2. Cidades com mais clientes em SP Ranking das cidades do estado de São Paulo com maior número de clientes. Técnicas: JOIN, COUNT, GROUP BY, WHERE, ORDER BY

3. Pedidos entregues por cidade em SP Total de pedidos com status delivered por cidade no estado de SP. Técnicas: JOIN, COUNT, GROUP BY, WHERE, ORDER BY

4. Valor total de pedidos entregues por cidade em SP Análise de faturamento por cidade — quais cidades de SP geraram mais receita em pedidos entregues. Técnicas: JOIN (3 tabelas), SUM, GROUP BY, WHERE, ORDER BY

5. Filtro por volume mínimo de pedidos Estados com mais de 1.000 e mais de 5.000 pedidos, excluindo SP. Técnicas: JOIN, COUNT, GROUP BY, HAVING, ORDER BY

6. Ticket médio por estado (versão inicial) Valor médio de pedido por estado, considerando apenas pedidos entregues e estados com média acima de R$ 150. Técnicas: JOIN (3 tabelas), AVG, GROUP BY, WHERE, HAVING, ORDER BY

7. Clientes acima da média geral de valor Cidades dos clientes que realizaram pelo menos um pedido acima do valor médio geral da plataforma. Técnicas: Subquery aninhada, AVG, IN, DISTINCT

Bloco 2 — JOINs com fan-out, CTEs e qualidade de métrica

Nessa etapa, o foco passou a ser identificar e corrigir distorções silenciosas causadas por JOINs entre tabelas com relação um-para-muitos — um problema que não gera erro no SQL, mas infla contagens e pode enviesar médias.

8. Nota média de avaliação por categoria de produto Pergunta: qual categoria de produto tem a melhor/pior nota média de review, considerando só pedidos entregues e categorias com mais de 100 pedidos? Problema identificado: JOIN direto entre order_items e order_reviews causa fan-out (1 pedido com N itens × N reviews gera linhas duplicadas), inflando COUNT(*) e distorcendo a base de cálculo do AVG. Solução: CTE pré-agregando a nota média por pedido antes do JOIN com os itens. Técnicas: JOIN (4 tabelas), CTE (WITH), AVG, COUNT, GROUP BY, HAVING Observação: a granularidade do review é por pedido, não por produto — quando um pedido tem produtos de categorias diferentes, a nota "vaza" para todas elas. Limitação do dado, não corrigível via SQL.

9. Ticket médio por estado do cliente (versão corrigida) Pergunta: qual o valor médio pago por pedido, por estado do cliente? Problema identificado: um pedido pode ter várias linhas em order_payments (ex: pagamento parcial em voucher + cartão), causando o mesmo tipo de fan-out. Solução: CTE somando o valor total pago por pedido (SUM) antes de calcular a média por estado (AVG). Técnicas: JOIN, CTE (WITH), SUM, AVG, GROUP BY, ORDER BY Observação: identificado que colunas fora do GROUP BY/agregação no ORDER BY rodam no SQLite sem erro, mas com resultado não confiável (bancos mais rígidos bloqueiam isso).

10. Tempo médio de entrega por vendedor (seller) Pergunta: quais vendedores têm o maior tempo médio de entrega (aprovação do pagamento → entrega ao cliente)? Técnicas: JOIN (3 tabelas), JULIANDAY (cálculo de diferença de datas), AVG, COUNT, GROUP BY, HAVING, ORDER BY Observações:

Erro de coluna ambígua (seller_id existe em duas tabelas do JOIN) — resolvido especificando tabela.coluna.
Sellers com poucos pedidos (1 ou 2) apresentavam médias extremas (até 189 dias) por causa de casos isolados sem volume para diluir. Resolvido com HAVING qtd_pedidos > 20, reduzindo a base de ~2.970 para 855 sellers e trazendo o range para valores realistas (4–31 dias).
Conceitos praticados
SELECT, WHERE, GROUP BY, ORDER BY, LIMIT
COUNT, SUM, AVG, JULIANDAY
JOIN com múltiplas tabelas
HAVING
Subqueries (incluindo subquery dentro de subquery)
DISTINCT
Aliases de tabelas e colunas (AS)
CTE (WITH ... AS) para pré-agregação e resolução de fan-out
Identificação de distorções em métricas agregadas: fan-out por JOIN e amostras pequenas (baixo volume por grupo)
