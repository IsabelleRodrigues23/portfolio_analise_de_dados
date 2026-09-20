# Dashboard de Marketing Digital
**Visão Geral de Investimento e Retorno (2023-2025)**

## Sobre o projeto

Dashboard em Power BI analisando performance de marketing digital multi-canal (Google, Meta, TikTok, LinkedIn, Snapchat), cobrindo investimento, retorno, eficiência de mídia, tendências temporais e distribuição geográfica.

- **Dataset:** [Digital Marketing Performance Dataset](https://www.kaggle.com/datasets/alinaboulsi/digital-marketing-performance-dataset) (Kaggle), ~30.000 linhas, traduzido para português.
- **Período:** 2023, 2024 e 2025 completos.
- **Ferramenta:** Power BI (Power Query + DAX).

## Estrutura do dashboard (4 páginas)

### 1. Visão Geral
KPIs centrais (Receita, Gasto, Lucro, ROAS, Conversões, CPA, Ticket Médio), evolução temporal de Gasto x Receita, funil de conversão (Impressões → Cliques → Conversões), investimento por etapa do funil, dispersão de campanhas e Top 5 campanhas por ROAS.

### 2. Tendências Temporais
Indicadores de variação mês a mês (MoM) e ano a ano (YoY), comparação de receita entre os 3 anos por mês, fechamento por trimestre, eficiência (ROAS) ao longo do tempo e projeção de receita para os próximos meses (forecast nativo do Power BI, com sazonalidade de 12 meses).

### 3. Canais e Plataformas
Comparativo de ROAS, CPC e CPM por plataforma, mapa de eficiência (custo x retorno) e matrizes cruzando plataforma com objetivo de campanha.

### 4. Geografia
Distribuição de investimento e retorno por país, por nível de mercado (Tier) e detalhamento completo por país.

## Principais insights

- **Google Search é o canal mais eficiente com folga**: ROAS geral de 3,78x (chegando a 16,78x em campanhas de Vendas), respondendo por 65% de toda a receita rastreada com apenas 22% do investimento total.
- **LinkedIn é o pior canal em todas as métricas simultaneamente**: menor ROAS (0,11x-0,36x), maior CPM ($24,96) e maior CPC ($3,73) — recomendação de realocação de verba para canais com melhor desempenho.
- **Apenas campanhas de Leads e Vendas geram receita rastreável** (45% do investimento total); campanhas de topo de funil (Alcance, Engajamento, Tráfego, Visualizações de Vídeo) não têm receita atribuída por natureza, o que é esperado e não um erro de dado.
- **Forte sazonalidade de Q4**: o quarto trimestre concentra receita muito acima dos demais (R$ 6,6 Mi vs. ~R$ 2,5 Mi nos outros trimestres), puxado por novembro/dezembro em todos os anos analisados.
- **2024 foi o melhor ano** em receita; **2025 encerrou em queda** (-9,26% YoY, com o último mês do período caindo -15% frente ao mês anterior), enquanto o investimento se manteve estável nos 3 anos — indicando queda de eficiência, não de orçamento.
- **Omã tem o melhor ROAS entre os países** (1,36x); Arábia Saudita concentra o maior volume de investimento.
- **Nível de Mercado não segue relação linear com performance**: Nível 2 tem o pior ROAS (abaixo de 1x), enquanto Níveis 1 e 3 performam de forma parecida e superior.
- **Tema de campanha "Lançamento de Produto" tem o melhor ROAS** (1,27x); "Educacional" fica no ponto de equilíbrio (1,00x), o mais fraco entre os 8 temas analisados.

## Notas técnicas e limitações

- **Medidas de tempo (MoM/YoY) usam um padrão de "âncora"** (`VAR MAX(Data) + FILTER(ALL())`) em vez de `DATEADD` puro, necessário porque essas medidas aparecem em cartões soltos, sem contexto de filtro de período ativo — sem essa âncora, o cálculo compara o período errado.
- **A tabela de calendário original do dataset tinha uma linha por hora de postagem** (data duplicada); foi necessário criar uma tabela calendário própria (1 linha por dia) e relacioná-la à tabela de fatos para viabilizar as medidas de tempo.
- **A "Receita Projetada Próximo Mês" (cartão) usa uma taxa de crescimento média histórica simples e não considera sazonalidade** — por isso pode divergir da tendência real de curto prazo (ex: mesmo com o último mês em queda, a média histórica de crescimento é positiva). O gráfico de **Forecast**, que usa suavização exponencial com sazonalidade de 12 meses, é a referência mais confiável para expectativa de curto prazo.
- **Dataset sintético**: os dados são gerados artificialmente, mas de forma internamente consistente (cliques nunca excedem impressões, conversões nunca excedem cliques, sem valores negativos), permitindo análise de relações de causa e efeito plausíveis dentro do próprio dataset.

---

## ✉️ Contato
Desenvolvido por **Isabelle Rodrigues**  

- 💼 **LinkedIn:** [Isabelle Rodrigues](https://www.linkedin.com/in/isabelle-rodrigues-18177b3b1)
- 🐙 **GitHub:** [IsabelleRodrigues23](https://github.com/IsabelleRodrigues23)
- 📧 **E-mail:** [isabellerodrigues0423@gmail.com](mailto:isabellerodrigues0423@gmail.com)