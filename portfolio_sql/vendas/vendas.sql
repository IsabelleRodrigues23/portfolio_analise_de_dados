-- =============================================================================
-- PROJETO: Análise Comercial e de Vendas (Sales Analytics)
-- BANCO DE DADOS: AdventureWorks 2022 (SQL Server / T-SQL)
-- AUTOR: Isabelle
-- DESCRIÇÃO:
-- Análise de performance de vendas: receita, sazonalidade, ticket médio,
-- ranking de produtos por território e tempo de envio dos pedidos.

-- TABELAS UTILIZADAS:
--   Sales.SalesOrderHeader — pedidos (data, valor total, território)
--   Sales.SalesOrderDetail — itens do pedido (quantidade, produto)
--   Production.Product — nome do produto
--   Sales.SalesTerritory — nome do território
-- =============================================================================

-- =============================================================================
-- PERGUNTAS DE NEGÓCIO RESPONDIDAS:
-- 1. Qual a receita total por ano?
-- 2. Quais os 10 produtos mais vendidos em quantidade?
-- 3. Qual território vende mais?
-- 4. Qual o ticket médio por pedido?
-- 5. Existe sazonalidade nas vendas por mês (agregando todos os anos)?
-- 6. Qual a variação % de receita mês a mês?
-- 7. Qual o tempo médio (em dias) entre o pedido e o envio, por território?
-- =============================================================================



-- 1. Receita total por ano.

SELECT
	YEAR(OrderDate) AS Ano,
	SUM(TotalDue) AS ReceitaTotal
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY Ano;


-- 2. 10 produtos mais vendidos em quantidade.

SELECT TOP 10
	p.Name AS Produto,
	SUM(sod.OrderQty) AS QuantidadeVendida
FROM sales.SalesOrderDetail AS sod
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY QuantidadeVendida DESC;


-- 3. Território que mais vendem.
 
 SELECT
	t.Name AS Territorio,
	SUM(soh.TotalDue) AS ReceitaTotal
FROM Sales.SalesOrderHeader AS soh
INNER JOIN sales.SalesTerritory t ON soh.TerritoryID = t.TerritoryID
GROUP BY t.Name
ORDER BY ReceitaTotal DESC;


-- 4. Ticket médio por pedido.

SELECT
	AVG(TotalDue) AS TicketMedio
FROM SALES.SalesOrderHeader;


-- 5. Sazonalidade nas vendas por mês (agregando todos os anos).

SELECT 
	MONTH(OrderDate) AS Mes,
	SUM(TotalDue) AS ReceitaTotal
FROM sales.SalesOrderHeader
GROUP BY MONTH(OrderDate)
ORDER BY Mes;


-- 6. Variação % de receita mês a mês.

WITH ReceitaMensal AS (
SELECT
	YEAR(OrderDate) AS Ano,
	MONTH(OrderDate) AS Mes,
	SUM(TotalDue) AS ReceitaTotal
FROM sales.SalesOrderHeader
GROUP BY Year(OrderDate), MONTH(OrderDate)
)

SELECT
	Ano,
	Mes,
	ReceitaTotal,
	LAG(ReceitaTotal) OVER (ORDER BY Ano,Mes) AS ReceitaMesAnterior,
	CAST(
        ROUND(
            (ReceitaTotal - LAG(ReceitaTotal) OVER (ORDER BY Ano, Mes)) * 100.0 
            / LAG(ReceitaTotal) OVER (ORDER BY Ano, Mes), 2
        ) AS DECIMAL(10,2)
    ) AS VariacaoPercentual
FROM ReceitaMensal
ORDER BY Ano, Mes;


-- 7. Tempo médio (em dias) entre o pedido e o envio por território.

SELECT 
    st.Name AS Territorio,
    COUNT(soh.SalesOrderID) AS QtdPedidos,
    CAST(AVG(CAST(DATEDIFF(DAY, soh.OrderDate, soh.ShipDate) AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS TempoMedioEnvioDias
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
WHERE soh.ShipDate IS NOT NULL
GROUP BY st.Name
ORDER BY TempoMedioEnvioDias DESC;