-- =============================================================================
-- PROJETO: Análise de Recursos Humanos (Human Resources)
-- BANCO DE DADOS: AdventureWorks 2022 (SQL Server / T-SQL)
-- AUTOR: Isabelle 
-- DESCRIÇÃO:
-- Análise da estrutura organizacional: distribuição de funcionários por
-- departamento e gênero, tempo de casa, salário médio, turnover e
-- hierarquia completa de comando (CEO até cada funcionário).

-- TABELAS UTILIZADAS:
--  HumanResources.Employee — cargo, data de contratação, gênero
--  HumanResources.EmployeeDepartmentHistory — departamento atual/histórico
--  HumanResources.Department — nome do departamento
--  Person.Person — nome completo do funcionário
--  HumanResources.EmployeePayHistory — histórico de salário/hora

-- =============================================================================

-- =============================================================================
-- PERGUNTAS DE NEGÓCIO RESPONDIDAS:
-- 1. Quantos funcionários existem em cada departamento atualmente?
-- 2. Qual o nome completo e cargo atual de cada funcionário?
-- 3. Qual o tempo médio de casa (em anos) dos funcionários por departamento?
-- 4. Qual a hierarquia completa de comando (do CEO até cada funcionário)?
-- 5. Qual a distribuição de funcionários por gênero, em cada departamento?
-- 6. Qual o salário/hora médio atual (mais recente) por departamento?
-- 7. Quantos funcionários estão ativos vs. inativos (turnover)?
-- =============================================================================



-- 1. Quantidade de funcionários por departamento atual.

SELECT 
    d.Name AS Departamento,
    COUNT(edh.BusinessEntityID) AS QtdFuncionarios
FROM HumanResources.EmployeeDepartmentHistory edh
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL
GROUP BY d.Name
ORDER BY QtdFuncionarios DESC;


-- 2. Nome completo e cargo atual dos funcionários.

SELECT 
    CONCAT_WS(' ', p.FirstName, p.MiddleName, p.LastName) AS NomeCompleto,
    e.JobTitle AS Cargo,
    d.Name AS Departamento
FROM HumanResources.Employee e
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL
ORDER BY NomeCompleto;


-- 3. Tempo médio de empresa (em anos) dos funcionários por departamento.

WITH DataReferencia AS (
    SELECT MAX(OrderDate) AS UltimaDataDataset
    FROM Sales.SalesOrderHeader
)
SELECT 
    d.Name AS Departamento,
    AVG(DATEDIFF(DAY, e.HireDate, dr.UltimaDataDataset)) / 365.0 AS TempoMedioAnos
FROM HumanResources.Employee e
INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
INNER JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
CROSS JOIN DataReferencia dr
WHERE edh.EndDate IS NULL
GROUP BY d.Name
ORDER BY TempoMedioAnos DESC;


-- 4. Hierarquia completa de comando (do CEO até cada funcionário).

WITH Hierarquia AS (
    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS NomeCompleto,
        e.JobTitle AS Cargo,
        hierarchyid::GetRoot() AS OrganizationNode,
        0 AS Nivel
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    WHERE e.OrganizationNode IS NULL OR e.OrganizationNode = hierarchyid::GetRoot()

    UNION ALL

    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName,
        e.JobTitle,
        e.OrganizationNode,
        h.Nivel + 1
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    JOIN Hierarquia h ON e.OrganizationNode.GetAncestor(1) = h.OrganizationNode
)
SELECT 
    NomeCompleto,
    Cargo,
    Nivel
FROM Hierarquia
ORDER BY Nivel, NomeCompleto;


-- 5. Distribuição de funcionários por gênero em cada departamento.
SELECT 
    d.Name AS Departamento,
    e.Gender AS Genero,
    COUNT(*) AS QtdFuncionarios
FROM HumanResources.Employee e
INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON e.BusinessEntityID = edh.BusinessEntityID
INNER JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE edh.EndDate IS NULL
GROUP BY d.Name, e.Gender
ORDER BY d.Name, e.Gender;


-- 6. Salário/hora média atual por departamento.

WITH SalarioMaisRecente AS (
    SELECT 
        BusinessEntityID,
        Rate,
        ROW_NUMBER() OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate DESC) AS Ordem
    FROM HumanResources.EmployeePayHistory
)
SELECT 
    d.Name AS Departamento,
    ROUND(AVG(sr.Rate), 2) AS SalarioMedioHora
FROM SalarioMaisRecente sr
INNER JOIN HumanResources.EmployeeDepartmentHistory edh ON sr.BusinessEntityID = edh.BusinessEntityID
INNER JOIN HumanResources.Department d ON edh.DepartmentID = d.DepartmentID
WHERE sr.Ordem = 1 AND edh.EndDate IS NULL
GROUP BY d.Name
ORDER BY SalarioMedioHora DESC;


-- 7. Funcionários ativos vs. inativos (turnover).

SELECT 
    CASE WHEN CurrentFlag = 1 THEN 'Ativo' ELSE 'Inativo' 
    END AS Status,
    COUNT(*) AS QtdFuncionarios
FROM HumanResources.Employee
GROUP BY CurrentFlag;