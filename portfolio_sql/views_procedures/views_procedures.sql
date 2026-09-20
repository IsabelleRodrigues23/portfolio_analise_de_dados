-- =============================================================================
-- PROJETO: Views, Stored Procedures e User-Defined Functions (UDFs)
-- para automação e regras de negócio sob demanda.
-- BANCO DE DADOS: AdventureWorks 2022 (SQL Server / T-SQL)
-- AUTOR: Isabelle
-- DESCRIÇÃO:
-- Objetos reutilizáveis do banco (views, stored procedures e function)
-- que consolidam as análises das outras pastas em consultas parametrizadas
-- e relatórios prontos para uso repetido.

-- OBJETOS CRIADOS:
--   Views: vw_ReceitaMensal, vw_ClientesRFM, vw_HeadcountDepartamento
--   Stored Procedures: sp_RelatorioVendasPorPeriodo, sp_HistoricoCliente,
--   sp_RelatorioExecutivo
--   USER-DEFINED FUNCTIONS - UDFs: fn_ClassificarCliente 
-- =============================================================================

-- =============================================================================

-- OBJETOS CRIADOS:
-- 1. vw_ReceitaMensal
--    Objetivo: consolidar a receita agregada por ano/mês, evitando
--    repetir o mesmo GROUP BY em várias queries diferentes.
--
-- 2. vw_ClientesRFM
--    Objetivo: centralizar o cálculo de segmentação RFM (Recência,
--    Frequência, Valor), servindo de base reutilizável para outras
--    queries e para a function de classificação.
--
-- 3. sp_RelatorioVendasPorPeriodo (@DataInicio, @DataFim)
--    Objetivo: gerar um relatório de vendas (qtd. pedidos, receita,
--    ticket médio) para qualquer intervalo de datas informado.
--
-- 4. sp_HistoricoCliente (@CustomerID)
--    Objetivo: retornar o histórico completo de compras de um
--    cliente específico, simulando uma consulta de atendimento.
--
-- 5. fn_ClassificarCliente (@CustomerID)
--    Objetivo: retornar o segmento RFM de um cliente sob demanda,
--    reaproveitando a view vw_ClientesRFM.
--
-- 6. sp_RelatorioExecutivo (@DataInicio, @DataFim)
--    Objetivo: consolidar em uma única chamada um relatório
--    executivo completo (KPIs, top produtos, receita por categoria
--    e distribuição de clientes por segmento RFM) para um período.
-- =============================================================================


-- Receita Mensal Consolidada.

CREATE VIEW vw_ReceitaMensal AS
SELECT 
    YEAR(OrderDate) AS Ano,
    MONTH(OrderDate) AS Mes,
    SUM(TotalDue) AS ReceitaTotal
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate);

SELECT *
FROM vw_ReceitaMensal;


-- Segmentação RFM completa.

CREATE VIEW vw_ClientesRFM AS
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
        CustomerID, Recencia, Frequencia, Monetario,
        NTILE(4) OVER (ORDER BY Recencia DESC) AS R_Score,
        NTILE(4) OVER (ORDER BY Frequencia ASC) AS F_Score,
        NTILE(4) OVER (ORDER BY Monetario ASC) AS M_Score
    FROM RFM_Base
)
SELECT 
    CustomerID, Recencia, Frequencia, Monetario,
    (R_Score + F_Score + M_Score) AS RFM_ScoreTotal,
    CASE 
        WHEN (R_Score + F_Score + M_Score) >= 10 THEN 'Cliente VIP'
        WHEN (R_Score + F_Score + M_Score) >= 7  THEN 'Cliente Fiel'
        WHEN (R_Score + F_Score + M_Score) >= 4  THEN 'Cliente em Risco'
        ELSE 'Cliente Perdido'
    END AS SegmentoRFM
FROM RFM_Score;

SELECT *
FROM vw_ClientesRFM;


-- Relatório de vendas por período (com parâmetros de data).

CREATE PROCEDURE sp_RelatorioVendasPorPeriodo
    @DataInicio DATE,
    @DataFim DATE
AS
BEGIN
    SELECT 
        YEAR(OrderDate) AS Ano,
        MONTH(OrderDate) AS Mes,
        COUNT(SalesOrderID) AS QtdPedidos,
        SUM(TotalDue) AS ReceitaTotal,
        AVG(TotalDue) AS TicketMedio
    FROM Sales.SalesOrderHeader
    WHERE OrderDate BETWEEN @DataInicio AND @DataFim
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
    ORDER BY Ano, Mes;
END;

EXEC sp_RelatorioVendasPorPeriodo @DataInicio = '2013-01-01', @DataFim = '2013-12-31';


-- Relatório de cliente específico (histórico completo de um cliente).

CREATE PROCEDURE sp_HistoricoCliente
    @CustomerID INT
AS
BEGIN
    SELECT 
        soh.SalesOrderID,
        soh.OrderDate,
        soh.TotalDue,
        p.Name AS Produto,
        sod.OrderQty
    FROM Sales.SalesOrderHeader soh
    INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
    WHERE soh.CustomerID = @CustomerID
    ORDER BY soh.OrderDate;
END;

EXEC sp_HistoricoCliente @CustomerID = 29847;


-- Classificação o segmento RFM de um cliente específico, sob demanda.

CREATE FUNCTION fn_ClassificarCliente (@CustomerID INT)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Segmento VARCHAR(20);
    
    SELECT @Segmento = SegmentoRFM
    FROM vw_ClientesRFM
    WHERE CustomerID = @CustomerID;
    
    RETURN @Segmento;
END;
GO

SELECT 
    soh.CustomerID,
    soh.SalesOrderID,
    soh.TotalDue,
    dbo.fn_ClassificarCliente(soh.CustomerID) AS Segmento
FROM Sales.SalesOrderHeader soh
WHERE soh.OrderDate >= '2014-01-01';


-- Visão Geral:

CREATE PROCEDURE sp_RelatorioExecutivo
    @DataInicio DATE,
    @DataFim DATE
AS
BEGIN
-- KPIs gerais do período

    SELECT 
        COUNT(SalesOrderID) AS QtdPedidos,
        SUM(TotalDue) AS ReceitaTotal,
        AVG(TotalDue) AS TicketMedio
    FROM Sales.SalesOrderHeader
    WHERE OrderDate BETWEEN @DataInicio AND @DataFim;

-- Top 5 produtos mais vendidos no período

    SELECT TOP 5
        p.Name AS Produto,
        SUM(sod.OrderQty) AS QuantidadeVendida
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.OrderDate BETWEEN @DataInicio AND @DataFim
    GROUP BY p.Name
    ORDER BY QuantidadeVendida DESC;

-- Receita por categoria no período

    SELECT 
        pc.Name AS Categoria,
        SUM(sod.LineTotal) AS ReceitaTotal
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
    JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.OrderDate BETWEEN @DataInicio AND @DataFim
    GROUP BY pc.Name
    ORDER BY ReceitaTotal DESC;

-- Distribuição de clientes por segmento RFM.

    SELECT 
        SegmentoRFM,
        COUNT(*) AS QtdClientes
    FROM vw_ClientesRFM
    GROUP BY SegmentoRFM
    ORDER BY QtdClientes DESC;
END;
GO

EXEC sp_RelatorioExecutivo @DataInicio = '2013-01-01', @DataFim = '2013-12-31';