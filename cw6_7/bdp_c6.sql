-- W TRAKCIE ...

-- 1. Tworzenie rastrów z istniejących rastrów i interakcja z wektorami
-- 1A. ST_Intersects

CREATE TABLE zurowski_407589.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

-- dodanie serial primary key:
ALTER TABLE zurowski_407589.intersects
ADD COLUMN rid SERIAL PRIMARY KEY;

-- utworzenie indeksu przestrzennego:
CREATE INDEX idx_intersects_rast_gist ON zurowski_407589.intersects
USING gist (ST_ConvexHull(rast));

-- dodanie raster constraints:
-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('zurowski_407589'::name, 'intersects'::name,'rast'::name);

------------------------------------
-- 1B. ST_Clip
--DROP TABLE zurowski_407589.clip;

CREATE TABLE zurowski_407589.clip AS
SELECT ST_Clip(a.rast, b.geom, true) AS rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

-- dodanie serial primary key:
ALTER TABLE zurowski_407589.clip
ADD COLUMN rid SERIAL PRIMARY KEY;

-- utworzenie indeksu przestrzennego:
CREATE INDEX idx_clip_rast_gist ON zurowski_407589.clip
USING gist (ST_ConvexHull(rast));

-- dodanie raster constraints:
-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('zurowski_407589'::name, 'clip'::name,'rast'::name);

------------------------------------
-- 1C. ST_Union
CREATE TABLE zurowski_407589.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true)) AS rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

-- dodanie serial primary key:
ALTER TABLE zurowski_407589.union
ADD COLUMN rid SERIAL PRIMARY KEY;

-- utworzenie indeksu przestrzennego:
CREATE INDEX idx_union_rast_gist ON zurowski_407589.union
USING gist (ST_ConvexHull(rast));

-- dodanie raster constraints:
-- schema::name table_name::name raster_column::name
SELECT AddRasterConstraints('zurowski_407589'::name, 'union'::name,'rast'::name);

------------------------------------
-- 2. Tworzenie rastrów z wektorów (rastrowanie)
-- 2A. ST_Union

-- ...