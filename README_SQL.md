# Portfólio de SQL Server — Análise de Dados com AdventureWorks

Projeto de portfólio em SQL Server, construído sobre o banco de dados de exemplo **AdventureWorks2022** (Microsoft), simulando uma análise de negócio completa: vendas, clientes, produtos e recursos humanos de uma empresa fabricante de bicicletas e acessórios esportivos.

## Sobre o dataset

O AdventureWorks é o banco de amostra oficial da Microsoft para SQL Server, com um schema relacional real (múltiplas tabelas normalizadas, chaves estrangeiras, relacionamentos indiretos). Os dados de vendas cobrem o período de 2011 a 2014.

**Observações sobre o dataset:**
- O ano de 2014 é parcial (não é um ano fiscal completo).
- Todos os 290 funcionários aparecem como "Ativo" — o dataset não registra histórico de desligamentos.
- Como o dataset é histórico (dados até 2014), todas as análises de tempo (recência de compra, tempo de casa) usam a **última data de pedido do próprio dataset** como referência, em vez de `GETDATE()` — isso evita cálculos de tempo distorcidos por comparar com a data real de hoje.

## Estrutura do projeto

```
/vendas               → análise de receita, produtos e sazonalidade
/clientes             → segmentação de clientes e comportamento de compra
/produtos             → performance de catálogo e margem
/rh                   → estrutura organizacional e força de trabalho
/views-procedures     → objetos reutilizáveis (views, stored procedures, function)
```

Cada pasta temática contém um arquivo `.sql` com todas as queries daquele tema, comentadas com a pergunta de negócio que respondem.

## Resumo por pasta

### 📈 Vendas (7 perguntas)
Receita por ano, top 10 produtos por quantidade, receita por território, ticket médio, sazonalidade mensal (agregada entre anos), variação % de receita mês a mês (usando `LAG` e window functions), e tempo médio de envio (dias entre pedido e despacho) por território.

### 👥 Clientes (7 perguntas)
Top 10 clientes por valor, recorrência de pedidos, intervalo entre compras, **segmentação RFM** (Recência, Frequência, Valor) com classificação em texto (VIP / Fiel / Em Risco / Perdido), clientes únicos vs. recorrentes, e ticket médio por cliente.

**Distribuição de clientes por segmento RFM:**
| Segmento | Qtd. Clientes |
|---|---|
| Cliente Fiel | 7.209 |
| Cliente em Risco | 5.784 |
| Cliente VIP | 4.857 |
| Cliente Perdido | 1.269 |

### 📦 Produtos (7 perguntas)
Receita por categoria (Bikes domina com ~95% do faturamento), receita por subcategoria, top 10 produtos por margem de lucro, produtos nunca vendidos (peças de fabricação, não produtos de catálogo final), desconto médio por categoria, produto mais vendido por categoria (`RANK` + `PARTITION BY`), e **Análise de Pareto (regra 80/20)** identificando quais produtos concentram 80% da receita.

### 🧑‍💼 RH (7 perguntas)
Quantidade de funcionários por departamento, nome completo e cargo, tempo médio de casa, distribuição por gênero, salário médio mais recente por departamento (`ROW_NUMBER`), status ativo/inativo, e **hierarquia organizacional completa via CTE recursiva** (do CEO até cada funcionário).

### ⚙️ Views, Procedures e Function
- `vw_ReceitaMensal` — receita consolidada por ano/mês
- `vw_ClientesRFM` — segmentação RFM completa, reutilizável
- `sp_RelatorioVendasPorPeriodo` — relatório de vendas parametrizado por data
- `sp_HistoricoCliente` — histórico completo de compras de um cliente específico
- `fn_ClassificarCliente` — function escalar que retorna o segmento RFM de um cliente
- `sp_RelatorioExecutivo` — **procedure "mestra"**, que devolve em uma única chamada: KPIs gerais, top 5 produtos, receita por categoria e distribuição de clientes por segmento RFM, filtrados por período

## Decisões técnicas e aprendizados

- **Correção de bug de dados reais**: o `OrganizationNode` do CEO no AdventureWorks vem `NULL` em vez do valor esperado, o que quebrava a CTE recursiva de hierarquia. Corrigido usando `hierarchyid::GetRoot()` na âncora da recursão, identificado através de uma query de diagnóstico com `.ToString()`.
- **Data de referência fixa**: todas as métricas de tempo (recência RFM, tempo de casa) usam a última data do dataset como "hoje fictício", em vez de `GETDATE()`.
- **Performance de function escalar**: `fn_ClassificarCliente` funciona, mas é executada linha a linha (uma consulta por registro), sendo mais lenta que um `JOIN` direto com a view `vw_ClientesRFM` em grandes volumes — mantida no projeto por clareza didática, com a ressalva documentada aqui.
- **RFM não filtrado por período**: a `sp_RelatorioExecutivo` filtra vendas por data, mas o segmento RFM de cada cliente reflete o histórico *completo* dele, não o período filtrado — é uma decisão intencional, já que o perfil de cliente (VIP, Fiel etc.) é uma classificação de longo prazo.
- **`ShipDate` sintético e sem variação real**: a análise de tempo médio entre pedido e envio (`OrderDate` → `ShipDate`) por território retornou exatamente **7,00 dias para todos os territórios**, sem nenhuma variação. Isso indica que o dataset gera `ShipDate` como uma regra fixa (`OrderDate + 7 dias`), sem simular diferenças reais de logística por distância geográfica — uma limitação conhecida do dataset sintético, documentada aqui em vez de ser omitida.

---
## 📁 Acesso aos Arquivos
Para visualizar os scripts organizados por módulos (Clientes, Vendas, RH, Produtos, Views e Procedures), acesse:
👉 **[Navegar pela pasta portfolio_sql](./portfolio_sql)**

## Ferramentas
SQL Server 2022 · SSMS · Dataset AdventureWorks2022 (Microsoft)

---

## ✉️ Contato
Desenvolvido por **Isabelle Rodrigues**  

- 💼 **LinkedIn:** [Isabelle Rodrigues](https://www.linkedin.com/in/isabelle-rodrigues-18177b3b1)
- 🐙 **GitHub:** [IsabelleRodrigues23](https://github.com/IsabelleRodrigues23)
- 📧 **E-mail:** [isabellerodrigues0423@gmail.com](mailto:isabellerodrigues0423@gmail.com)
