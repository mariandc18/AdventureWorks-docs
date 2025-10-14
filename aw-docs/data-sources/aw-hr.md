# AdventureWorks HR Files

## Resumen

Los archivos referentes a los recursos humanos de la empresa, muestran las asignaciones de los empleados en la misma. Se detallan los departamento que tiene la empresa, los empleados que pertenecen a cada uno, así como los turnos y salarios de los mismos.

## Modelo conceptual

![Modelo conceptual de HR](./imgs/HR.drawio.png)

## Modelo lógico

## Catálogo de datos

### Department

Indica todos los departamentos que existen en la empresa, y la función que realiza cada uno.

| Campo         | Tipo de dato | Restricciones           | Descripción                                  |
|--------------|--------------|-------------------------|----------------------------------------------------------|
| DepartmentId | SMALLINT     | PK                      | Identificador único del departamento                    |
| Name         | NVARCHAR(50) | NOT NULL, UNIQUE        | Nombre del departamento (ej. "Production")              |
| GroupName    | NVARCHAR(50) | NOT NULL                | Categoría funcional               |
| ModifiedDate | DATETIME     | NOT NULL                | Fecha de última modificación                |

### EmployeeDepartmentHistory

Contiene el historial de cada empleado en un determinado departamento.

| Campo             | Tipo de dato | Restricciones                     | Descripción                                |
|------------------|--------------|-----------------------------------|----------------------------------------------------------|
| BusinessEntityId | INT          | FK a `Person.BusinessEntityId`   | Id del empleado                    |
| DepartmentId     | SMALLINT     | FK a `Department.DepartmentId`   | Departamento al que pertenece el empleado               |
| ShiftId          | TINYINT      | FK a `Shift.ShiftId`             | Turno en el que trabaja el empleado                     |
| StartDate        | DATE         | NOT NULL                         | Fecha de inicio de la asignación                        |
| EndDate          | DATE         |        | Fecha de fin de la asignación                           |
| ModifiedDate     | DATETIME     | NOT NULL                         | Fecha de última modificación

### EmployeePayHistory

Contiene el historial de pago del empleado.

| Campo             | Tipo de dato | Restricciones                               | Descripción                                |
|------------------|--------------|---------------------------------------------|----------------------------------------------------------|
| BusinessEntityId | INT          | FK a `Person.BusinessEntityId`             | Identificador del empleado                              |
| RateChangeDate   | DATE         | PK compuesto con `BusinessEntityId`        | Fecha en que se aplica el nuevo salario                 |
| Rate             | MONEY        | NOT NULL                                   | Monto del salario                  |
| PayFrequency     | TINYINT      | NOT NULL (0 = mensual, 1 = quincenal)       | Frecuencia de pago                                      |
| ModifiedDate     | DATETIME     | NOT NULL                                   | Fecha de última modificación |

### Shift

Representa los turnos de trabajo.

| Campo         | Tipo de dato | Restricciones           | Descripción                                 |
|--------------|--------------|-------------------------|----------------------------------------------------------|
| ShiftId      | TINYINT      | PK                      | Identificador único del turno                           |
| Name         | NVARCHAR(50) | NOT NULL       | Nombre del turno                   |
| StartTime    | TIME         | NOT NULL                | Hora de inicio del turno                                |
| EndTime      | TIME         | NOT NULL                | Hora de fin del turno                                   |
| ModifiedDate | DATETIME     | NOT NULL                | Fecha de última modificación |
