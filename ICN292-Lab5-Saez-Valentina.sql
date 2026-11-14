-- ICN-292 Lab 5 - Andes Bike
DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike;
USE andesbike;

-- =====================================================
-- Entregable 1: creación de las cuatro tablas
-- =====================================================
CREATE TABLE tiendas (
    id_tienda INT NOT NULL AUTO_INCREMENT,
    nombre    VARCHAR(60) NOT NULL,
    comuna    VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_tienda)
);

CREATE TABLE vendedores (
    id_vendedor   INT NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(80) NOT NULL,
    id_tienda     INT NULL,
    fecha_ingreso DATE NOT NULL,
    PRIMARY KEY (id_vendedor),
    FOREIGN KEY (id_tienda) REFERENCES tiendas (id_tienda)
);

CREATE TABLE bicicletas (
    id_bicicleta INT NOT NULL AUTO_INCREMENT,
    modelo       VARCHAR(60) NOT NULL,
    categoria    ENUM('Eléctrica','Infantil','Montaña','Ruta','Urbana') NOT NULL,
    precio       DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_bicicleta)
);

CREATE TABLE ventas (
    id_venta     INT NOT NULL AUTO_INCREMENT,
    id_vendedor  INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha        DATE NOT NULL,
    unidades     INT NOT NULL,
    PRIMARY KEY (id_venta),
    FOREIGN KEY (id_vendedor)  REFERENCES vendedores (id_vendedor),
    FOREIGN KEY (id_bicicleta) REFERENCES bicicletas (id_bicicleta)
);

-- =====================================================
-- Carga oficial
-- =====================================================
INSERT INTO tiendas (nombre, comuna) VALUES
('Andes Providencia', 'Providencia'),
('Andes Maipú',       'Maipú'),
('Andes Concepción',  'Concepción'),
('Andes La Serena',   'La Serena');

INSERT INTO vendedores (nombre, id_tienda, fecha_ingreso) VALUES
('Camila Ortiz',    1,    '2024-06-20'),
('Diego Fuentes',   1,    '2024-01-15'),
('Javiera Soto',    2,    '2023-07-24'),
('Matías Herrera',  2,    '2024-01-15'),
('Paula Riquelme',  3,    '2022-11-02'),
('Ignacio Vera',    3,    '2024-08-19'),
('Fernanda Lillo',  1,    '2025-02-03'),
('Rubén Castro',    NULL, '2025-06-10');

INSERT INTO bicicletas (modelo, categoria, precio) VALUES
('Cordillera 29', 'Montaña',   549990.00),
('Ruta Austral',  'Ruta',      899990.00),
('Urbana Pro',    'Urbana',    329990.00),
('Pequeño Andes', 'Infantil',  149990.00),
('Volt City',     'Eléctrica', 1249990.00),
('Trail Master',  'Montaña',   749990.00),
('Urbana Lite',   'Urbana',    229990.00),
('Sprint R7',     'Ruta',      1099990.00);

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
(1, 1, '2025-03-04', 2),
(1, 3, '2025-03-18', 1),
(1, 5, '2025-04-02', 1),
(2, 2, '2025-03-04', 1),
(2, 1, '2025-04-11', 3),
(2, 7, '2025-05-06', 2),
(3, 4, '2025-03-21', 4),
(3, 3, '2025-04-15', 2),
(3, 6, '2025-05-20', 1),
(4, 1, '2025-03-27', 1),
(4, 5, '2025-05-09', 2),
(5, 2, '2025-04-08', 1),
(5, 6, '2025-04-23', 2),
(5, 4, '2025-06-02', 5),
(6, 3, '2025-05-13', 3),
(6, 7, '2025-06-17', 1),
(6, 1, '2025-06-24', 2),
(1, 6, '2025-06-30', 1);

-- =====================================================
-- Entregable 2: consultas
-- =====================================================

-- Consulta 1: todos los vendedores con su cantidad de ventas (0 si no tienen)
SELECT v.nombre, COUNT(ve.id_venta) AS cantidad_ventas
FROM vendedores v
LEFT JOIN ventas ve ON ve.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nombre
ORDER BY cantidad_ventas DESC, v.nombre;

-- Consulta 2: por tienda, ventas y unidades (incluye tiendas sin vendedores)
SELECT t.nombre,
       COUNT(ve.id_venta)             AS ventas,
       COALESCE(SUM(ve.unidades), 0)  AS unidades
FROM tiendas t
LEFT JOIN vendedores v ON v.id_tienda = t.id_tienda
LEFT JOIN ventas ve    ON ve.id_vendedor = v.id_vendedor
GROUP BY t.id_tienda, t.nombre
ORDER BY unidades DESC;

-- Consulta 3: tiendas sin ningún vendedor
SELECT t.id_tienda, t.nombre, t.comuna
FROM tiendas t
LEFT JOIN vendedores v ON v.id_tienda = t.id_tienda
WHERE v.id_vendedor IS NULL;

-- Consulta 4: modelos que no se vendieron en junio de 2025
-- Explicación: la condición del mes va en el ON del LEFT JOIN; si la hubiera puesto
-- en el WHERE, las filas sin venta (fecha NULL) se descartarían y no devolvería ningún modelo.
SELECT b.id_bicicleta, b.modelo
FROM bicicletas b
LEFT JOIN ventas ve ON ve.id_bicicleta = b.id_bicicleta
                   AND ve.fecha >= '2025-06-01' AND ve.fecha < '2025-07-01'
WHERE ve.id_venta IS NULL;

-- Consulta 5: vendedores sin ventas, con el nombre de su tienda (Rubén no tiene tienda)
SELECT v.nombre AS vendedor, t.nombre AS tienda
FROM vendedores v
LEFT JOIN tiendas t ON t.id_tienda = v.id_tienda
LEFT JOIN ventas ve ON ve.id_vendedor = v.id_vendedor
WHERE ve.id_venta IS NULL;

-- Consulta 6: pares de vendedores de la misma tienda, primero el que ingresó antes
-- (en empate de fecha se desempata por id para que cada par salga una sola vez)
SELECT a.nombre AS vendedor_1, a.fecha_ingreso AS ingreso_1,
       b.nombre AS vendedor_2, b.fecha_ingreso AS ingreso_2,
       t.nombre AS tienda
FROM vendedores a
JOIN vendedores b ON b.id_tienda = a.id_tienda
                 AND (a.fecha_ingreso < b.fecha_ingreso
                      OR (a.fecha_ingreso = b.fecha_ingreso AND a.id_vendedor < b.id_vendedor))
JOIN tiendas t ON t.id_tienda = a.id_tienda
ORDER BY t.nombre, a.fecha_ingreso;

-- Consulta 7: monto vendido por tienda en Montaña y Ruta, solo las que superan 2.000.000
SELECT t.nombre, SUM(ve.unidades * b.precio) AS monto_total
FROM tiendas t
JOIN vendedores v  ON v.id_tienda = t.id_tienda
JOIN ventas ve     ON ve.id_vendedor = v.id_vendedor
JOIN bicicletas b  ON b.id_bicicleta = ve.id_bicicleta
WHERE b.categoria IN ('Montaña', 'Ruta')
GROUP BY t.id_tienda, t.nombre
HAVING SUM(ve.unidades * b.precio) > 2000000
ORDER BY monto_total DESC;

-- Consulta 8: bicicletas con precio sobre el promedio del catálogo
-- Informe: el promedio es 657.490; se obtiene con la subconsulta (SELECT AVG(precio) FROM bicicletas).
SELECT modelo, precio
FROM bicicletas
WHERE precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY precio DESC;

-- Consulta 9: vendedores cuyo promedio de unidades por venta supera el promedio de todas las ventas
SELECT v.nombre, AVG(ve.unidades) AS promedio_unidades
FROM vendedores v
JOIN ventas ve ON ve.id_vendedor = v.id_vendedor
GROUP BY v.id_vendedor, v.nombre
HAVING AVG(ve.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY promedio_unidades DESC, v.nombre;

-- Consulta 10: todos los vendedores con su monto total (incluye los que no vendieron)
-- Explicación: los vendedores sin ventas muestran NULL y no 0 porque SUM sobre ninguna fila da NULL;
-- habría que agregar COALESCE(SUM(...), 0) para que muestren cero.
SELECT v.nombre, SUM(ve.unidades * b.precio) AS monto_total
FROM vendedores v
LEFT JOIN ventas ve    ON ve.id_vendedor = v.id_vendedor
LEFT JOIN bicicletas b ON b.id_bicicleta = ve.id_bicicleta
GROUP BY v.id_vendedor, v.nombre
ORDER BY monto_total DESC;
