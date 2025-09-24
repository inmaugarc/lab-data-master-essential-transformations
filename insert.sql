Script con sentencias INSERT para datos de prueba y tabla de métodos de pago

-- Insertar registros en tabla S_ORDERS_CLEAN 
INSERT INTO S_ORDERS_CLEAN (
  ID_ORDER, DTE_ORDER, ID_CUSTOMER, ID_PART, QTY_ORDERED, AMT_TOTAL
) VALUES
('ORD9999', '2025-06-25', 'C9999', 'P9999', 3, 249.99);

-- Insertar registros en tabla S_PAYMENT_METHODS VALUES
INSERT INTO S_PAYMENT_METHODS VALUES
  ('CARD', 'Tarjeta'),
  ('CASH', 'Efectivo'),
  ('TRANSFER', 'Transferencia'),
  ('CRYPTO', 'Criptomoneda');
