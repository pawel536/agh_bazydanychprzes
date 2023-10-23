-- 2 --
-- CREATE DATABASE cw2;

-- 3 --
CREATE EXTENSION postgis;

-- 4 --
CREATE TABLE buildings (id int NOT NULL PRIMARY KEY, 
					   name varchar(30), 
					   geometry geometry);
					   
CREATE TABLE roads (id int NOT NULL PRIMARY KEY, 
					   name varchar(30), 
					   geometry geometry);
					   
CREATE TABLE poi (id int NOT NULL PRIMARY KEY, 
					   name varchar(30), 
					   geometry geometry);

-- 5 --
INSERT INTO buildings VALUES
(1, 'BuildingA', 'POLYGON((8 1.5, 8 4, 10.5 4, 10.5 1.5, 8 1.5))'),
(2, 'BuildingB', 'POLYGON((4 5, 4 7, 6 7, 6 5, 4 5))'),
(3, 'BuildingC', 'POLYGON((3 6, 3 8, 5 8, 5 6, 3 6))'),
(4, 'BuildingD', 'POLYGON((9 8, 9 9, 10 9, 10 8, 9 8))'),
(5, 'BuildingF', 'POLYGON((1 1, 1 2, 2 2, 2 1, 1 1))');
	
INSERT INTO poi VALUES
(6, 'G', 'POINT(1 3.5)'),
(7, 'H', 'POINT(5.5 1.5)'),
(8, 'I', 'POINT(9.5 6)'),
(9, 'J', 'POINT(6.5 6)'),
(10, 'K', 'POINT(6 9.5)');
	
INSERT INTO roads VALUES
(11, 'RoadX', 'LINESTRING(0 4.5, 12 4.5)'),
(12, 'RoadY', 'LINESTRING(7.5 0, 7.5 10.5)');
	
-- 6a --
SELECT SUM(ST_LENGTH(geometry)) FROM roads;

-- 6b --
SELECT ST_AsText(geometry), ST_AREA(geometry), ST_PERIMETER(geometry) 
FROM buildings 
WHERE name = 'BuildingA';

-- 6c --
SELECT name, ST_AREA(geometry) 
FROM buildings 
ORDER BY name;

-- 6d --
SELECT name, ST_PERIMETER(geometry) 
FROM buildings 
ORDER BY ST_AREA(geometry) DESC LIMIT 2;

-- 6e --
SELECT ST_DISTANCE(buildings.geometry, poi.geometry) 
FROM buildings CROSS JOIN poi 
WHERE buildings.name = 'BuildingC' 
AND poi.name = 'K';

-- 6f -- SUBQUERY
SELECT ST_AREA( ST_Difference(geometry, ST_BUFFER(
	(SELECT geometry FROM buildings WHERE buildings.name = 'BuildingB'), 0.5) ) )
FROM buildings 
WHERE buildings.name = 'BuildingC';
-- KOMENTARZ: DROBNA NIEDOKŁADNOŚĆ BO ST_BUFFER ZWRACA POLIGON

-- 6g --
SELECT buildings.id, buildings.name, ST_AsText(buildings.geometry) 
FROM buildings CROSS JOIN roads 
WHERE roads.name = 'RoadX' 
AND ST_Y(ST_CENTROID(buildings.geometry)) > ST_Y(ST_CENTROID(roads.geometry));

-- 6h --
SELECT ST_AREA(ST_SYMDIFFERENCE(geometry, 'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')) 
FROM buildings 
WHERE name = 'BuildingC';


DROP TABLE poi;
DROP TABLE buildings;
DROP TABLE roads;