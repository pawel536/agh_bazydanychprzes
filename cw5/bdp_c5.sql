--CREATE DATABASE cw5;
CREATE EXTENSION postgis;

-- 1 --
CREATE TABLE obiekty(id_ int NOT NULL PRIMARY KEY, 
					 name_ varchar(10), 
					 geom geometry);

INSERT INTO obiekty VALUES(1, 'obiekt1', ST_COLLECT(ARRAY['LINESTRING(0 1, 1 1)', 'CIRCULARSTRING(1 1, 2 0, 3 1)',
			'CIRCULARSTRING(3 1, 4 2, 5 1)', 'LINESTRING(5 1, 6 1)' ]));
			
INSERT INTO obiekty VALUES(2, 'obiekt2', ST_COLLECT(ARRAY['LINESTRING(10 6, 14 6)', 'CIRCULARSTRING(14 6, 16 4, 14 2)',
			'CIRCULARSTRING(14 2, 12 0, 10 2)', 'LINESTRING(10 2, 10 6)', 'CIRCULARSTRING(11 2, 13 2, 11 2)' ]));
			
INSERT INTO obiekty VALUES(3, 'obiekt3', 'POLYGON((7 15, 10 17, 12 13, 7 15))');

INSERT INTO obiekty VALUES(4, 'obiekt4', 'LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)');

INSERT INTO obiekty VALUES(5, 'obiekt5', ST_Collect('POINT(30 30 59)', 'POINT(38 32 234)'));

INSERT INTO obiekty VALUES(6, 'obiekt6', ST_Collect('LINESTRING(1 1, 3 2)', 'POINT(4 2)'));

SELECT name_, ST_AsText(geom) AS all_ FROM obiekty;

-- 2 --
SELECT ST_AREA(ST_BUFFER(
	ST_ShortestLine( (SELECT geom FROM obiekty WHERE name_ = 'obiekt3'), (SELECT geom FROM obiekty WHERE name_ = 'obiekt4') ), 5));

-- sprawdzenie --
SELECT 
	ST_AsText(ST_ShortestLine( (SELECT geom FROM obiekty WHERE name_ = 'obiekt3'), (SELECT geom FROM obiekty WHERE name_ = 'obiekt4')));

-- 3 --
UPDATE obiekty SET geom = ST_MakePolygon(ST_AddPoint(geom, 'POINT(20 20)')) WHERE name_ = 'obiekt4';
-- Trzeba dodac punkt aby domknąć linestringa --

-- 4 --
INSERT INTO obiekty VALUES(7, 'obiekt7', ST_Collect((SELECT geom FROM obiekty WHERE name_ = 'obiekt3'), 
												   (SELECT geom FROM obiekty WHERE name_ = 'obiekt4') ));

-- 5 --
SELECT SUM(ST_AREA(ST_BUFFER(geom, 5))) FROM obiekty WHERE ST_HasArc(geom) = False;

-- obiekt2 ze zbioru linii na figurę ???
--INSERT INTO obiekty VALUES(102, 'obiekt102', ST_ToMultiSurface( ST_COLLECT(ARRAY['LINESTRING(10 6, 14 6)', 'CIRCULARSTRING(14 6, 16 4, 14 2)',
--'CIRCULARSTRING(14 2, 12 0, 10 2)', 'LINESTRING(10 2, 10 6)']), ST_COLLECT(ARRAY['CIRCULARSTRING(11 2, 13 2, 11 2)']) )  );

DROP  TABLE obiekty;



