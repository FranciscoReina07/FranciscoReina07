

USE Clear;


---------Rename table 
EXEC sp_rename 'empresa', 'Company'

-------------stored procedure from table 
CREATE PROCEDURE comp
as 
SELECT * FROM Company;
------------------------Select * from company
EXEC comp
------------------------Rename Columns 
EXEC sp_rename 'Company.Id?empleado', 'Id_employee', 'COLUMN'
EXEC sp_rename 'Company.género', 'Gender', 'COLUMN'
EXEC sp_rename 'Company.Apellido', 'Last_Name', 'COLUMN'
EXEC sp_rename 'Company.star_date', 'Start_Date', 'COLUMN'
EXEC sp_rename 'Company.type', 'Work_Arrangement', 'COLUMN'

--------------------Change Value 
ALTER TABLE Company ALTER COLUMN Id_employee varchar(20) null
ALTER TABLE Company ALTER COLUMN Work_Arrangement text

-----------------Change names within the column 
UPDATE Company SET Work_Arrangement = REPLACE(CAST(Work_Arrangement AS VARCHAR(MAX)), '1', 'Remote') 
UPDATE Company SET Work_Arrangement = REPLACE(CAST(Work_Arrangement AS VARCHAR(MAX)), '0', 'Hybrid')
UPDATE Company sET Gender = REPLACE (Gender,'Hombre','Male')
UPDATE Company sET Gender = REPLACE (Gender,'Mujer','Female')


------------Check characteristics from table 
sp_help company 

--------------------Look for dublicates 
SELECT  Id_employee, COUNT(*) duplicates FROM Company
GROUP BY Id_employee 
HAVING COUNT(*)>1;

-------------------Detect duplicates whit a subquery 
SELECT COUNT(*) Amount_duplicates 
FROM (
SELECT Id_employee, COUNT(*) Amount_duplicates
FROM Company
GROUP BY Id_employee
HAVING COUNT(*)>1
) AS subquery_1;

-----------------Detect duplicates that don't delete 
SELECT * FROM (
SELECT *, ROW_NUMBER() OVER (PARTITION BY Id_employee ORDER BY Id_employee) C
FROM Company
WHERE (Id_employee) in (
SELECT id_employee FROM Company
GROUP BY id_employee
HAVING COUNT(*)>1)
)T1
WHERE c=2 

-----------Save rows no duplicates within table temporal
SELECT * Into Temporal_1 FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY Id_employee ORDER BY Id_employee DESC) C
FROM Company
WHERE (Id_employee) in (
SELECT id_employee FROM Company
GROUP BY (Id_employee)
HAVING COUNT(*)>1)
)T1
WHERE C=2

--------------Delete duplicates from table original
DELETE FROM Company
WHERE Id_employee in (
SELECT Id_employee FROM Company
GROUP BY Id_employee
HAVING COUNT(*)>1
)

-----------Insert rows to table original and Delete table temporal_1
INSERT INTO Company SELECT * FROM Temporal_1
GO 
DROP TABLE Temporal_1

------------------------Delete Columns space
SELECT RTRIM(LTRIM(name)) Name FROM Company
SELECT RTRIM(LTRIM(Last_name)) Last_Name FROM Company
SELECT RTRIM(LTRIM(Salary)) Salary FROM Company

--------------------modifying salary

UPDATE Company SET salary = REPLACE (salary,'$','')
UPDATE Company SET salary = REPLACE (salary,'"','')
ALTER TABLE Company ALTER COLUMN Salary int


-------------------modifying birth_date and update 

SELECT birth_date
FROM Company
WHERE CHARINDEX('/', birth_date) < 3; -- Busca si hay una barra "/" antes del tercer carácter


---fechas en formato "MM/DD/YYYY" y que el mes y el día pueden tener uno o dos dígitos,
---puedes usar la función STUFF()
---para insertar el cero al inicio del mes y del día si es necesario


---Esta consulta primero verifica si el mes tiene un solo dígito 
---(es decir, si el primer "/" está en la posición 2). Si es así,
---inserta un cero al inicio de la cadena usando la función STUFF().
---La condición CHARINDEX('/', tu_columna_fecha) = 2 
---asegura que la actualización solo se aplique a las 
---fechas donde el mes tiene un solo 
---dígito y el día puede tener uno o dos dígitos.


SELECT 
    birth_date AS fecha_original,
    CASE
        WHEN CHARINDEX('/', birth_date) = 2 THEN
            STUFF(birth_date, 1, 0, '0')
        ELSE
            birth_date
    END AS fecha_actualizada
FROM 
    Company
WHERE 
    CHARINDEX('/', birth_date) = 2; 



UPDATE Company
SET birth_date = 
    CASE
        WHEN CHARINDEX('/', birth_date) = 2 THEN -- Si el mes tiene un solo dígito
            STUFF(birth_date, 1, 0, '0') -- Inserta un cero al inicio
        ELSE
            birth_date
    END
WHERE CHARINDEX('/', birth_date) = 2; -- Solo actualiza si la fecha tiene formato "M/DD/YYYY"

ALTER TABLE Company ALTER COLUMN birth_date DATE

-----------modifying finish_date and update 

SELECT finish_date
FROM Company
WHERE CHARINDEX('/', finish_date) < 3;

UPDATE Company
SET finish_date = 
    CASE
        WHEN CHARINDEX('/', finish_date) = 2 THEN 
		STUFF(finish_date, 1, 0, '0')
        ELSE
            finish_date
    END
WHERE CHARINDEX('/', finish_date) = 2;

ALTER TABLE Company ALTER COLUMN finish_date DATE

-------------prueba para modificar fechas con horas y minutos 

exec comp
sp_help company


ALTER TABLE COMPANY ADD backup_date text
UPDATE Company SET backup_date = promotion_date
ALTER TABLE COMPANY drop column backup_date;

SELECT backup_date,str_to_date(backup_date,'%Y-%n-%d-%H:%i:%s') fecha  FROM Company

DECLARE @fechaCompleta VARCHAR(50) = '2027-05-11 07:35:50 UTC';

SELECT 
    YEAR(CONVERT(datetime, backup_date)) AS Anio,
    MONTH(CONVERT(datetime, backup_date)) AS Mes,
    DAY(CONVERT(datetime, backup_date)) AS Dia,
    DATEPART(HOUR, CONVERT(datetime, backup_date)) AS Hora,
    DATEPART(MINUTE, CONVERT(datetime, backup_date)) AS Minuto,
    DATEPART(SECOND, CONVERT(datetime, backup_date)) AS Segundo
FROM company 

