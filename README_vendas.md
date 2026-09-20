# Análise de Vendas e Logística — E-commerce Olist

Dashboard em Power BI construído a partir do [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), cobrindo vendas, geografia, logística, satisfação do cliente e projeção de curto prazo.

## Sobre o projeto

Esse dashboard nasceu como treino de DAX e Power BI, mas evoluiu para uma análise completa depois que uma série de inconsistências reais no dataset foram identificadas e corrigidas ao longo do processo. A maior parte do valor deste projeto está justamente nessas correções — elas representam o tipo de "sujeira" de dado real que aparece em ambientes de trabalho, não em datasets de curso já tratados.

## Estrutura do Dashboard (4 páginas)

1. **Visão Geral & Presente** — KPIs principais, faturamento por estado e categoria, forma de pagamento, distribuição de pedidos por dia da semana, frete médio por estado (Top N)
2. **Passado (Tendências e Sazonalidade)** — evolução mensal e anual do faturamento, sazonalidade por trimestre, atrasos por mês e por estado
3. **Satisfação do Cliente** — distribuição de avaliações, nota média por estado e por categoria, impacto do atraso na nota do cliente
4. **Projeções e Tendência Futura** — variação mês a mês, taxa de crescimento média, projeção do próximo mês, tendência de atraso, e conclusão consolidada com recomendações

## Período considerado

**Janeiro/2017 a agosto/2018.**

Os dados de 2016 e de setembro/outubro de 2018 foram excluídos da análise. Esse recorte é uma prática recomendada por outras análises públicas desse mesmo dataset: o volume de pedidos nas pontas do período é extremamente baixo, refletindo o início e o corte da coleta de dados, não um comportamento real de negócio. Manter esses meses distorceria qualquer métrica de tendência ou variação percentual.

## Problemas de dado encontrados e como foram tratados

Esta seção documenta as principais inconsistências identificadas durante a construção do dashboard, junto com o raciocínio usado para corrigi-las.

### 1. Escala incorreta em colunas monetárias (centavos vs. reais)
As colunas `price` e `freight_value` estavam armazenadas como valores inteiros representando centavos (ex.: `5890` em vez de `58,90`), inflando o faturamento total em 100x. Corrigido dividindo as colunas por 100 no Power Query (Transformar → Número → Padrão → Dividir → 100).

### 2. Período de coleta incompleto nas pontas do dataset
Setembro/outubro de 2018 apresentam volume de pedidos próximo de zero, e o ano de 2016 tem apenas alguns pedidos residuais em outubro/novembro. Resolvido com um filtro de relatório restringindo todas as páginas ao intervalo jan/2017–ago/2018.

### 3. Funções de time intelligence sensíveis a contexto de filtro
Medidas como `SAMEPERIODLASTYEAR` e `DATEADD`, quando avaliadas em cards sem um mês/ano específico no contexto (ex.: fora de uma tabela ou slicer), produziam resultados incorretos porque deslocavam a tabela de datas inteira, não um período específico. A correção adotada foi ancorar as medidas em uma data de referência explícita (`MAX(Calendario[Date])` dentro de visuais filtrados, ou uma data fixa dentro de tabelas calculadas — ver item 6) e usar `FILTER(ALL(Calendario), ...)` para isolar exatamente o ano/mês desejado, em vez de depender do deslocamento automático dessas funções.

### 4. Comparação Ano a Ano (YoY) com períodos de tamanhos diferentes
Comparar 2018 (truncado em agosto) contra 2017 (ano cheio) inflava artificialmente o crescimento. Corrigido com uma lógica de **YTD vs. PYTD** (Year-to-Date vs. Previous-Year-to-Date), comparando o mesmo intervalo de meses nos dois anos (jan-ago/2018 vs. jan-ago/2017).

### 5. Taxa de crescimento média distorcida por meses de transição
O primeiro mês do período filtrado (jan/2017) calculava sua variação percentual contra dezembro/2016 — um mês com faturamento residual de poucos reais, gerando uma variação percentual de milhares de %. Corrigido filtrando meses com variação absoluta acima de 300% antes de calcular a média (`FILTER(..., ABS([MoM]) < 3)`), tratando-os como ruído de transição de dados, não como sinal real de negócio.

### 6. Tabelas calculadas não respeitam filtro de relatório
Diferente de medidas usadas em visuais, uma tabela calculada (DAX `Nova Tabela`) é processada uma única vez, na atualização dos dados, e **não é afetada pelo filtro de página/relatório**. Isso fez com que `MAX(Calendario[Date])` dentro de uma tabela calculada retornasse a última data da tabela Calendario inteira (31/12/2018, incluindo meses sem nenhum pedido), em vez do último mês do período analisado (agosto/2018). Corrigido fixando a data de referência explicitamente (`DATE(2018,8,1)`) dentro da tabela calculada.

### 7. Viés de censura à direita nos indicadores de atraso
Atraso só é identificado após a entrega do pedido (comparação entre data prometida e data real de entrega). Pedidos dos meses mais recentes do período ainda não tiveram tempo hábil de serem entregues, fazendo esses meses parecerem artificialmente "no prazo". Corrigido defasando a métrica de tendência de atraso em 2 meses em relação ao mês mais recente do filtro (compara junho vs. maio de 2018, não agosto vs. julho), dando margem de tempo suficiente para a maioria das entregas serem concluídas.

### 8. Linhas duplicadas na tabela de avaliações
A tabela `olist_order_reviews_dataset` contém `review_id` duplicados — o mesmo review (mesma nota, mesmo texto, mesmo timestamp) associado a `order_id` diferentes, um problema de integridade já relatado por outras análises públicas desse dataset. Isso inflava a contagem total de avaliações (mas não a nota média, já que os valores duplicados são idênticos). Corrigido usando `SUMMARIZE` por `review_id`/`order_id` antes de qualquer contagem ou média, eliminando as duplicatas do cálculo.

### 9. Atribuição de nota por categoria (limitação, não erro)
Como a avaliação é feita por pedido e um pedido pode conter produtos de categorias diferentes, a nota de um único pedido pode ser contabilizada em mais de uma categoria na análise "Nota Média por Categoria". Essa é uma limitação inerente à granularidade do dado, não um erro de cálculo — está documentada aqui para transparência.

## Principais Insights

- **Concentração geográfica**: São Paulo lidera com folga em volume de pedidos e faturamento.
- **Forma de pagamento**: crédito representa ~81% do faturamento, frente a ~18% de boleto.
- **Gargalo logístico regional**: estados do Norte/Nordeste (RR, PB, RO, AC, PI, MA) têm frete médio até 3x mais caro que a média nacional, refletindo a distância da concentração de vendedores no Sudeste.
- **Logística afeta satisfação**: pedidos atrasados recebem, em média, quase 1 ponto a menos de avaliação (nota cai de ~4,1 para ~3,0), e as regiões com frete mais caro coincidem com as de menor nota média.
- **Momento atual**: crescimento médio mensal de 14,24%, mas o último mês do período mostrou retração de -4,56% — sinal de possível desaceleração a monitorar.
- **Projeção**: com base na taxa de crescimento média, o faturamento projetado para o mês seguinte ao período analisado é de ~R$ 976 mil.
- **Tendência de atraso**: melhora de -6,77 p.p. no indicador de atraso (comparação com defasagem de 2 meses), uma leitura positiva para a experiência do cliente.

## Ferramentas

- Power BI Desktop (modelagem, DAX, visualização)
- Power Query (limpeza e transformação de dados)

## Autor

Projeto desenvolvido como parte de portfólio de transição de carreira para análise de dados.
