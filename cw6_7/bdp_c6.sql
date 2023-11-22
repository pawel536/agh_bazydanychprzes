-- W TRAKCIE ...

-- 1. Tworzenie rastrów z istniejących rastrów i interakcja z wektorami
-- 1.1 ST_Intersects

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
-- 1.2 ST_Clip

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
-- 1.3 ST_Union

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
-- 2.1 ST_AsRaster

CREATE TABLE zurowski_407589.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

------------------------------------
-- 2.2 ST_Union

------------------------------------
-- 2.3 ST_AsRaster

CREATE TABLE zurowski_407589.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

------------------------------------
-- 3. Konwertowanie rastrów na wektory (wektoryzowanie)


------------------------------------
-- 4. Analiza rastrów
-- 4.1 ST_Band - do wyodrębniania pasm z rastra

CREATE TABLE zurowski_407589.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

------------------------------------
-- 4.2 ST_Clip - może być użyty do wycięcia rastra z innego rastra. 
-- Poniższy przykład wycina jedną parafię z tabeli vectors.porto_parishes. 
-- Wynik będzie potrzebny do wykonania kolejnych przykładów.

CREATE TABLE zurowski_407589.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

------------------------------------
-- 4.3 ST_Slope
-- Poniższy przykład użycia funkcji ST_Slope wygeneruje nachylenie przy 
-- użyciu poprzednio wygenerowanej tabeli (wzniesienie).

CREATE TABLE zurowski_407589.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM zurowski_407589.paranhos_dem AS a;

------------------------------------
-- 4.4 ST_Reclass - Aby zreklasyfikować raster należy użyć funkcji ST_Reclass.

CREATE TABLE zurowski_407589.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3', '32BF',0)
FROM zurowski_407589.paranhos_slope AS a;

------------------------------------
-- 4.5 ST_SummaryStats
-- Aby obliczyć statystyki rastra można użyć funkcji ST_SummaryStats. 
-- Poniższy przykład wygeneruje statystyki dla kafelka.

SELECT st_summarystats(a.rast) AS stats
FROM zurowski_407589.paranhos_dem AS a;

------------------------------------
-- 4.6 - ST_SummaryStats oraz Union
-- Przy użyciu UNION można wygenerować jedną statystykę wybranego rastra.

SELECT st_summarystats(ST_Union(a.rast))
FROM zurowski_407589.paranhos_dem AS a;

--ST_SummaryStats zwraca złożony typ danych. Więcej informacji na temat złożonego typu danych:
--https://www.postgresql.org/docs/current/static/rowtypes.html

------------------------------------
-- 4.7 - ST_SummaryStats z lepszą kontrolą złożonego typu danych

WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM zurowski_407589.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

------------------------------------
-- 4.8 - ST_SummaryStats w połączeniu z GROUP BY
-- Aby wyświetlić statystykę dla każdego poligonu "parish" można użyć polecenia GROUP BY

WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast, b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

------------------------------------
-- 4.9 - ST_Value
-- Funkcja ST_Value pozwala wyodrębnić wartość piksela z punktu lub zestawu punktów. 
-- Poniższy przykład wyodrębnia punkty znajdujące się w tabeli vectors.places.
-- Ponieważ geometria punktów jest wielopunktowa, a funkcja ST_Value wymaga geometrii jednopunktowej,
-- należy przekonwertować geometrię wielopunktową na geometrię jednopunktową za pomocą funkcji (ST_Dump(b.geom)).geom.

SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

------------------------------------
-- 4.10 - ...