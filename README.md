# Proyecto Tech Layoffs: Limpieza, análisis y visualización

En este proyecto trabajé con el dataset público de Layoffs.fyi, que recopila despidos tecnológicos desde marzo de 2020 a la actualidad (fuentes como Bloomberg, TechCrunch, The New York Times, entre otros).

El objetivo fue limpiar, modelar y analizar los datos en SQL para identificar tendencias de despidos en Estados Unidos, con foco en el año 2024. Finalmente, visualicé los resultados con Power BI para obtener insights claros y comparables.

## 🛠️ Flujo de trabajo end-to-end

### 1. Carga de datos

Importación de archivos CSV mediante Python.

### 2. Limpieza y normalización (SQL)

Corrección de tipos de datos (fechas, enteros, decimales).

Eliminación de duplicados y registros inconsistentes (ej: Oda, Beyond Meat, Cazoo, Terminus).

Creación de un identificador único por evento de despido.

Homogeneización de variables como percentage_laid_off y funds_raised.

### 3. Análisis exploratorio (SQL)

Comparativa de despidos por año y variación interanual (2023 vs 2024).

Evolución por industria y sectores con mayor reducción o incremento de despidos.

Ranking de empresas con más despidos en 2023 y 2024.

Identificación de compañías que cerraron operaciones en 2024.

## 📊 Técnicas SQL aplicadas

Limpieza y modelado de datos

ALTER TABLE, UPDATE, REPLACE para normalización.

Eliminación de redundancias y creación de clave primaria id_despido.

Consultas de explotación y análisis

Subconsultas y CTEs para comparar variaciones anuales.

Funciones de ventana (LAG(), OVER()) para cálculos de tendencias.

Agregaciones por industria y empresa (SUM, COUNT, GROUP BY).

## 🚀 Hallazgos más importantes

En 2024 se registró una reducción de ~40% en despidos tech en EE. UU. respecto a 2023.

IA y Data fueron los sectores con mayor caída de despidos (-92% y -86% respectivamente).

Educación, Transporte e Infraestructura mostraron los mayores incrementos (+231%, +198%, +170%).

Las empresas con más despidos reportados en 2023 fueron Amazon, Google, Microsoft y Meta.

En 2024 el protagonismo cambió hacia Intel, Tesla, Cisco, Dell y Microsoft.

54 empresas cerraron operaciones en 2024, incluyendo casos como Forward (healthtech), Exosonic (aeronáutica supersónica) y Redbox (streaming/DVD).

## 🗄️ Dataset

Fuente: 'Layoffs Dataset' - Kaggle. Obtenido de: Layoffs.fyi

Cobertura: Marzo 2020 – Abril 2025

Granularidad: Evento de despido por empresa/ubicación/fecha

Limitaciones:

Algunos despidos reportados sin cifras exactas.

Varias empresas con fuentes duplicadas o inconsistentes.

Dataset no exhaustivo: refleja los casos reportados en medios, no el 100% del mercado.

## 📂 Estructura del repositorio

layoffs_cleaning_analysis.sql → Scripts de limpieza, normalización y modelado. Parte 2: Consultas SQL con análisis exploratorio.

layoffs.pbix → Visualización con insights clave.

README.md → Documentación del proyecto.

## 🤝 ¡Hablemos!
👤 Pedro Gil Olivares

🔗 www.linkedin.com/in/pedro-gil-olivares-485517216

📧 pedrogilolivares009@gmail.com
