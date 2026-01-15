# Projekt z SQL – Dostupnost potravin v ČR  
# SQL Project – Food Affordability in the Czech Republic

---

## Úvod (CZ)
Cílem tohoto projektu je analyzovat vývoj mezd a cen základních potravin v České republice
a posoudit jejich dostupnost v čase. Analýza vychází z otevřených dat Českého statistického úřadu
a dalších veřejných zdrojů.

Projekt se zaměřuje na srovnatelné období let **2006–2018**, ve kterém jsou dostupná jak data o mzdách,
tak data o cenách potravin. Součástí analýzy je také posouzení vztahu mezi vývojem HDP,
mzdami a cenami potravin.

Výstupem projektu jsou dvě analytické tabulky a sada SQL dotazů,
které slouží jako datový podklad pro odpovědi na definované výzkumné otázky.

---

## Introduction (EN)
The goal of this project is to analyze the development of wages and prices of basic food products
in the Czech Republic and to assess their affordability over time.
The analysis is based on open data published by the Czech Statistical Office
and other public data sources.

The project focuses on the comparable period **2006–2018**, during which both wage
and food price data are available. The analysis also examines the relationship
between GDP growth, wages, and food prices.

The main outputs of the project are two analytical tables and a set of SQL queries
that provide data-driven answers to the defined research questions.

---

## Použité datové sady (CZ)
- `czechia_payroll` – informace o mzdách v České republice  
- `czechia_price` – ceny vybraných potravin  
- `countries` – základní informace o státech  
- `economies` – HDP, GINI koeficient a populace  

---

## Used Datasets (EN)
- `czechia_payroll` – wage data in the Czech Republic  
- `czechia_price` – prices of selected food products  
- `countries` – basic country information  
- `economies` – GDP, GINI coefficient, and population  

---

## Metodologie (CZ)
- Analýza pracuje pouze se **společnými roky 2006–2018**
- Mzdy jsou analyzovány **podle jednotlivých odvětví**
- Ceny potravin jsou agregovány jako **roční průměry jednotlivých kategorií**
- Primární datové tabulky nebyly upravovány; veškeré transformace probíhají
  až v nově vytvořených tabulkách nebo CTE

---

## Methodology (EN)
- The analysis uses **common years only (2006–2018)**
- Wages are analyzed **by individual industries**
- Food prices are aggregated as **yearly averages by category**
- Primary source tables are not modified; all transformations are performed
  in newly created tables or CTEs

---

## Výzkumné otázky a interpretace  
## Research Questions and Interpretation

---

### Question 1  
**Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**  
**Do wages grow over time in all industries, or do some industries experience declines?**

#### 🇨🇿 Interpretace
Analýza meziročních změn mezd v období **2006–2018** ukazuje, že **ne ve všech odvětvích mzdy rostly nepřetržitě**.

- Z celkem **19 sledovaných odvětví** zaznamenalo **14 odvětví alespoň jeden rok poklesu mezd**
- Pouze **5 odvětví** nevykázalo žádný meziroční pokles (mzdy pouze rostly nebo stagnovaly)

Například:
- **Těžba a dobývání** zaznamenala pokles mezd ve **4 různých letech**
- **Zdravotní a sociální péče** nezaznamenala žádný pokles mezd

**Závěr:**  
Mzdy dlouhodobě rostou, avšak **krátkodobé poklesy jsou v řadě odvětví běžné**.

#### 🇬🇧 Interpretation
The year-over-year wage analysis for **2006–2018** shows that **wages did not grow continuously in all industries**.

- Out of **19 analyzed industries**, **14 experienced at least one year of wage decline**
- Only **5 industries** showed no wage decreases at all

For example:
- **Mining and quarrying** recorded wage declines in **4 different years**
- **Health and social care** showed no wage decline during the entire period

**Conclusion:**  
While wages grow in the long term, **short-term declines are common across many industries**.

---

### Question 2  
**Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?**  
**How many liters of milk and kilograms of bread could an average person buy in the first and last comparable period?**

#### 🇨🇿 Interpretace
V roce **2006** činila průměrná mzda přibližně **20 342 Kč**.  
Za tuto mzdu bylo možné koupit:
- cca **1 409 litrů mléka** (cena ~ **14,4 Kč/l**)
- cca **1 262 kg chleba** (cena ~ **16,1 Kč/kg**)

V roce **2018** vzrostla průměrná mzda na cca **31 980 Kč**, ale ceny potravin také vzrostly:
- mléko ~ **19,8 Kč/l**
- chléb ~ **24,2 Kč/kg**

Kupní síla v roce 2018:
- cca **1 614 litrů mléka**
- cca **1 319 kg chleba**

**Závěr:**  
Kupní síla se zvýšila, ale **růst cen potravin výrazně oslabil efekt růstu mezd**.

#### 🇬🇧 Interpretation
In **2006**, the average wage was approximately **20,342 CZK**, allowing the purchase of:
- about **1,409 liters of milk**
- about **1,262 kilograms of bread**

By **2018**, the average wage increased to around **31,980 CZK**, but food prices also rose.

Purchasing power in 2018:
- about **1,614 liters of milk**
- about **1,319 kilograms of bread**

**Conclusion:**  
Purchasing power increased, but **food price growth significantly reduced the impact of wage growth**.

---

### Question 3  
**Která kategorie potravin zdražuje nejpomaleji?**  
**Which food category increases in price the slowest?**

#### 🇨🇿 Interpretace
Nejpomaleji zdražující kategorií potravin byl **cukr krystalový**,
s průměrným meziročním růstem **−1,92 %**.

Další pomalu zdražující kategorie:
- Rajská jablka: **−0,74 %**
- Banány: **+0,81 %**

Naopak nejrychleji zdražovaly:
- Papriky: **+7,29 %**
- Máslo: **+6,67 %**

**Závěr:**  
Vývoj cen potravin je velmi nerovnoměrný a některé základní potraviny
vykazují dlouhodobou cenovou stabilitu.

#### 🇬🇧 Interpretation
The slowest-growing food category was **crystal sugar**, with an average YoY change of **−1.92 %**.

In contrast, some products showed rapid price growth, such as peppers (**+7.29 %**) and butter (**+6.67 %**).

**Conclusion:**  
Food price development is highly uneven across categories.

---

### Question 4  
**Existuje rok, kdy byl růst cen potravin výrazně vyšší než růst mezd (o více než 10 %)?**  
**Is there a year when food price growth exceeded wage growth by more than 10 percentage points?**

#### 🇨🇿 Interpretace
V žádném roce mezi **2007–2018** nepřesáhl rozdíl mezi růstem cen potravin
a růstem mezd hranici **10 procentních bodů**.

Nejvyšší zaznamenaný rozdíl činil přibližně **9,6 p. b. (rok 2017)**.

**Závěr:**  
Nedochází k extrémnímu meziročnímu zhoršení dostupnosti potravin vůči mzdám.

#### 🇬🇧 Interpretation
In none of the analyzed years did the difference exceed **10 percentage points**.
The highest observed difference was approximately **9.6 pp in 2017**.

**Conclusion:**  
There is no evidence of a year with extreme deterioration in food affordability.

---

### Question 5  
**Má HDP vliv na změny mezd a cen potravin?**  
**Does GDP influence changes in wages and food prices?**

#### 🇨🇿 Interpretace
Vztah mezi růstem HDP, mezd a cen potravin není jednoznačný.

Například:
- V roce **2009** kleslo HDP o **−4,7 %**, zatímco mzdy vzrostly o **+3,25 %**
- V roce **2013** HDP stagnovalo (**−0,05 %**), ale ceny potravin vzrostly o více než **+5 %**

Slabý zpožděný efekt lze pozorovat pouze v některých letech.

**Závěr:**  
HDP samo o sobě **není spolehlivým krátkodobým prediktorem**
vývoje mezd ani cen potravin.

#### 🇬🇧 Interpretation
The relationship between GDP growth and wage or food price changes is inconsistent.

For example:
- In **2009**, GDP declined by **−4.7 %**, while wages still increased
- In **2013**, GDP stagnated, yet food prices rose by over **5 %**

**Conclusion:**  
GDP alone is **not a strong short-term predictor**
of wage or food price growth.
