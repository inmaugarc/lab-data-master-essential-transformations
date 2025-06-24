![logo_ironhack_blue 7](https://user-images.githubusercontent.com/23629340/40541063-a07a0a8a-601a-11e8-91b5-2f13e4e6b441.png)

# Lab | Comandos esenciales de SQL y Transformaciones sobre datos “sucios”

## 🎯 Objetivo

Practicar los comandos fundamentales de SQL y aplicar transformaciones reales sobre un dataset cargado en Snowflake (en este caso, `B_ORDERS_RAW_COMPLEX.csv`). Reforzarás el uso de DDL, DML, DQL, TCL, DCL, así como joins y subconsultas para transformar, limpiar y validar datos de forma eficiente.

## Requisitos

* Haz un ***fork*** de este repositorio.
* Clona este repositorio.

## Entrega

- Haz Commit y Push
- Crea un Pull Request (PR)
- Copia el enlace a tu PR (con tu solución) y pégalo en el campo de entrega del portal del estudiante – solo así se considerará entregado el lab

## 🗂️ 1. Tipos de Comandos SQL

### 🔧 DDL – Data Definition Language

```sql
-- Crear esquema y tabla
CREATE SCHEMA IF NOT EXISTS DEV_SQL_LAB.S_SANDBOX;

CREATE OR REPLACE TABLE DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN (
  ID_ORDER STRING,
  DTE_ORDER DATE,
  ID_CUSTOMER STRING,
  ID_PART STRING,
  QTY_ORDERED NUMBER,
  AMT_TOTAL NUMBER(10,2),
  REF_PAYMENT_METHOD STRING,
  DTE_DELIVERY_EST DATE,
  DES_ORDER_NOTE STRING
);
```

### ✍️ DML – Data Manipulation Language

```sql
-- Insertar registros
INSERT INTO DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN (
  ID_ORDER, DTE_ORDER, ID_CUSTOMER, ID_PART, QTY_ORDERED, AMT_TOTAL
) VALUES
('ORD9999', '2025-06-25', 'C9999', 'P9999', 3, 249.99);

-- Actualizar datos
UPDATE DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN
SET QTY_ORDERED = 5
WHERE ID_ORDER = 'ORD9999';

-- Eliminar datos
DELETE FROM DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN
WHERE ID_ORDER = 'ORD9999';
```

### 🔍 DQL – Data Query Language

```sql
-- Consulta simple
SELECT ID_ORDER, QTY_ORDERED, AMT_TOTAL
FROM DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN
WHERE QTY_ORDERED > 5
ORDER BY AMT_TOTAL DESC;

-- Subconsulta: pedidos con importe mayor al promedio
SELECT *
FROM DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN
WHERE AMT_TOTAL > (
  SELECT AVG(AMT_TOTAL) 
  FROM DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN
);
```

### 🔁 TCL – Transaction Control Language

```sql
-- Empezar una transacción (solo útil si AUTO-COMMIT está desactivado)
BEGIN;

-- Modificación temporal
UPDATE DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN
SET AMT_TOTAL = AMT_TOTAL * 0.9
WHERE REF_PAYMENT_METHOD = 'CASH';

-- Revertir la transacción
ROLLBACK;

-- Rehacer la operación con confirmación
UPDATE DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN
SET AMT_TOTAL = AMT_TOTAL * 0.9
WHERE REF_PAYMENT_METHOD = 'CASH';

COMMIT;
```

### 🔐 DCL – Data Control Language

```sql
-- Dar privilegios de lectura
GRANT SELECT ON DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN TO ROLE ANALYST_ROLE;

-- Revocar privilegios
REVOKE SELECT ON DEV_SQL_LAB.S_SANDBOX.S_ORDERS_CLEAN FROM ROLE ANALYST_ROLE;
```

## 🧪 2. Aplicar Transformaciones SQL al dataset “sucio”

Supongamos que `DEV_BRONZE_DB.B_LEGACY_ERP.B_ORDERS_RAW_COMPLEX` ya está cargado. Vamos a transformarlo paso a paso.

### Paso 1 – Limpiar y convertir columnas

```sql
CREATE OR REPLACE TABLE DEV_SQL_LAB.S_SANDBOX.S_CLEANED_TRANSFORMED AS
SELECT
  ID_ORDER,
  TRY_TO_DATE(DTE_ORDER, 'YYYY-MM-DD') AS DTE_ORDER,
  ID_CUSTOMER,
  ID_PART,
  CASE 
    WHEN IS_NUMBER(QTY_ORDERED) AND TRY_TO_NUMBER(QTY_ORDERED) > 0 THEN TRY_TO_NUMBER(QTY_ORDERED)
    ELSE NULL 
  END AS QTY_ORDERED,
  TRY_TO_NUMBER(AMT_TOTAL) AS AMT_TOTAL,
  UPPER(REF_PAYMENT_METHOD) AS REF_PAYMENT_METHOD,
  TRY_TO_DATE(DTE_DELIVERY_EST, 'YYYY-MM-DD') AS DTE_DELIVERY_EST,
  DES_ORDER_NOTE
FROM DEV_BRONZE_DB.B_LEGACY_ERP.B_ORDERS_RAW_COMPLEX;
```

### Paso 2 – Validar datos nulos

```sql
-- ¿Cuántos registros tienen columnas clave nulas?
SELECT 
  COUNT(*) AS NUM_INVALID
FROM DEV_SQL_LAB.S_SANDBOX.S_CLEANED_TRANSFORMED
WHERE DTE_ORDER IS NULL 
   OR ID_CUSTOMER IS NULL
   OR QTY_ORDERED IS NULL
   OR AMT_TOTAL IS NULL;
```

### Paso 3 – Joins con tabla de referencia

```sql
-- Crear tabla de métodos de pago
CREATE OR REPLACE TABLE DEV_SQL_LAB.S_SANDBOX.S_PAYMENT_METHODS (
  REF_PAYMENT_METHOD STRING PRIMARY KEY,
  DES_PAYMENT_METHOD STRING
);

INSERT INTO DEV_SQL_LAB.S_SANDBOX.S_PAYMENT_METHODS VALUES
  ('CARD', 'Tarjeta'),
  ('CASH', 'Efectivo'),
  ('TRANSFER', 'Transferencia'),
  ('CRYPTO', 'Criptomoneda');

-- Join para enriquecer los pedidos
SELECT 
  C.ID_ORDER,
  C.AMT_TOTAL,
  C.REF_PAYMENT_METHOD,
  P.DES_PAYMENT_METHOD
FROM DEV_SQL_LAB.S_SANDBOX.S_CLEANED_TRANSFORMED C
LEFT JOIN DEV_SQL_LAB.S_SANDBOX.S_PAYMENT_METHODS P
  ON C.REF_PAYMENT_METHOD = P.REF_PAYMENT_METHOD;
```

## Entregables

Dentro de tu repositorio forkeado, asegúrate de incluir los siguientes archivos:

* `create.sql` – Script con la creación de tablas (`S_ORDERS_CLEAN`, `S_CLEANED_TRANSFORMED`, `S_PAYMENT_METHODS`)
* `insert.sql` – Script con sentencias `INSERT` para datos de prueba y tabla de métodos de pago
* `queries.sql` – Script con consultas SQL aplicadas (DML, DQL, joins, subconsultas, TCL, DCL)
* `lab-notes.md` – Documento explicativo que incluya:
  * Qué errores detectaste en el dataset original y cómo los corregiste
  * Qué comandos SQL utilizaste y para qué (ej: `ROLLBACK`, `GRANT`, subconsultas)
  * Cuáles fueron los resultados de validaciones o enriquecimientos (joins)
* *(Opcional)* Capturas de pantalla mostrando los resultados de las consultas

## ✅ Conclusión

Has aplicado los principales comandos de SQL para crear estructuras, insertar, transformar y consultar datos reales con errores. También se han incluido subconsultas, joins y control de transacciones.

Este ejercicio te prepara para realizar ETLs eficientes directamente en Snowflake, aprovechando la potencia de SQL.

- 📁 Dataset usado: `B_ORDERS_RAW_COMPLEX.csv`  
- 📂 Esquema de trabajo: `DEV_SQL_LAB.S_SANDBOX`