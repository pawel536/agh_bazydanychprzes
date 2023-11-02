CREATE EXTENSION postgis;

-- 1 --
--SELECT build19.gid FROM build18 INNER JOIN build19 ON build18.geom = build19.geom;

CREATE TEMP TABLE new_build AS 
SELECT * FROM build19 WHERE gid NOT IN (SELECT build19.gid FROM build18 
										INNER JOIN build19 ON build18.geom = build19.geom);

SELECT * FROM new_build;

--23 nowe/zmienione budynki

-- 2 --
CREATE TEMP TABLE new_poi AS 
SELECT * FROM poi19 WHERE gid NOT IN (SELECT poi19.gid FROM poi18 
										INNER JOIN poi19 ON poi18.geom = poi19.geom);
-- 3622 nowe poi

CREATE TEMP TABLE new_temp AS
SELECT new_poi.gid, new_poi.type AS tp, new_build.gid AS bgid FROM new_poi 
LEFT JOIN new_build ON ST_CONTAINS(ST_BUFFER(new_build.geom, 0.005), new_poi.geom);

SELECT tp, COUNT(DISTINCT gid) FROM 
(SELECT gid, tp FROM new_temp WHERE bgid IS NOT NULL GROUP BY gid, tp ORDER BY gid) 
GROUP BY tp;

-- 3 --
--SELECT * FROM streets19;
--SELECT * FROM public.spatial_ref_sys WHERE srid=3068; 

CREATE TEMP TABLE streets_reprojected AS 
SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, 
to_speed_l, dir_travel, ST_TRANSFORM(geom, 3068) as geom FROM streets19;

SELECT * FROM streets_reprojected;

-- 4 --
CREATE TABLE input_points(id int NOT NULL PRIMARY KEY, 
						  geometry geometry);
	
INSERT INTO input_points VALUES
(1, 'POINT(8.36093 49.03174)'),
(2, 'POINT(8.39876 49.00644)');

-- 5 --
UPDATE input_points SET geometry = ST_TRANSFORM(ST_SetSRID(geometry, 4326), 3068);

-- 6 --
SELECT * FROM nodes19;

ALTER TABLE nodes19
 	ALTER COLUMN geom TYPE geometry(POINT, 3068) USING ST_TRANSFORM(geom, 3068);

-- Jednostką w EPSG 3068 jest metr zatem uzywam dist < 200, nie 0.002
-- Punkt musi być skrzyżowaniem, więc intersect = 'Y'

SELECT *, ST_DISTANCE(geom, ST_MAKELINE(
	(SELECT geometry FROM input_points WHERE id = 1), (SELECT geometry FROM input_points WHERE id = 2)
									   )
					 ) as dist
FROM nodes19 WHERE nodes19.intersect = 'Y' AND ST_DISTANCE(geom, ST_MAKELINE(
	(SELECT geometry FROM input_points WHERE id = 1), (SELECT geometry FROM input_points WHERE id = 2)
																			) 
														  ) < 200;

-- 7 --
SELECT ST_GeometryType(geom) FROM lua19;

ALTER TABLE poi19
 	ALTER COLUMN geom TYPE geometry(POINT, 3068) USING ST_TRANSFORM(geom, 3068);
	
ALTER TABLE lua19
 	ALTER COLUMN geom TYPE geometry(MULTIPOLYGON, 3068) USING ST_TRANSFORM(geom, 3068);
	
--SELECT * FROM poi19 WHERE poi19.type='Sporting Goods Store';
--SELECT * FROM lua19 WHERE lua19.type LIKE '%Park%' AND lua19.type NOT LIKE '%Parking%';

--SELECT * FROM poi19 CROSS JOIN lua19 
--WHERE poi19.type='Sporting Goods Store' AND lua19.type LIKE '%Park%' AND 
--	lua19.type NOT LIKE '%Parking%' AND ST_Contains(ST_BUFFER(lua19.geom, 300), poi19.geom)
--ORDER BY poi19.gid;

SELECT COUNT(DISTINCT poi19.gid) FROM poi19 CROSS JOIN lua19 
WHERE poi19.type='Sporting Goods Store' AND lua19.type LIKE '%Park%' AND 
	lua19.type NOT LIKE '%Parking%' AND ST_Contains(ST_BUFFER(lua19.geom, 300), poi19.geom);

-- 24 sklepy w pobliżu parków

-- 8 --

-- Tu nie trzeba transformować
-- SELECT * FROM rail19;
-- SELECT * FROM water19;

CREATE TABLE bridges AS
SELECT ST_AsText(ST_Intersection(rail19.geom, water19.geom)) FROM rail19 
CROSS JOIN water19 WHERE ST_Intersects(rail19.geom, water19.geom);

SELECT * FROM bridges; 
-- 60 mostów kolejowo - wodnych

-- END --
DROP TABLE bridges;
DROP TABLE input_points;
DROP TABLE streets_reprojected;
DROP TABLE new_temp;
DROP TABLE new_poi;
DROP TABLE new_build;

DROP TABLE build18;
DROP TABLE build19;
DROP TABLE streets19;
DROP TABLE poi19;
DROP TABLE poi18;
DROP TABLE rail19;
DROP TABLE water19;
DROP TABLE nodes19;
DROP TABLE lua19;