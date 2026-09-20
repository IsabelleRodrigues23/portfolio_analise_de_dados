# 📊 Portfólio de Análise de Dados & Business Intelligence

Bem-vindo(a) ao meu portfólio! Aqui você encontra projetos práticos de Análise de Dados utilizando **Power BI**, **DAX** e **SQL Server**, focados na resolução de problemas de negócio reais e na geração de insights estratégicos a partir de dados brutos — incluindo a identificação e correção de inconsistências encontradas nos próprios datasets.

---

## 🛠️ Tecnologias & Ferramentas
- **Modelagem & Análise:** SQL Server (T-SQL), Power Query, Modelagem Dimensional (Star Schema)
- **Visualização de Dados:** Power BI, DAX
- **Gestão & Documentação:** Git, GitHub
---

## 🚀 Projetos em Destaque

### 1. 📈 Dashboard de Marketing Digital (Power BI)
- **Descrição:** Dashboard de performance de campanhas de marketing digital em 5 plataformas (Meta, Google, TikTok, LinkedIn, Snapchat), cobrindo investimento, retorno e funil de conversão em 12 países, de 2023 a 2025.
- **Estrutura:** 4 páginas — Visão Geral, Tendências Temporais (MoM/YoY), Canais e Plataformas, Geografia.
- **DAX:** mais de 20 medidas calculadas do zero a partir de métricas cruas (ROAS, CPM, CPC, CTR, CPA, CPL, VTR, CPV, Ticket Médio, Lucro Bruto), incluindo comparativos Mês a Mês e Ano a Ano.
- **Destaques:** funil de conversão interativo, matrizes cruzadas de Plataforma x Objetivo (CPA/ROAS para Leads e Vendas), mapa de eficiência por plataforma, e identificação dinâmica do melhor país por ROAS (Omã) e maior investimento (Arábia Saudita).
- 🔗 **[Ver Dashboard Interativo no Power BI](https://app.powerbi.com/view?r=eyJrIjoiYjI3ZDgyMzYtZGJhZS00N2FjLWJiNWQtMTQzYTE3YWFiNGEyIiwidCI6IjEzNDBhYWVlLTJlMTQtNDNjZi1iMjIwLTlhMzQ4NTNkZDQ2MyJ9)**
- 📁 **[Ver detalhes do projeto](./README_dashboard_marketing.md)**

---

### 2. 🛒 Dashboard de Vendas e Logística (Power BI)
- **Descrição:** Análise completa de vendas, logística e satisfação do cliente do e-commerce Olist, estruturada em Presente → Passado → Satisfação → Futuro.
- **Estrutura:** 4 páginas — Visão Geral, Passado (Tendências e Sazonalidade), Satisfação do Cliente, Projeções e Tendência Futura.
- **DAX:** medidas de time intelligence (YoY, MoM, YTD, rolling 12 meses, média móvel), projeção de faturamento e tendência de atraso, todas ancoradas corretamente em contexto de filtro (padrão MAX(Data) + FILTER(ALL())).
- **Destaques:** correção de bug de escala (valores em centavos), tratamento de período de coleta incompleto, crescimento YoY de 137% após ajuste de período comparável, e defasagem intencional de 2 meses na medida de atraso para evitar viés de censura à direita.
- 🔗 **[Ver Dashboard Interativo no Power BI](https://app.powerbi.com/view?r=eyJrIjoiOGI4YjRlNGMtOTUzZi00NGE5LTgxYmYtMDJjNTg5ZWM1NGM1IiwidCI6IjEzNDBhYWVlLTJlMTQtNDNjZi1iMjIwLTlhMzQ4NTNkZDQ2MyJ9)**
- 📁 **[Ver detalhes do projeto](./README_vendas.md)**

---

### 3. 💰 Dashboard Contábil e Financeiro (Power BI)
- **Descrição:** Análise financeira de 12 grandes empresas (AAPL, MSFT, GOOG, AMZN, NVDA, entre outras) com base em dados reais de demonstrações financeiras (10-K), de 2009 a 2022.
- **Estrutura:** páginas de Visão Geral, Desempenho ao Longo do Tempo e Saúde Financeira e Risco, com KPIs como Receita, EBITDA, ROE, ROA, CAGR e Margem Líquida.
- **DAX:** medidas de CAGR, variação YoY corretamente ancorada por ano, e uma medida de ROE ajustada excluindo empresas com Patrimônio Líquido negativo.
- **Destaques:** identificação e explicação de distorções reais nos dados — ROE inflado por Patrimônio Líquido negativo (Sears em dificuldade financeira; McDonald's com recompra agressiva de ações) e queda de liquidez da PG&E ligada à sua recuperação judicial de 2019.
- 🔗 **[Ver Dashboard Interativo no Power BI](https://app.powerbi.com/view?r=eyJrIjoiOGI4N2MyNDUtYzNmYi00YzJkLTg1YTMtMmFlYWZhODMzYmYzIiwidCI6IjEzNDBhYWVlLTJlMTQtNDNjZi1iMjIwLTlhMzQ4NTNkZDQ2MyJ9)**
- 📁 **[Ver detalhes do projeto](./README_Financeiro.md)**

---

### 4. 👥 Dashboard de Recursos Humanos (Power BI)
- **Descrição:** Dashboard de análise de força de trabalho, explorando relação entre perfil demográfico, remuneração e rotatividade dos funcionários.
- **DAX:** medidas cruzando Estado Civil, Escolaridade e Gênero com renda, tempo desde a última promoção, percentual de aumento salarial e tempo de casa.
- **Destaques:** identificação de que a diferença de renda por estado civil era menor do que o esperado (Casados e Divorciados com renda similar, ~7 mil; Solteiros ~5,5 mil), e cruzamento entre área de formação e departamento de atuação.
- 🔗 **[Ver Dashboard Interativo no Power BI](https://app.powerbi.com/view?r=eyJrIjoiZmFlMDBhZDItMTdjNy00Nzk2LWFjODktMWFlM2Q4NzA0ODYzIiwidCI6IjEzNDBhYWVlLTJlMTQtNDNjZi1iMjIwLTlhMzQ4NTNkZDQ2MyJ9)**
- 📁 **[Ver detalhes do projeto](./README_Analise_RH.md)**

---

### 5. 🗄️ Portfólio de Análise de Dados em SQL Server (AdventureWorks)
- **Descrição:** 28 perguntas de negócio respondidas em T-SQL puro sobre o banco de dados AdventureWorks2022, cobrindo Vendas, Clientes, Produtos e RH — além de um conjunto de objetos reutilizáveis (views, stored procedures e function).
- **Estrutura:** `/vendas`, `/clientes`, `/produtos`, `/rh`, `/views-procedures`, cada um com um arquivo `.sql` comentado por pergunta de negócio respondida.
- **Técnicas aplicadas:** CTEs, window functions (`LAG`, `NTILE`, `RANK`, `ROW_NUMBER`, soma acumulada), segmentação de clientes via **RFM**, **Análise de Pareto (80/20)**, e **CTE recursiva com `hierarchyid`/`GetAncestor()`** para reconstruir a hierarquia organizacional completa da empresa a partir do CEO.
- **Destaques técnicos:** identificação e correção de um bug real de dados (nó de hierarquia do CEO nulo no banco, resolvido com `hierarchyid::GetRoot()`), e uma stored procedure "mestra" (`sp_RelatorioExecutivo`) que devolve um relatório executivo completo — KPIs, top produtos, receita por categoria e distribuição de clientes por segmento — em uma única chamada parametrizada por período.
- 📁 **[Ver o projeto completo e o README técnico](./README_SQL.md)**
- 📂 **[Acesse a pasta com todas as queries, views e procedures completas](./portfolio_sql)**

---


## ✉️ Contato
Desenvolvido por **Isabelle Rodrigues**  

- 💼 **LinkedIn:** [Isabelle Rodrigues](https://www.linkedin.com/in/isabelle-rodrigues-18177b3b1)
- 🐙 **GitHub:** [IsabelleRodrigues23](https://github.com/IsabelleRodrigues23)
- 📧 **E-mail:** [isabellerodrigues0423@gmail.com](mailto:isabellerodrigues0423@gmail.com)
