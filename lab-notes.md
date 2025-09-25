1. Cuantos registros fueron descartados
-- En la tabla B_ORDERS_RAW_COMPLEX  que se carg√≥ desde el fichero original hay 1000 registros 
-- y en la tabla S_ORDERS_CLEAN_COMPLEX han quedado 629 registros, por lo que se han descartado 371 registros

2. Que errores o inconsistencias predominaban
-- 1. Hay 258 registros descartados con el campo qty_ordered menor o igual que 0
-- como se puede comprobar con la siguiente query: SELECT COUNT(*) FROM B_ORDERS_RAW_COMPLEX  WHERE TRY_TO_NUMBER(QTY_ORDERED) <= 0  
-- 2. Hay 146 registros con el campo amt_total nulo, como se puede comprobar en la siguiente query:
-- SELECT COUNT(*) FROM B_ORDERS_RAW_COMPLEX WHERE TRY_TO_NUMBER(AMT_TOTAL) IS NULL 
-- 3. Hay 101 registros con el CAMPO DTE_ORDER incorrecto
-- como se puede comprobar en la siguiente query:  SELECT COUNT(*) FROM B_ORDERS_RAW_COMPLEX WHERE TRY_TO_DATE(DTE_ORDER) IS  NULL
-- 4. Hay 97 registros con el campo id_customer nulo
-- como se puede comprobar en la siguiente query:  SELECT COUNT(*) FROM B_ORDERS_RAW_COMPLEX WHERE ID_CUSTOMER IS  NULL 
-- 5. Hay 92 registros con el campo id_part inv√°lido, como se puede comprobar en la siguiente query:
--  SELECT COUNT(*) FROM B_ORDERS_RAW_COMPLEX WHERE ID_PART IN ('INVALID') 

3. Que validaciones aplicaste (formato, tipos, nulos, valores invalidos)
-- Se valida que el campo DTE_ORDER tenga el formato fecha con el siguiente formato: 'YYYY-MM-DD' y que adem·s ese campo no sea NULL
-- Se valida que el campo identificador de cliente ID_CUSTOMER no sea NULL
-- Se valida que el campo identificador de pieza ID_PART no contenga el texto 'INVALID' 
-- Se valida que el campo AMT_TOTAL sea numÈrico y no sea NULL

4. Propuesta de otras vistas anali≠ticas en Gold

Otras propuestas para la capa Gold podrÌan ser las siguientes:

--TOP TEN CLIENTES QUE HAN GASTADO M¡S
CREATE OR REPLACE VIEW G_TOP_TEN_CLIENTS_IMPORT AS
SELECT ID_CUSTOMER, SUM(AMT_TOTAL) AS TOTAL -- C0362 4278
FROM S_ORDERS_CLEAN_COMPLEX
WHERE AMT_TOTAL IS NOT NULL
GROUP BY ID_CUSTOMER
ORDER BY TOTAL DESC
LIMIT 10

-- TOP TEN CLIENTES QUE HAN COMPRADO M¡S PIEZAS
CREATE OR REPLACE VIEW G_TOP_TEN_CLIENTS_QTY AS
SELECT ID_CUSTOMER,SUM(QTY_ORDERED) AS NUMPIEZAS_TOTAL FROM S_ORDERS_CLEAN_COMPLEX ORD
WHERE QTY_ORDERED IS NOT NULL
GROUP BY ID_CUSTOMER
ORDER BY NUMPIEZAS_TOTAL DESC
LIMIT 10

-- TOP TEN PIEZAS M¡S VENDIDAS
CREATE OR REPLACE VIEW G_TOP_TEN_PARTS AS
SELECT ID_PART,SUM(QTY_ORDERED) AS NUMPIEZAS_TOTAL FROM S_ORDERS_CLEAN_COMPLEX ORD
WHERE QTY_ORDERED IS NOT NULL
GROUP BY ID_PART
ORDER BY NUMPIEZAS_TOTAL DESC
LIMIT 10

--  TOP TEN DE MES EN QUE SE HAN PEDIDO M¡S PIEZAS
CREATE OR REPLACE VIEW G_TOP_TEN_MONTH AS
SELECT   
EXTRACT(MONTH FROM DTE_ORDER) AS MES, 
SUM(QTY_ORDERED) AS PIEZAS_PEDIDAS,
EXTRACT(DAYOFWEEK FROM DTE_ORDER) AS DIA_SEMANA,
DTE_ORDER AS FECHA_COMPLETA 
FROM S_ORDERS_CLEAN_COMPLEX
WHERE QTY_ORDERED IS NOT NULL
GROUP BY DTE_ORDER
ORDER BY PIEZAS_PEDIDAS DESC
LIMIT 10


5. Respuestas a las preguntas del apartado† Preguntas de analisis

La pregunta 1 ya ha sido contestada en un apartado previo øCu·ntos registros fueron descartados por errores? 

øQuÈ proporciÛn de mÈtodos de pago est·n ausentes o mal escritos?
	Para contestar a esta pregunta,
durante la limpieza de datos y para normalizar, se pasa a may˙sculas el string del mÈtodo de pago. Si revisamos cu·ntos valores distintos tiene ese campo, podemos ver que hay sÛlo 5 campos distintos, siendo uno de ellos el campo null.
Por tanto, no hay ning˙n registro con este campo mal escrito, por lo que vamos a contar cu·ntos est·n asuentes. Para ello  miramos cu·ntos registros hay en la capa Silver, que son 619 y luego comprobamos cu·ntos est·n con el campo REF_PAYMENT_METHOD a NULL, que son 119, por tanto (119/629)*100 nos da casi un 19% de registros con ese campo inv·lido.

øCu·l es el ticket medio por pedido?
Si por ticket se entiende la cantidad solicitada serÌa 10.35
SELECT AVG(QTY_ORDERED) FROM S_ORDERS_CLEAN_COMPLEX
Si se refiere a la cantidad total es 766.96
SELECT AVG(AMT_TOTAL) FROM S_ORDERS_CLEAN_COMPLEX 

øCu·ntos pedidos no tienen fecha de entrega informada?
Para contestar, haremos la siguiente consulta: 
SELECT COUNT(*) FROM S_ORDERS_CLEAN_COMPLEX
WHERE DTE_DELIVERY_EST IS null
que nos devuelve 126 registros

