# [D9] Incrementar el control de calidad en la línea de ensamblaje

## Resumen

Un mayor control de calidad durante la producción permitiría detectar defectos, ineficiencias y problemas potenciales en etapas más tempranas, mejorando la calidad de los productos finales y reduciendo costos asociados con reprocesos, devoluciones y reclamos de garantía.

## Preguntas de negocio

- Cuál es la tasa de productos rechazados en inspecciones de calidad por producto?

- Qué productos tienen mayor frecuencia de reprocesos o de ser desechados?

- Cuál es el costo estimado de desecho por producto y por período?

- Qué porcentaje de órdenes de trabajo terminan con scrap o defectos? (Production.WorkOrder, Production.WorkOrderRouting)

- Devoluciones por producto

- Cuál es el ahorro estimado si se reduce el scrap en un determinado porciento?

## Indicadores de desempeño (KPI)

| KPI                        | Definición                                               | Fórmula (basada en AdventureWorks)                                      |
|---------------------------|----------------------------------------------------------|--------------------------------------------------------------------------|
| **Tasa de desechos**         | % de productos defectuosos en producción                 | `(WorkOrder.ScrappedQty / WorkOrder.OrderQty) × 100`                    |
| **Costo de desechar**        | Costo total de productos descartados                     | `∑(ScrappedQty × StandardCost)`         |
| **Índice de devoluciones**| % de productos devueltos por clientes                    | `(CantidadDevuelta / CantidadVendida) × 100`       |
| **Costo por devolución**  | Costo promedio por devolución                            | `∑(MontoDevoluciones / TotalDevoluciones)` |                                  |

## Parámetros

- Rango de fechas.

- Producto.

- Ubicación de producción

- Motivo de desecho.

## Visualizaciones recomendadas

- Gráfico de líneas para evolución mensual de la tasa de desecho por ubicación de producción.
- Gráfico de barras para productos con mayor costo de desecho acumulado.
- Gráfico de barras para productos con mayor número de devoluciones.
- Mapa de calor para frecuencia de motivos de scrap por producto
- Gráfico de dispersión para relación entre scrap y devoluciones por producto.
