-- =============================================================================
-- PROJETO: Análise de Comportamento de Clientes (Customer Analytics)
-- BANCO DE DADOS: AdventureWorks 2022 (SQL Server / T-SQL)
-- AUTOR: Isabelle
-- DESCRIÇÃO: 
-- Análise de comportamento de compra e segmentação de clientes,
-- incluindo classificação RFM (Recência, Frequência, Valor) para
-- identificar clientes VIP, fiéis, em risco e perdidos.

-- TABELAS UTILIZADAS:
--   Sales.SalesOrderHeader — pedidos (data, valor, cliente)
--   Sales.Customer — cadastro do cliente 
-- =============================================================================

-- =============================================================================
-- PERGUNTAS DE NEGÓCIO RESPONDIDAS:
-- 1. Quais os 10 clientes que mais compraram em valor?
-- 2. Quantos pedidos cada cliente fez? (identifica clientes recorrentes vs. únicos)
-- 3. Qual o tempo (em dias) entre a primeira e a última compra de cada cliente?
-- 4. Qual o segmento de cada cliente (RFM classificado em texto)?
-- 5. Quantos clientes compraram só 1 vez vs. mais de uma vez?
-- 6. Quantos clientes existem em cada segmento RFM?
-- 7. Qual o ticket médio de cada cliente?
-- =============================================================================

-- 1. 10 clientes que mais compram em valor.

SELECT TOP 10
	c.CustomerID,
	SUM(soh.TotalDue) AS ValorTotalComprado
FROM SALES.SalesOrderHeader AS soh
INNER JOIN sales.Customer c ON soh.CustomerID = c.CustomerID
GROUP BY c.CustomerID
ORDER BY ValorTotalComprado DESC;


-- 2. Quantidade de pedidos que cada cliente fez (identificando clientes recorrentes vs. únicos).

SELECT
	CustomerID,
	COUNT(SalesOrderID) AS QuantidadePedidos
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY QuantidadePedidos; 


-- 3. Tempo (em dias) entre a primeira e a última compra de cada cliente.
SELECT 
    CustomerID,
    MIN(OrderDate) AS PrimeiraCompra,
    MAX(OrderDate) AS UltimaCompra,
    DATEDIFF(DAY, MIN(OrderDate), MAX(OrderDate)) AS DiasEntreCompras
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(SalesOrderID) > 1
ORDER BY DiasEntreCompras DESC;


-- 4. Segmento de cada cliente (RFM classificado em texto).

WITH DataReferencia AS (
    SELECT MAX(OrderDate) AS UltimaDataDataset
    FROM Sales.SalesOrderHeader
),
RFM_Base AS (
    SELECT 
        soh.CustomerID,
        DATEDIFF(DAY, MAX(soh.OrderDate), (SELECT UltimaDataDataset FROM DataReferencia)) AS Recencia,
        COUNT(soh.SalesOrderID) AS Frequencia,
        SUM(soh.TotalDue) AS Monetario
    FROM Sales.SalesOrderHeader soh
    GROUP BY soh.CustomerID
),
RFM_Score AS (
    SELECT 
        CustomerID,
        Recencia,
        Frequencia,
        Monetario,
        NTILE(4) OVER (ORDER BY Recencia DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequencia ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetario ASC) AS M_Score
    FROM RFM_Base
)
SELECT 
    CustomerID,
    Recencia,
    Frequencia,
    Monetario,
    (R_Score + F_Score + M_Score) AS RFM_ScoreTotal,
    CASE 
        WHEN (R_Score + F_Score + M_Score) >= 10 THEN 'Cliente VIP'
        WHEN (R_Score + F_Score + M_Score) >= 7  THEN 'Cliente Fiel'
        WHEN (R_Score + F_Score + M_Score) >= 4  THEN 'Cliente em Risco'
        ELSE 'Cliente Perdido'
    END AS SegmentoRFM
FROM RFM_Score
ORDER BY RFM_ScoreTotal DESC;


-- 5. Clientes que compraram só 1 vez vs. mais de uma vez.

SELECT 
    CASE 
        WHEN QtdPedidos = 1 THEN 'Cliente Único'
        ELSE 'Cliente Recorrente'
    END AS TipoCliente,
    COUNT(*) AS QtdClientes
FROM (
    SELECT CustomerID,
    COUNT(SalesOrderID) AS QtdPedidos
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
) AS Base
GROUP BY 
    CASE 
        WHEN QtdPedidos = 1 THEN 'Cliente Único'
        ELSE 'Cliente Recorrente'
    END;


-- 6. Quantidade de clientes que existem em cada segmento RFM.

WITH DataReferencia AS (
    SELECT MAX(OrderDate) AS UltimaDataDataset
    FROM Sales.SalesOrderHeader
),
RFM_Base AS (
    SELECT 
        soh.CustomerID,
        DATEDIFF(DAY, MAX(soh.OrderDate), (SELECT UltimaDataDataset FROM DataReferencia)) AS Recencia,
        COUNT(soh.SalesOrderID) AS Frequencia,
        SUM(soh.TotalDue) AS Monetario
    FROM Sales.SalesOrderHeader soh
    GROUP BY soh.CustomerID
),
RFM_Score AS (
    SELECT 
        CustomerID,
        Recencia,
        Frequencia,
        Monetario,
        NTILE(4) OVER (ORDER BY Recencia DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequencia ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetario ASC) AS M_Score
    FROM RFM_Base
),
RFM_Final AS (
    SELECT 
        CustomerID,
        (R_Score + F_Score + M_Score) AS RFM_ScoreTotal,
        CASE 
            WHEN (R_Score + F_Score + M_Score) >= 10 THEN 'Cliente VIP'
            WHEN (R_Score + F_Score + M_Score) >= 7  THEN 'Cliente Fiel'
            WHEN (R_Score + F_Score + M_Score) >= 4  THEN 'Cliente em Risco'
            ELSE 'Cliente Perdido'
        END AS SegmentoRFM
    FROM RFM_Score
)
SELECT 
    SegmentoRFM,
    COUNT(*) AS QtdClientes
FROM RFM_Final
GROUP BY SegmentoRFM
ORDER BY QtdClientes DESC;


-- 7. Ticket médio de cada cliente.

SELECT 
    CustomerID,
    AVG(TotalDue) AS TicketMedioCliente
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(SalesOrderID) > 1
ORDER BY TicketMedioCliente DESC;