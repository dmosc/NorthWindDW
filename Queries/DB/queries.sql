-- Q0.1 Cuales años tienen órdenes
SELECT YEAR(OrderDate)
FROM Orders
GROUP BY YEAR(OrderDate);

-- Q0.2 Cuántos años existen con registros
SELECT COUNT(DISTINCT(YEAR(OrderDate)))
FROM Orders

-- Q1 Producto con más unidades vendidas en 1996
SELECT TOP 1 P.ProductName
FROM [Order Details] AS OD
JOIN Products AS P ON OD.ProductID = P.ProductID
JOIN Orders AS O ON OD.OrderID = O.OrderID
WHERE YEAR(O.OrderDate) = 1996
GROUP BY P.ProductName
ORDER BY SUM(OD.Quantity) DESC

-- Q2 Total de ventas en el 96
SELECT CAST(SUM((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)) as MONEY)
FROM [Order Details] AS OD
JOIN Orders AS O ON OD.OrderID = O.OrderID
WHERE YEAR(O.OrderDate) = 1996;

-- Q3 Total de ventas en el 97
SELECT CAST(SUM((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)) as MONEY)
FROM [Order Details] AS OD
JOIN Orders AS O ON OD.OrderID = O.OrderID
WHERE YEAR(O.OrderDate) = 1997;

-- Q4 Total de ventas histórico
SELECT CAST(SUM((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)) as MONEY)
FROM [Order Details] AS OD
JOIN Orders AS O ON OD.OrderID = O.OrderID;

-- Q5 Producto que generó más ganancias en 1997
SELECT TOP 1 P.ProductName
FROM [Order Details] AS OD
JOIN Products AS P ON OD.ProductID = P.ProductID
JOIN Orders AS O ON OD.OrderID = O.OrderID
WHERE YEAR(O.OrderDate) = 1997
GROUP BY P.ProductName
ORDER BY SUM((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)) DESC;

-- Q6 Region que generó más ventas en 1997
	-- función que regresa la región con mayor ventas en 1997
	CREATE FUNCTION region_ventas_max_1997()
		RETURNS VARCHAR 
		AS
		BEGIN
			DECLARE @VARCHAR VARCHAR;
			SELECT TOP 1 @VARCHAR = O.ShipRegion
			FROM 
				Orders AS O
				JOIN [Order Details] AS OD ON OD.OrderId = O.OrderId
			WHERE YEAR(O.OrderDate) = 1997
			GROUP BY O.ShipRegion
			ORDER BY SUM((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)) DESC;
			RETURN @VARCHAR
		END
	GO
	-- llamado a la función
	select dbo.region_ventas_max_1997()

-- Q7 Estado o pais que mas genero de la region de ventas maxima
	-- definición de función de comparación de 2 strings, STRCMP
	CREATE FUNCTION STRCMP(@str1 varchar, @str2 varchar)
		RETURNS int
		AS
		BEGIN
			DECLARE @ans int;
			IF @str1 = @str2 BEGIN SET @ans = 0 END
			ELSE BEGIN SET @ans = 1 END
			RETURN @ans
		END
	GO
	-- query
	SELECT TOP 1
		CASE WHEN dbo.STRCMP(O.ShipCountry, 'USA') = 0
			THEN O.ShipRegion
			ELSE O.ShipCountry
		END AS topStateOrRegion
	FROM Orders as O
	JOIN [Order Details] AS OD ON OD.OrderId = O.OrderId
	WHERE O.ShipRegion = dbo.region_ventas_max()
		AND YEAR(O.OrderDate) = 1997
	GROUP BY
		CASE WHEN dbo.STRCMP(O.ShipCountry, 'USA') = 0
			THEN O.ShipRegion
			ELSE O.ShipCountry
		END
	ORDER BY SUM((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)) DESC;

-- Q8 Total de ventas org por region, estado y/o pais
SELECT O.ShipCountry, O.ShipRegion, SUM((OD.UnitPrice * OD.Quantity) * (1 - OD.Discount)) AS Ventas
FROM [Order Details] AS OD
JOIN Orders AS O ON O.OrderId = OD.OrderId
GROUP BY O.ShipRegion, O.ShipCountry