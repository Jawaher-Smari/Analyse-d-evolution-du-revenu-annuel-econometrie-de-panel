# Projet économétrique

## Introduction

Ce projet représente une analyse économétrique explicative traitant un dataset de 100 entreprises sur la période 2017-2022.

## Présentation du dataset

La base de données est un panel cylindré, avec N = 100 entreprises, T = 6 années (2017-2022), soit N×T = 600 observations. Chaque entreprise est observée exactement six fois et il n’y a aucune valeur manquante.

Les variables présentées sont au nombre de 8. Nous avons choisi *Revenue Growth* comme variable à expliquer et conservé les autres comme variables explicatives.

## Détails sur les variables

En observant le dataset, on constate que la variable dépendante **Revenue Growth (RG)** représente le logarithme du revenu annuel de chaque entreprise. RG varie entre 9,986 et 13,301, ce qui correspond à des revenus allant approximativement de e⁹·⁹⁹ ≈ 21 760 $ à e¹³·³⁰ ≈ 595 000 $.

Les variables restantes représentent des indices avec des intervalles variés.

| Code | Nom complet | Description |
|------|-------------|-------------|
| RG | Revenue Growth | Revenu annuel qui capture la performance économique de chaque firme |
| ADS | Adoption of Data Science | Degré d’utilisation des outils analytiques (IA, ML, big data) dans les processus décisionnels |
| DAQ | Data Accessibility and Quality | Qualité et accessibilité des données internes (collecte, stockage, gouvernance) |
| OI | Organizational Innovation | Culture d’innovation, prise de risque et acceptation du changement |
| CFP | Company Financial Performance | Santé financière globale conditionnant la capacité d’investissement technologique |
| DTS | Data Science Training & Skills | Niveau de compétences et de formation des employés en data science |
| LSI | Legacy Systems Integration | Difficultés d’intégration des systèmes informatiques anciens |
| RC | Resistance to Change | Résistance organisationnelle aux pratiques data‑driven |

## Définition de la question métier

Parmi les facteurs listés dans le dataset, quels sont les plus susceptibles de contribuer à l’évolution économique des revenus des entreprises dans le contexte d’adoption de la data science ?

## Analyse descriptive

### Statistiques descriptives

- **Variable dépendante RG** : dispersion importante (écart‑type = 0,605 en log), ce qui traduit d’importantes différences de taille entre entreprises.
- **Variable DTS** : écart‑type très proche de 0, ce qui montre que la majorité des entreprises affiche des niveaux de formation faibles.
- **Variables LSI et RC** : certaines entreprises présentent des niveaux exceptionnellement élevés de difficultés d’intégration ou de résistance au changement.
- **Variables ADS, DAQ, OI, CFP** : moyennes légèrement négatives.

### Matrice de corrélation

Les corrélations entre régresseurs sont extrêmement élevées :  
ADS/LSI (r = 0,946), DAQ/RC (r = 0,953), ADS/RG (r = 0,931), CFP/RG (r = 0,950). Ces valeurs dépassent largement le seuil de 0,70.

### Visualisation préliminaire

**Visualisation temporelle** : le graphique montre une tendance globale ascendante, suggérant la présence d’effets temporels communs (λₜ ≠ 0). Économiquement, cela peut refléter la croissance macroéconomique générale sur la période ou l’expansion du marché digital.

**Visualisation individuelle** : chaque point représente le log‑revenu moyen d’une entreprise sur l’ensemble de la période. Un point très éloigné de la moyenne indique une entreprise nettement plus grande ou plus petite que la médiane. Cette dispersion des RGᵢ est la manifestation empirique des effets individuels αᵢ que l’on cherche à modéliser.

## Application des modèles économétriques

### 1. Modèle MCO empilé (Pooled)

Le modèle *pooled* empile les 600 observations et les traite comme si elles étaient indépendantes.  
**Spécificité violée** : il ne donne des estimateurs MCO non biaisés que si les effets individuels sont nuls (αᵢ = 0), ce qui n’est pas le cas dans notre dataset.  

→ ADS et DTS sont les plus significatives, avec un R² important mais qui s’explique en partie par la forte corrélation entre les variables et par l’hétérogénéité individuelle non contrôlée.

### 2. Modèle Within (Fixed Effects)

L’estimateur *Within* élimine les effets individuels αᵢ en centrant chaque observation par sa moyenne temporelle.  
**Spécificité violée** : il n’examine que les variations intra‑individuelles. De plus, si les effets inobservables individuels sont corrélés avec les régresseurs, ces derniers seront corrélés avec l’erreur, d’où un biais d’endogénéité.  

→ L’intercept global est absorbé par les 100 effets fixes individuels. ADS, DTS et CFP sont les plus significatives.

### 3. Modèle Between

Ce modèle remplace chaque observation par la moyenne individuelle de chaque entité.  
**Spécificité violée** : il aplatit les données en écartant complètement les effets temporels.  

→ Beaucoup de variables perdent leur significativité, seule CFP se maintient. Le R² est très élevé mais calculé sur seulement 100 moyennes, ce qui le rend moins fiable qu’un R² calculé sur 600 observations.

### 4. Modèle à effets aléatoires (Random Effects)

Ce modèle prend en considération tout effet inobservable possible en combinant *Within* et *Between*.  
**Spécificité violée** : il suppose, lors du traitement des données, que les αᵢ ne sont pas corrélés avec les régresseurs X.  

→ L’exploitation conjointe des deux dimensions du panel se manifeste par l’apparition du degré de significativité de chaque variable du dataset. ADS, CFP et DTS sont les plus significatives, puis LSI (second degré), et enfin DAQ et OI.

## Comparaison des modèles

**Remarque** : dans tous les modèles, la variable RC ne présente aucune significativité pour expliquer le comportement de RG. On peut donc l’écarter de notre étude, puisque notre objectif est de trouver les facteurs d’évolution de RG.

En ce qui concerne le R², chaque modèle présente une spécificité violée, ce qui implique l’application de tests de spécification pour choisir le bon modèle.

## Tests de spécification

### 1. Test de Fisher

Pour vérifier l’existence d’une hétérogénéité individuelle.  
→ La p‑valeur est pratiquement nulle, donc on rejette H₀ par confirmation de l’existence d’effets individuels et de la non‑efficience d’une simple estimation MCO.  
**Interprétation économique** : les 100 entreprises ont des niveaux de revenu structurellement différents, et il serait erroné de les traiter comme identiques.

### 2. Test LM de Breusch‑Pagan

Pour vérifier l’existence d’effets aléatoires significatifs.  
→ La p‑valeur est quasi nulle, donc on rejette H₀ : la variance inter‑individuelle est bien différente de zéro.  
**Interprétation économique** : les entreprises présentent des différences autres que leurs seules variations *within* individuelles.

### 3. Test de Hausman

La conjonction des deux tests (Fisher et LM) confirme sans ambiguïté la présence d’effets individuels significatifs et la nécessité d’un modèle avec effets.  
→ La p‑valeur est égale à 0,064 : on ne rejette pas H₀. Rien ne prouve statistiquement que les effets individuels sont corrélés avec les régresseurs. Le modèle à effets aléatoires (MCG) est donc préféré au modèle *Within*. Même en cas de corrélation modérée entre les régresseurs et αᵢ, la variation *between* est largement supérieure à la variation *within*, ce qui implique l’utilisation d’un modèle prenant en compte les effets inobservables, surtout ceux qui ne varient pas dans le temps (impossible à traiter avec un modèle à effets fixes).  
**Le modèle retenu est donc le modèle à effets aléatoires.**

## Diagnostic des résidus avant correction

Trois problèmes fréquents peuvent invalider nos résultats : l’autocorrélation (les erreurs sont liées entre elles dans le temps), l’hétéroscédasticité (la variance des erreurs n’est pas constante) et la dépendance transversale (les erreurs de deux entreprises différentes sont liées).

1. **Test de Breusch‑Godfrey (autocorrélation sérielle)**  
   La p‑valeur est inférieure à 0,05 : on rejette H₀, il y a bien de l’autocorrélation.  
   → Les résidus d’une année sont liés à ceux de l’année précédente.

2. **Test de Breusch‑Pagan (hétéroscédasticité)**  
   La p‑valeur est inférieure à 0,05 : on rejette H₀, la variance des résidus n’est pas constante.  
   → Certaines entreprises ont des résidus systématiquement plus grands que d’autres.

3. **Test de Pesaran CD (dépendance transversale)**  
   La p‑valeur est quasi nulle : on rejette H₀, les résidus des entreprises sont corrélés entre eux à une même date.

Ces problèmes ne biaisent pas les coefficients du modèle à effets aléatoires retenu, mais ils rendent les écarts‑types classiques invalides. Pour obtenir des inférences fiables, on peut appliquer deux méthodes de correction robuste.

### 1. Méthode de Driscoll‑Kraay

Cette méthode corrige simultanément les trois anomalies.  
→ Toutes les variables (sauf OI) deviennent très significatives, et les écarts‑types sont nettement plus petits que ceux du modèle RE classique. Or, une correction robuste a normalement pour effet d’augmenter les écarts‑types. Cette baisse anormale suggère que, dans notre panel court (T=6) et en présence d’une dépendance transversale extrême (test CD : z = 8,71), la méthode de Driscoll‑Kraay sous‑estime la variance. Ces résultats sont donc considérés comme trop optimistes et non fiables.

### 2. Double clustering (entreprise + année)

Cette méthode permet de corriger en même temps la corrélation temporelle et la dépendance transversale entre les firmes, sans faire d’hypothèse forte sur leur forme.  
→ Seules ADS, CFP, DTS et LSI conservent un effet statistiquement significatif. Les variables DAQ, OI et RC ne sont plus significatives. Ces résultats sont cohérents avec l’idée que l’adoption de la data science, la performance financière, la formation spécialisée et la facilité d’intégration des nouvelles approches IT sont les véritables moteurs du revenu annuel, tandis que les autres facteurs n’ont pas d’effet propre.

En comparant les résultats, la correction par double clustering est retenue comme la méthode la plus fiable pour cette étude.

**Limite** : la multicolinéarité sévère (ADS‑LSI : r = 0,95 ; DAQ‑RC : r = 0,95) empêche de distinguer l’effet propre de LSI et RC.

## Réponse à la question métier

En se basant sur les valeurs des coefficients associés aux régresseurs et leurs degrés de significativité, on peut conclure que :

- **ADS** : un coefficient positif et significatif confirme qu’une intensification de l’utilisation des outils analytiques se traduit par une augmentation majeure du revenu annuel.
- **CFP** : une telle significativité est attendue. Une entreprise qui investit davantage devient plus rentable.
- **DTS** : de même, un signal positif a été observé. Une entreprise qui investit de plus en plus dans la formation de ses équipes atteint des revenus plus élevés.
- **OI et DAQ** : même avec des coefficients positifs, ces deux facteurs n’ont pas d’effets majeurs au niveau du gain financier.
- **LSI et RC** : leurs coefficients sont économiquement logiques. Les organisations résistantes à l’adoption de nouvelles pratiques ou présentant plus de systèmes anciens tirent moins de bénéfices de leurs investissements en data science.
