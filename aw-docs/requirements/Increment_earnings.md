# [D2] Lanzar una oferta especial para un producto

## Resumen

Aunque esta estrategia implica reducir el precio y, potencialmente, disminuir los márgenes de ganancia a corto plazo, también puede generar un incremento significativo en el volumen de ventas. Además de aumentar los ingresos inmediatos, las promociones pueden atraer nuevos clientes que, una vez familiarizados con la marca y sus productos, podrían continuar comprando a precios regulares.

## Preguntas de negocio

- Cuál es el número de ventas por producto?
- Cuál es el costo de producción de ese producto?
- Nivel de satisfacción de los clientes con el producto.
- Distribución de las ventas de un produducto por regiones.
- Ha estado en promoción anteriormente? Cuáles fueron los resultados?
- Forma de venta más efectiva para un determinado producto?
- Margen de ganancia del producto.

## Indicadores de desempeño (KPI)

| KPI                          | Definición                                                   | Fórmula                                       |
|-----------------------------|--------------------------------------------------------------|---------------------------------------------------------------------------|
| **Número de ventas**        | Total de unidades vendidas del producto.                    | `SUM(SalesOrderDetail.OrderQty)`                                         |
| **Costo de producción**     | Costo estándar del producto en el período                    | `ProductCostHistory.StandardCost`                                        |
| **Nivel de satisfacción**   | Promedio de calificaciones de clientes        |  Reviews proporcionadas por la API|
| **Ventas por región**       | Total de ventas por territorio geográfico                    | `SUM(SalesOrderDetail.LineTotal)` agrupado por `SalesTerritory.Name`     |
| **Historial de promociones**| Registro de promociones anteriores y su impacto              | `Sales.SpecialOfferProduct` + `Sales.SpecialOffer` + ventas asociadas    |
| **Forma de venta efectiva** | Canal con mayor conversión para el producto                  | Comparar `OnlineOrderFlag` en `SalesOrderHeader`                         |
| **Margen de ganancia**      | Diferencia entre precio de venta y costo estándar            | `UnitPrice − StandardCost` *(join con ProductCostHistory)*               |

## Parámetros

- Rango de fechas.

- Producto.

- Tipo de oferta.

- Canal de venta.

- Región geográfica.

- Segmento de cliente.

- Estado de la orden.

## Visualizaciones recomendadas

- Gráfico de barras número de ventas por producto  
- Gráfico de líneas para evolución del margen de ganancia por producto  
- Mapa de calor para distribución geográfica de ventas por territorio  
- Gráfico de barras para comparación de ventas antes y durante promociones anteriores  
- Gráfico de pastel para proporción de ventas por canal (online vs. físico)  
- Gráfico de dispersión para relación entre descuento aplicado y volumen de ventas.
