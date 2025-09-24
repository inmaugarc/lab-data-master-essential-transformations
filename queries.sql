-- Script con consultas SQL aplicadas (DML, DQL, joins, subconsultas, TCL, DCL)

-------------- DML ---------------

-- Insertar registros
INSERT INTO S_ORDERS_CLEAN (
  ID_ORDER, DTE_ORDER, ID_CUSTOMER, ID_PART, QTY_ORDERED, AMT_TOTAL
) VALUES
('ORD9999', '2025-06-25', 'C9999', 'P9999', 3, 249.99);

-- Actualizar datos
UPDATE S_ORDERS_CLEAN
SET QTY_ORDERED = 5
WHERE ID_ORDER = 'ORD9999';

-- Eliminar datos
DELETE FROM S_ORDERS_CLEAN
WHERE ID_ORDER = 'ORD9999';

-------------- DQL ---------------
-- Consulta simple
SELECT ID_ORDER, QTY_ORDERED, AMT_TOTAL
FROM S_ORDERS_CLEAN
WHERE QTY_ORDERED > 5
ORDER BY AMT_TOTAL DESC;

-- Subconsulta: pedidos con importe mayor al promedio
SELECT *
FROM S_ORDERS_CLEAN
WHERE AMT_TOTAL > (
  SELECT AVG(AMT_TOTAL) 
  FROM S_ORDERS_CLEAN
);


------------- JOIN ---------------
-- Join para enriquecer los pedidos
SELECT 
  C.ID_ORDER,
  C.AMT_TOTAL,
  C.REF_PAYMENT_METHOD,
  P.DES_PAYMENT_METHOD
FROM S_CLEANED_TRANSFORMED C
LEFT JOIN S_PAYMENT_METHODS P
  ON C.REF_PAYMENT_METHOD = P.REF_PAYMENT_METHOD;


-------------- TCL---------------
-- Empezar una transacción (solo útil si AUTO-COMMIT está desactivado)
BEGIN;

-- Modificación temporal
UPDATE S_ORDERS_CLEAN
SET AMT_TOTAL = AMT_TOTAL * 0.9
WHERE REF_PAYMENT_METHOD = 'CASH';

-- Revertir la transacción
ROLLBACK;

-- Rehacer la operación con confirmación
UPDATE S_ORDERS_CLEAN
SET AMT_TOTAL = AMT_TOTAL * 0.9
WHERE REF_PAYMENT_METHOD = 'CASH';

COMMIT;


----------------DCL-------------------
-- Dar privilegios de lectura -- no funciona en SEAT
GRANT SELECT ON S_ORDERS_CLEAN TO ROLE ANALYST_ROLE;

-- Revocar privilegios
REVOKE SELECT ON S_ORDERS_CLEAN FROM ROLE ANALYST_ROLE;