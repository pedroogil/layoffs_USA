----------------------------
-- FASE 0: CREACIÓN BASE DE DATOS
----------------------------
 
CREATE DATABASE layoffs;

-- La importación se realizó a través de Python (Script en otro documento)

use layoffs;
select * from layoffs_data;

----------------------------
-- FASE 1: LIMPIEZA Y PREPARACIÓN DE DATOS
----------------------------

-- Vamos a comprobar ante cuantos registros estamos
select count(*) from layoffs_data; #4.171 resultados

-- Revisando el tipo de datos, ya encontramos varios errores. La mayoría de valores se encuentran en formato texto, a pesar de ser numéricos o fechas

----------------------------
-- 1.1. TIPO DE DATOS
----------------------------

-- company - text. Correcto

-- location - text. Correcto por el momento

-- total_laid_off - double. Incorrecto.
-- Esta variable se refiere al total de despidos, por lo que no tiene sentido que existan despidos en formato decimal. Por si acaso vamos a comprobarlo
select * from layoffs_data where total_laid_off % 1 != 0; #0 resultados, no tenemos valores decimales. Lo mejor será cambiarlo a tipo entero (int)
ALTER TABLE layoffs_data MODIFY	total_laid_off int;

-- date - text. Incorrecto.
-- Fecha en la que se produjo el despido. Este campo lo deberíamos tener en formato fecha. Vamos también a renombrarlo para ganar claridad
ALTER TABLE layoffs_data RENAME COLUMN date to date_layoff;
ALTER TABLE layoffs_data MODIFY date_layoff date; #Nos devuelve error al estar en formato %m/%d/%Y. Vamos a solucionarlo

SET SQL_SAFE_UPDATES= 0;
UPDATE layoffs_data
SET date_layoff = str_to_date(date_layoff, '%m/%d/%Y');
SET SQL_SAFE_UPDATES= 1;

ALTER TABLE layoffs_data MODIFY date_layoff date;

-- percentage_laid_off - text. Incorrecto.
-- Porcentaje del personal total que ha sido despedido. Deberia estar en formato numérico decimal (double)
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_data
SET percentage_laid_off = REPLACE(percentage_laid_off, '%','');
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE layoffs_data MODIFY percentage_laid_off double;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_data
SET percentage_laid_off = percentage_laid_off / 100;
SET SQL_SAFE_UPDATES = 1;

-- industry - text. Correcto

-- source - text. Correcto

-- stage - text. Correcto

-- funds_raised - text. Incorrecto
-- Fondos recaudados por la empresa en millones de $. Aquí deberíamos tenerlo en formato numérico
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_data
SET funds_raised = replace(funds_raised, '$', '');
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE layoffs_data MODIFY funds_raised double;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_data
SET funds_raised = funds_raised *1000000; #Lo dejamos en dólares en vez de en millones de dólares para facilitar el análisis posterior
SET SQL_SAFE_UPDATES = 1;

-- country - text. Correcto por el momento

-- date_added. Es la fecha en la que el despido ha sido añadido al dataset. 
-- Vamos a comprobar si hay registros nulos en nuestra fecha de despido. Si no hay, podríamos eliminar esta fecha, ya que no es relevante para nuestro análisis
select * from layoffs_data where date_layoff IS NULL; #0 resultados

-- Podemos deshacernos de esta columna
ALTER TABLE layoffs_data DROP COLUMN date_added;

----------------------------
-- 1.2. Tabla y modelado de datos
----------------------------

-- Podemos comprobar que nuestra tabla está a nivel de despido, pero no tenemos un identificador único
-- Nos interesa que esté a nivel empresa-despidos-fecha, por lo que vamos a comprobar si hay duplicados
SELECT company, total_laid_off, date_layoff, COUNT(*) as conteo
FROM layoffs_data
GROUP BY company, total_laid_off, date_layoff
HAVING conteo > 1; #4 resultados, vamos a analizarlos uno a uno

-- 1. Oda
SELECT * FROM layoffs_data where company = 'Oda' and total_laid_off = 70; #Parece un error de transcripción de datos. 
-- Investigando en internet, Oda es una compañía con sede en Oslo, y hubo un despido que supuso la reducción del 18% de la plantilla del departamento (6% del total de todo Oda)
-- Como en la mayoría de artículos se habla de reducción de la plantilla general, no por departamento, vamos a quedarnos con el registro del 6%.

SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_data
WHERE company = 'Oda' and percentage_laid_off = 0.18;
SET SQL_SAFE_UPDATES = 1;

-- 2. Beyond Meat
SELECT * FROM layoffs_data where company = 'Beyond Meat' and total_laid_off = 200; #Aquí es un duplicado exacto, cambiando la fuente. Eliminamos uno de los dos registros

SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_data
WHERE source = 'https://www.cnbc.com/2022/10/14/beyond-meat-to-cut-19percent-of-its-workforce-as-sales-stock-struggle.html';
SET SQL_SAFE_UPDATES = 1;

-- 3. Cazoo
SELECT * FROM layoffs_data WHERE company = 'Cazoo' and total_laid_off = 750; #Duplicado exacto, cambiando la fuente. Eliminamos uno de los dos registros
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_data
WHERE source = 'https://sifted.eu/articles/cazoo-layoffs-european-union/';
SET SQL_SAFE_UPDATES = 1;

-- 4. Terminus
SELECT * FROM layoffs_data WHERE company = 'Terminus' and date_layoff = '2022-05-27'; #Duplicado casi exacto, cambiando stage y fondos recaudados. Vamos a quedarnos con el que tiene ronda (stage)
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_data
WHERE company = 'Terminus' and stage = 'Unknown';
SET SQL_SAFE_UPDATES = 1;

-- Ahora si, podemos crear el identificador único de despido a nivel empresa-despidos-fecha
ALTER TABLE layoffs_data ADD id_despido INT auto_increment Primary key;

/*
Se ha valorado la creación de otra tabla a nivel de empresa, 
pero como la misma empresa puede estar en diferentes países o ubicaciones, la reducción de redundancia sería mínima. 
Por ello, optamos por trabajar con una tabla única a nivel de despido, manteniendo la granularidad de cada evento.
Cuando sea necesario, se podrán generar vistas agregadas a nivel empresa para análisis específicos.
*/

----------------------------
-- FASE 2: ANÁLISIS DE NUESTROS DATOS
----------------------------

-- Vamos a utilizar Estados Unidos como país para analizar, ya que es el que cuenta con mayor número de registros
-- Nos centraremos principalmente en el año 2024, el último año completo.
-- Despidos 2023 vs 2024
 
SELECT
	(SELECT SUM(total_laid_off) from layoffs_data where extract(year from date_layoff) = 2023 and country = 'United States') as despidos_2023,
    (SELECT SUM(total_laid_off) from layoffs_data where extract(year from date_layoff) = 2024 and country = 'United States') as despidos_2024,
    (SUM(CASE WHEN YEAR(date_layoff) = 2024 THEN total_laid_off END) -
     SUM(CASE WHEN YEAR(date_layoff) = 2023 THEN total_laid_off END))
     / SUM(CASE WHEN YEAR(date_layoff) = 2023 THEN total_laid_off END) * 100
     AS cambio_2024_vs_2023
FROM layoffs_data
WHERE total_laid_off IS NOT NULL and country = 'United States';

-- De acuerdo con nuestra muestra, se han reducido en torno a un 40% los despidos en Estados Unidos en 2024, respecto a 2023

-- Despidos 2023 vs 2024 industria
with t1 as(
	SELECT industry,
    YEAR(date_layoff) AS año,
    SUM(total_laid_off) AS total_despidos,
    LAG(SUM(total_laid_off)) OVER (PARTITION BY industry ORDER BY YEAR(date_layoff)) AS despidos_año_anterior,
    ROUND(
        (SUM(total_laid_off) - LAG(SUM(total_laid_off)) OVER (PARTITION BY industry ORDER BY YEAR(date_layoff)))
        / LAG(SUM(total_laid_off)) OVER (PARTITION BY industry ORDER BY YEAR(date_layoff)) * 100,
        2
    ) AS cambio_pct_anual
FROM layoffs_data
WHERE industry IS NOT NULL and country = 'United States' 
GROUP BY industry, YEAR(date_layoff)
ORDER BY industry, año)

SELECT industry, cambio_pct_anual
from t1
where año = 2024
order by cambio_pct_anual;

-- Podemos observar que los 5 sectores que parecen haber frenado más el despido de personal son: IA, Data, Retail, ventas y logística
-- Los 5 sectores con más incremento en despidos con respecto a 2023 son: Educación, transporte, infraestructura, energia y fitness

-- Empresas mas despidos 2023 USA vs 2024
SELECT company, sum(total_laid_off) as despidos
from layoffs_data
where year(date_layoff) = 2023 and country = 'United States'
group by company
Order by despidos desc;

-- En 2023, Amazon, Google, Microsoft y Meta fueron las empresas con más despidos reportados, superando los 10.000 

SELECT company, sum(total_laid_off) as despidos
from layoffs_data
where year(date_layoff) = 2024 and country = 'United States'
group by company
Order by despidos desc;

-- En 2024, las empresas con más despidos reportados en Estados Unidos fueron Intel, Tesla, Cisco, Dell y Microsoft.

-- Empresas que han cerrado en 2024
select company, percentage_laid_off, count(percentage_laid_off) OVER() #54 empresas estadounidenses
from layoffs_data
where percentage_laid_off =1 and year(date_layoff) = 2024 and country = 'United States';

/*
Tenemos 54 empresas que han cerrado este 2024 en Estados Unidos, destacando varias start-ups de renombre como:

Forward – clínica de salud digital y promotores de los CarePods: Kioskos de atención médica dirigida por IA.

Exosonic – aeronáutica / vuelos supersónicos. Problemas de financiación

Bowery Farming – agricultura vertical / agtech. Problemas financieros, que incluyen una pesada carga de deuda y la competencia de otros proveedores. 

Redbox – cadena de kioscos de alquiler de DVDs/streaming. Quiebra.

Zapata Computing – computación cuántica. Está llevando a cabo reestructuración
*/
