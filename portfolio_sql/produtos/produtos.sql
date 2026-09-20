-- =============================================================================
-- PROJETO: Análise de Produtos e Estoque (Product Analytics)
-- BANCO DE DADOS: AdventureWorks 2022 (SQL Server / T-SQL)
-- AUTOR: Isabelle
-- DESCRIÇÃO:
-- Análise de performance de catálogo: receita por categoria/subcategoria,
-- margem de lucro, produtos sem saída e concentração de receita
-- (Análise de Pareto 80/20).

-- TABELAS UTILIZADAS:
--   Sales.SalesOrderDetail — itens vendidos (quantidade, valor da linha)
--   Production.Product — nome, preço, custo
--   Production.ProductSubcategory — subcategoria (liga produto à categoria)
--   Production.ProductCategory — categoria (Bikes, Components, Clothing, Accessories)
-- =============================================================================

-- =============================================================================
-- PERGUNTAS DE NEGÓCIO RESPONDIDAS:
-- 1. Qual a receita total por categoria de produto?
-- 2. Quais os 10 produtos com maior margem de lucro (venda - custo)?
-- 3. Quais produtos existem no catálogo mas nunca foram vendidos?
-- 4. Qual a receita por subcategoria dentro de cada categoria?
-- 5. Qual o desconto médio (%) dado por categoria de produto?
-- 6. Qual o produto mais vendido (em quantidade) dentro de cada categoria?
-- 7. Quais produtos representam 80% da receita total? (Análise de Pareto / regra 80-20)
-- =============================================================================


-- 1. Receita total por categoria de produto.

SELECT
	pc.Name AS Categoria,
	SUM(sod.LineTotal) AS ReceitaTotal
FROM SALES.SalesOrderDetail sod
INNER JOIN Production.Product p ON sod.ProductID = p.ProductID
INNER JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
INNER JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY ReceitaTotal DESC;


-- 2. 10 produtos com maior margem de lucro (venda - custo).

SELECT TOP 10
    Name AS Produto,
    ListPrice AS PrecoVenda,
    StandardCost AS Custo,
    (ListPrice - StandardCost) AS MargemAbsoluta,
    ROUND((ListPrice - StandardCost) / NULLIF(ListPrice, 0) * 100, 2) AS MargemPercentual
FROM Production.Product
WHERE ListPrice > 0
ORDER BY MargemAbsoluta DESC;


-- 3. Produtos que existem no catálogo mas nunca foram vendidos.

SELECT 
    p.ProductID,
    p.Name AS Produto
FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;


-- 4. Receita por subcategoria dentro de cada categoria.

SELECT 
    pc.Name AS Categoria,
    psc.Name AS Subcategoria,
    SUM(sod.LineTotal) AS ReceitaTotal
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name, psc.Name
ORDER BY Categoria, ReceitaTotal DESC;


-- 5. Desconto médio (%) dado por categoria de produto.

SELECT 
    pc.Name AS Categoria,
    ROUND(AVG(sod.UnitPriceDiscount) * 100, 2) AS DescontoMedioPercentual
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.Name
ORDER BY DescontoMedioPercentual DESC;


-- 6. Produto mais vendido (em quantidade) dentro de cada categoria.

WITH VendasPorProduto AS (
    SELECT 
        pc.Name AS Categoria,
        p.Name AS Produto,
        SUM(sod.OrderQty) AS QuantidadeVendida,
        RANK() OVER (PARTITION BY pc.Name ORDER BY SUM(sod.OrderQty) DESC) AS Ranking
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.Name, p.Name
)
SELECT * 
FROM VendasPorProduto
WHERE Ranking = 1;


-- 7. Produtos que representam 80% da receita total (Análise de Pareto / regra 80-20).

WITH ReceitaPorProduto AS (
    SELECT 
        p.Name AS Produto,
        SUM(sod.LineTotal) AS ReceitaTotal
    FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY p.Name
),
ReceitaAcumulada AS (
    SELECT 
        Produto,
        ReceitaTotal,
        SUM(ReceitaTotal) OVER (ORDER BY ReceitaTotal DESC) AS ReceitaAcumuladaValor,
        SUM(ReceitaTotal) OVER () AS ReceitaTotalGeral
    FROM ReceitaPorProduto
)
SELECT 
    Produto,
    ReceitaTotal,
    ROUND(ReceitaAcumuladaValor * 100.0 / ReceitaTotalGeral, 2) AS PercentualAcumulado
FROM ReceitaAcumulada
WHERE (ReceitaAcumuladaValor * 100.0 / ReceitaTotalGeral) <= 80
ORDER BY ReceitaTotal DESC;