CREATE EXTENSION postgis;

-- 1 -- OK
--SELECT build19.gid FROM build18 INNER JOIN build19 ON build18.geom = build19.geom;

CREATE TEMP TABLE new_build AS 
SELECT * FROM build19 WHERE gid NOT IN (SELECT build19.gid FROM build18 
										INNER JOIN build19 ON build18.geom = build19.geom);

SELECT * FROM new_build;

--23 nowe/zmienione budynki

-- 2 --
-- TO DO
CREATE TEMP TABLE new_poi AS 
SELECT * FROM poi19 WHERE gid NOT IN (SELECT poi19.gid FROM poi18 
										INNER JOIN poi19 ON poi18.geom = poi19.geom);
										
SELECT * FROM new_poi;
--skomplikwane

-- 3 -- OK
--SELECT * FROM streets19;
--SELECT * FROM public.spatial_ref_sys WHERE srid=3068; 

CREATE TEMP TABLE streets_reprojected AS 
SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, 
to_speed_l, dir_travel, ST_TRANSFORM(geom, 3068) as geom FROM streets19;

SELECT * FROM streets_reprojected;

DROP TABLE streets_reprojected;

-- 4 -- OK
CREATE TABLE input_points(id int NOT NULL PRIMARY KEY, 
						  geometry geometry);
	
INSERT INTO input_points VALUES
(1, 'POINT(8.36093 49.03174)'),
(2, 'POINT(8.39876 49.00644)');

-- 5 -- OK
UPDATE input_points SET geometry = ST_TRANSFORM(ST_SetSRID(geometry, 4326), 3068);

-- 6 -- OK
SELECT * FROM nodes19;

ALTER TABLE nodes19
 	ALTER COLUMN geom TYPE geometry(POINT, 3068) USING ST_TRANSFORM(geom, 3068);

-- Jednostką w EPSG 3068 jest metr zatem dist < 200, nie 0.002
-- Punkt musi być skrzyżowaniem, więc intersect = 'Y'

SELECT *, ST_DISTANCE(geom, ST_MAKELINE(
											(SELECT geometry FROM input_points WHERE id = 1), 
											(SELECT geometry FROM input_points WHERE id = 2)
										)
						) as dist
FROM nodes19 WHERE nodes19.intersect = 'Y' AND ST_DISTANCE(geom, ST_MAKELINE(
											(SELECT geometry FROM input_points WHERE id = 1), 
											(SELECT geometry FROM input_points WHERE id = 2)
										) ) < 200;

-- 7 --
-- TO DO
SELECT ST_GeometryType(geom) FROM lua19;

ALTER TABLE poi19
 	ALTER COLUMN geom TYPE geometry(POINT, 3068) USING ST_TRANSFORM(geom, 3068);
	
ALTER TABLE lua19
 	ALTER COLUMN geom TYPE geometry(MULTIPOLYGON, 3068) USING ST_TRANSFORM(geom, 3068);
	
SELECT * FROM poi19 WHERE poi19.type='Sporting Goods Store';
SELECT * FROM lua19 WHERE lua19.type LIKE '%Park%' AND lua19.type NOT LIKE '%Parking%';

-- 8 --
-- TO DO



-- K --
DROP TABLE build18;
DROP TABLE build19;
DROP TABLE streets19;

