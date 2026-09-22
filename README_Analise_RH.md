# Análise de RH: Perfil e Fatores de Saída

## Objetivo

Este dashboard investiga os principais fatores associados à saída (attrition) de funcionários, buscando identificar padrões que expliquem por que colaboradores deixam a empresa e propor recomendações de retenção baseadas em dados.

## Fonte de Dados

Dataset **[IBM HR Analytics Employee Attrition](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset)**, contendo 1.470 registros de funcionários com informações demográficas, salariais, de satisfação e de histórico na empresa.

## Estrutura do Dashboard

O relatório está organizado em 3 páginas, seguindo uma progressão de profundidade analítica:

1. **Visão Geral** — contexto demográfico e organizacional (headcount, gênero, departamento, escolaridade, faixa etária, cargo).
2. **Fatores de Saída** — análise individual dos principais fatores associados à rotatividade.
3. **Perfil de Risco** — cruzamento dos fatores mais fortes para identificar um perfil combinado de risco elevado.

## Metodologia e Decisões Analíticas

- **Agrupamento em faixas:** variáveis contínuas como "Anos na Empresa", "Idade" e "Anos sem Promoção" foram agrupadas em faixas, em vez de analisadas ponto a ponto. Isso evitou distorções causadas por valores isolados (ex: um único funcionário com 40 anos de empresa gerando uma taxa de 100% de saída) e tornou a leitura estatisticamente mais confiável.
- **Ambiguidade em "Anos desde a Última Promoção":** o valor "0" nessa coluna pode representar tanto uma promoção recente quanto a ausência total de promoção — o dataset não permite diferenciar os dois casos com certeza. Essa limitação foi mantida na análise, mas não deve ser interpretada como certeza absoluta.
- **Escolha de `<=2` em vez de `=1` no perfil de risco:** ao filtrar satisfação e equilíbrio vida-trabalho apenas pelo valor mínimo (1), a amostra resultante era pequena demais (2 pessoas) para gerar um percentual confiável. Ampliar o filtro para os dois níveis mais baixos (1 e 2) resultou em uma amostra de 39 pessoas, tornando o percentual estatisticamente mais robusto.
- **Tradução seletiva:** dado o volume de colunas do dataset original (35 no total), apenas as colunas efetivamente utilizadas nas visualizações foram traduzidas para português, priorizando o tempo de análise sobre a tradução integral da base.

## Principais Achados

Cinco fatores individuais mostraram associação com maior taxa de saída:

- **Hora extra:** funcionários que fazem hora extra saem quase 3x mais (30,53%) do que os que não fazem (10,44%).
- **Satisfação no trabalho:** quem tem satisfação nível 1 sai quase o dobro (23%) comparado a quem tem satisfação nível 4 (11%).
- **Renda mensal:** quem sai da empresa ganha, em média, 30% menos (R$ 4,79 mil) do que quem permanece (R$ 6,83 mil).
- **Tempo de empresa:** os primeiros 2 anos concentram a maior taxa de saída (quase 30%), caindo progressivamente depois.
- **Equilíbrio vida-trabalho:** segue o mesmo padrão de satisfação — quanto menor o equilíbrio percebido, maior a taxa de saída.

Outros fatores investigados (estado civil, escolaridade, % de aumento salarial, proporção de carreira no cargo atual) não apresentaram relação relevante com a saída, e foram documentados como hipóteses testadas sem resultado significativo.

**Efeito cumulativo:** quando os três fatores mais fortes são combinados — hora extra, baixa satisfação e baixo equilíbrio vida-trabalho — a taxa de saída sobe para **41,03%** (amostra de 39 funcionários), mais que o dobro da taxa geral da empresa (16,12%). Isso indica que os fatores se reforçam mutuamente, e não atuam de forma isolada.

## Recomendação

Recomenda-se que a área de RH priorize o monitoramento de funcionários que se enquadram nesse perfil combinado, especialmente nos primeiros dois anos de empresa, período em que a rotatividade é mais concentrada. Ações como revisão da política de horas extras e acompanhamento próximo da satisfação no início do vínculo podem ter maior impacto na retenção do que medidas genéricas aplicadas a toda a base de funcionários.

## Limitações

- O dataset é sintético/anonimizado, sem dimensão temporal real (datas de admissão/desligamento), o que impossibilitou análises de tendência ao longo do tempo ou simulações "e se".
- A ambiguidade da coluna "Anos desde a Última Promoção" (detalhada acima) é uma limitação conhecida da base original.
- Amostras pequenas em cruzamentos muito específicos (ex: filtros com 3+ condições simultâneas) podem gerar percentuais menos confiáveis — por isso, faixas e agrupamentos foram usados sempre que necessário.

## Ferramentas

Power BI Desktop (Power Query, DAX, modelagem de dados).

---

## ✉️ Contato
Desenvolvido por **Isabelle Rodrigues**  

- 💼 **LinkedIn:** [Isabelle Rodrigues](https://www.linkedin.com/in/isabelle-rodrigues-18177b3b1)
- 🐙 **GitHub:** [IsabelleRodrigues23](https://github.com/IsabelleRodrigues23)
- 📧 **E-mail:** [isabellerodrigues0423@gmail.com](mailto:isabellerodrigues0423@gmail.com)
