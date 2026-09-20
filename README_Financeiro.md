# Dashboard Contábil e Financeiro

Dashboard em Power BI com análise de desempenho contábil e financeiro de 12 empresas de capital aberto, entre 2009 e 2022. Parte de um portfólio de 4 dashboards (RH, Vendas/Logística, Marketing Digital e este, Contábil/Financeiro).

## Sobre o dataset

O dataset usado é o **[Financial Statements of Major Companies (2009-2023)](https://www.kaggle.com/datasets/rish59/financial-statements-of-major-companies2009-2023)**, disponível no Kaggle, com dados reais extraídos de relatórios anuais (10-K) de empresas de capital aberto.

- **161 linhas** (empresa x ano), **12 empresas**: Apple (AAPL), Microsoft (MSFT), Google (GOOG), PayPal (PYPL), AIG, PG&E (PCG), Sears (SHLDQ), McDonald's (MCD), Barclays (BCS), Nvidia (NVDA), Intel (INTC) e Amazon (AMZN)
- Período original: 2009 a 2023 (o ano de 2023 foi excluído da análise — ver seção "Tratamento de dados" abaixo)
- O arquivo `Financial_Statements_Traduzido.xlsx` contém o dataset com colunas traduzidas para português; o arquivo original em inglês também está disponível na pasta de dados para quem quiser conferir os nomes originais

Esse dataset foi escolhido depois de eu testar e descartar um outro dataset contábil (sintético/gerado aleatoriamente), que tinha colunas com nomes contábeis mas sem relação matemática real entre elas (Receita, Despesas e Lucro Líquido não se conectavam). Antes de começar a construir qualquer gráfico, validei manualmente com Python que os números deste dataset real realmente se sustentam (ex: recalculando a Margem Líquida e o ROE a partir de Lucro Líquido, Receita e Patrimônio Líquido, e conferindo que batem com as colunas já prontas do dataset).

## Tratamento de dados

Alguns ajustes foram necessários antes de confiar nos números do dashboard:

**Exclusão do ano de 2023.** Apenas Microsoft e Nvidia têm dados de 2023 no dataset — as outras 10 empresas não. Para evitar comparações distorcidas (ano incompleto vs. anos completos), foi aplicado um filtro de relatório restringindo a análise a 2009-2022.

**Escala dos valores monetários.** As colunas de Receita, EBITDA e Lucro Líquido no dataset original vêm expressas em milhões de dólares. As medidas de totais (`Receita Total`, `EBITDA Total`, `Lucro Líquido Total`) multiplicam esses valores por 1.000.000 para refletir o valor real em dólares — sem esse ajuste, o Power BI abrevia os cartões incorretamente (ex: mostrando "12,21 Mi" quando o valor real é 12,21 trilhões de dólares).

**Correção de bug de formatação em ROE e ROA.** As colunas de ROE e ROA já vêm em formato de porcentagem (ex: "12,43" significa 12,43%). Aplicar a formatação nativa "Porcentagem" do Power BI multiplica o valor por 100 novamente, gerando números 100x maiores que o real (ex: 1243% em vez de 12,43%). As medidas foram corrigidas usando `FORMAT(valor, "0.00") & "%"`.

## Nota técnica: ROE e Dívida/Patrimônio distorcidos por Patrimônio Líquido negativo

Duas empresas do dataset têm Patrimônio Líquido negativo em parte do período analisado, o que distorce matematicamente qualquer métrica calculada com Patrimônio Líquido no denominador (ROE e Dívida/Patrimônio Líquido). A divisão de dois números negativos gera um resultado positivo enganoso; a divisão de um número positivo por um negativo gera um resultado negativo igualmente enganoso.

- **Sears (SHLDQ), 2015-2018**: Patrimônio Líquido negativo por prejuízo acumulado — sinal real de dificuldade financeira, que culminou na falência da empresa (o dataset não tem dados da Sears após 2018).
- **McDonald's (MCD), 2016-2022**: Patrimônio Líquido negativo por recompra agressiva de ações — prática comum em empresas maduras e altamente lucrativas, sem relação com problemas financeiros. O Lucro Líquido do McDonald's se manteve forte e estável (entre US$ 4,5 e 7,5 bilhões/ano) durante todo o período.

Ou seja, as duas empresas têm patrimônio negativo por motivos opostos: uma reflete crise real, a outra reflete confiança do mercado. Por isso, todas as medidas de ROE e Dívida/Patrimônio deste dashboard (`ROE Médio (Ajustado)` e `Dívida/Patrimônio Médio (Ajustado)`) excluem os anos com Patrimônio Líquido negativo do cálculo. É por isso que, no gráfico "ROE Médio por Ano por Empresa" (Página 2) e "Trajetória do Patrimônio Líquido" (Página 3), a linha do McDonald's aparece interrompida em 2015 e a da Sears em 2018 — não é um erro de dado ausente, é uma exclusão intencional para manter a métrica comparável.

## Nota técnica: "Receita por Setor" tem dois critérios diferentes

O dashboard usa dois critérios diferentes ao falar de receita por setor, propositalmente:

- O KPI **"Setor com Maior Receita Total"** (Página 4) soma a receita de todas as empresas de cada setor — por isso Tecnologia da Informação (TI) lidera, já que reúne 3 das 12 empresas do dataset (Apple, Microsoft e Google).
- O gráfico **"Receita Média por Setor"** mostra a receita média por empresa em cada setor — aqui Logística lidera, mas o setor é representado sozinho pela Amazon.

Os dois números contam histórias diferentes e complementares: um mostra concentração de mercado (quais setores têm mais peso no dataset como um todo), o outro mostra o porte típico de uma empresa daquele setor.

Vale reforçar também que, dos 8 setores do dataset, apenas 3 (Tecnologia da Informação, Banco e Eletrônicos/Eletricidade) têm mais de uma empresa representando-os. Os outros 5 setores (Logística, Finanças, Alimentação, Manufatura/Indústria e Fintech) são representados por uma única empresa cada — então, para esses casos, os gráficos "por setor" mostram, na prática, o desempenho daquela empresa específica, não uma média real de mercado.

## Estrutura do dashboard

### Página 1 — Visão Geral
KPIs: Receita Total, Lucro Líquido Total, Margem Líquida Média, ROE Médio, EBITDA Total, Total de Empresas.
Gráficos: Receita por Empresa, Distribuição de Empresas por Setor, Receita por Setor/Categoria, Ranking de Margem Líquida Média por Empresa, Lucro Líquido ao Longo do Tempo.
Segmentadores: Categoria, Empresa e Ano (disponíveis em todas as páginas).

### Página 2 — Desempenho ao Longo do Tempo
KPIs: Var % Receita YoY, Var % Lucro Líquido YoY, Melhor Ano, CAGR Receita, CAGR Lucro Líquido.
Gráficos: Receita ao Longo do Tempo por Empresa, Lucro Líquido vs Receita ao Longo do Tempo, Margem Líquida Média por Ano, ROE Médio por Ano por Empresa (Top 5 por ROE ajustado: Apple, McDonald's, Microsoft, Intel e Nvidia), Número de Funcionários ao Longo do Tempo.

**Insight:** entre 2021 e 2022, a Receita do grupo cresceu 8,65%, mas o Lucro Líquido caiu 14% — ou seja, as empresas faturaram mais, mas ficaram menos rentáveis no período, com despesas crescendo mais rápido que a receita.

### Página 3 — Saúde Financeira e Risco
KPIs: Liquidez Corrente Média, Dívida/Patrimônio Médio (Ajustado), Fluxo de Caixa Operacional Total, Empresas com Patrimônio Líquido Negativo.
Gráficos: Liquidez Corrente por Empresa, Dívida/Patrimônio por Empresa, Fluxo de Caixa Operacional por Empresa, Trajetória do Patrimônio Líquido (Sears vs. McDonald's), Liquidez Corrente ao Longo do Tempo (Sears x PG&E x Média do Grupo).

**Insight:** além da Sears, a PG&E (PCG) também aparece como um caso real de risco no dataset — sua liquidez corrente despenca para perto de zero em 2018, refletindo a recuperação judicial que a empresa pediu em janeiro de 2019 por conta de indenizações bilionárias de incêndios florestais na Califórnia.

### Página 4 — Setores e Comparativos
KPIs: Setor com Maior Receita Total, Setor com Maior Margem, ROA Médio, Total de Setores.
Gráficos: Receita Média por Setor, Margem Líquida Média por Setor, ROE Médio (Ajustado) por Setor, Mapa de Eficiência (Receita x Margem por Setor), Matriz Setor x Empresa (resumo com Receita Total, Margem Líquida Média e ROE Médio por empresa).

**Insight:** o Mapa de Eficiência mostra Tecnologia da Informação no quadrante ideal (receita alta e margem alta), Logística com receita altíssima mas margem baixa (modelo de alto volume/baixa margem, típico de varejo), e Finanças/Manufatura com margem negativa — reforçando a mesma história de risco (AIG e Sears) já vista na Página 3.

## Ferramentas
Power BI Desktop, DAX para as medidas, Python (pandas) para validação dos dados antes e durante a construção do dashboard.

---

## ✉️ Contato
Desenvolvido por **Isabelle Rodrigues**  

- 💼 **LinkedIn:** [Isabelle Rodrigues](https://www.linkedin.com/in/isabelle-rodrigues-18177b3b1)
- 🐙 **GitHub:** [IsabelleRodrigues23](https://github.com/IsabelleRodrigues23)
- 📧 **E-mail:** [isabellerodrigues0423@gmail.com](mailto:isabellerodrigues0423@gmail.com)