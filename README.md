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
and food price data are available. The analysis also examines the relationship between GDP growth,
wages, and food prices.

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
- Národní průměrná mzda je určena pomocí záznamů s `industry_branch_code IS NULL`
- Ceny potravin jsou agregovány jako **roční průměry jednotlivých kategorií**
- Analýza pracuje pouze se **společnými roky 2006–2018**
- Primární datové tabulky nebyly nijak upravovány; veškeré transformace probíhají
  až v nově vytvořených tabulkách

---

## Methodology (EN)
- National average wage is calculated using records with `industry_branch_code IS NULL`
- Food prices are aggregated as **yearly averages by category**
- The analysis uses **common years only (2006–2018)**
- Primary source tables are not modified; all transformations are performed
  in newly created tables

---

## Výzkumné otázky a interpretace

---

### Question 1  
**Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**

#### 🇨🇿 Interpretace
Analýza meziročních změn mezd podle jednotlivých odvětví ukazuje, že **ne ve všech odvětvích mzdy rostly nepřetržitě**.  
Ve většině odvětví se v analyzovaném období (2006–2018) vyskytl alespoň jeden rok,
kdy průměrná mzda meziročně klesla.

Pouze v několika odvětvích (např. *Administrativní a podpůrné činnosti*,
*Zdravotní a sociální péče*, *Zpracovatelský průmysl*) mzdy nikdy neklesly –  
buď rostly, nebo zůstaly na stejné úrovni.

**Závěr:**  
Mzdy obecně dlouhodobě rostou, ale **neplatí to rovnoměrně pro všechna odvětví**.

#### 🇬🇧 Interpretation
The year-over-year wage analysis by industry shows that **not all industries experienced continuous wage growth**.  
In most industries, there was at least one year between 2006–2018 when the average wage decreased.

Only a small number of industries showed no wage decreases at all,
meaning wages either increased or stayed constant throughout the period.

**Conclusion:**  
Although wages tend to grow in the long term, **wage growth is not consistent across all industries**.

---

### Question 2  
**Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období?**

#### 🇨🇿 Interpretace
V roce **2006** bylo možné si z průměrné mzdy koupit:
- více litrů mléka
- více kilogramů chleba

V roce **2018** sice průměrná mzda výrazně vzrostla, ale zároveň vzrostly i ceny potravin.  
Výsledkem je, že kupní síla se zvýšila, **avšak nikoli úměrně růstu mezd**.

**Závěr:**  
Kupní síla průměrné mzdy vůči základním potravinám se mezi lety 2006 a 2018 zlepšila,
ale růst cen potravin část tohoto efektu oslabil.

#### 🇬🇧 Interpretation
In 2006, an average wage allowed the purchase of a higher number of liters of milk
and kilograms of bread.

By 2018, average wages increased substantially, but food prices also rose.  
As a result, purchasing power improved, **but not proportionally to wage growth**.

**Conclusion:**  
The purchasing power of the average wage in relation to basic food products increased,
though rising food prices reduced part of the benefit.

---

### Question 3  
**Která kategorie potravin zdražuje nejpomaleji?**

#### 🇨🇿 Interpretace
Na základě průměrného meziročního procentuálního růstu cen vychází jako
**nejpomaleji zdražující kategorie potravin cukr krystalový**
(respektive jiná kategorie s nejnižší hodnotou ve výstupu).

Tyto kategorie vykazují:
- velmi nízký průměrný meziroční růst cen
- v některých letech dokonce pokles ceny

**Závěr:**  
Ne všechny potraviny zdražují stejným tempem;
některé základní produkty mají dlouhodobě velmi stabilní ceny.

#### 🇬🇧 Interpretation
Based on the average year-over-year percentage price change,
the slowest-growing food category was identified (e.g. crystal sugar).

These categories show:
- very low average annual price growth
- occasional price decreases in some years

**Conclusion:**  
Food prices do not increase uniformly;
some staple products show long-term price stability.

---

### Question 4  
**Existuje rok, kdy byl růst cen potravin výrazně vyšší než růst mezd (o více než 10 %)?**

#### 🇨🇿 Interpretace
Analýza rozdílu mezi meziročním růstem cen potravin a mezd ukazuje,
že **v analyzovaném období neexistuje rok**, ve kterém by růst cen potravin
převýšil růst mezd o více než **10 procentních bodů**.

**Závěr:**  
Neexistuje důkaz o extrémním zhoršení dostupnosti potravin vůči mzdám v jediném roce.

#### 🇬🇧 Interpretation
The comparison between year-over-year food price growth and wage growth shows
that there is **no year** in which food prices increased by more than
10 percentage points above wage growth.

**Conclusion:**  
There is no evidence of a single year with a dramatic deterioration
in food affordability relative to wages.

---

### Question 5  
**Má HDP vliv na změny mezd a cen potravin?**

#### 🇨🇿 Interpretace
Porovnání meziročního růstu HDP s růstem mezd a cen potravin ukazuje, že:
- vztah **není jednoznačný**
- vyšší růst HDP se **ne vždy** projeví okamžitě ve mzdách či cenách potravin
- v některých případech lze pozorovat **slabý zpožděný efekt** (v následujícím roce)

**Závěr:**  
HDP samo o sobě **není spolehlivým krátkodobým prediktorem**
růstu mezd ani cen potravin.

#### 🇬🇧 Interpretation
Comparing year-over-year GDP growth with wage and food price growth shows that:
- the relationship is **not consistent**
- higher GDP growth does not always translate immediately into wage or food price increases
- in some cases, a **weak lagged effect** can be observed

**Conclusion:**  
GDP alone is **not a strong short-term predictor**
of wage or food price growth.
