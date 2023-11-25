-- 5. ALGEBRA MAP
-- 5.1 Wyrażenie Algebry Map

CREATE TABLE zurowski_407589.porto_ndvi AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid, ST_MapAlgebra( r.rast, 1, r.rast, 4, 
	'([rast2.val] - [rast1.val]) / ([rast2.val] + [rast1.val])::float','32BF'
	) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON zurowski_407589.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zurowski_407589'::name, 'porto_ndvi'::name,'rast'::name);

------------------------------------
-- 5.2 Funkcja zwrotna

create or replace function zurowski_407589.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS
$$
BEGIN
	--RAISE NOTICE 'Pixel Value: %', value [1][1][1];-->For debug purposes
	RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value [1][1][1]); --> NDVI calculation!
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

-------

CREATE TABLE zurowski_407589.porto_ndvi2 AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,
	ST_MapAlgebra( 
		r.rast, ARRAY[1,4],
		'zurowski_407589.ndvi(double precision[], integer[],text[])'::regprocedure, '32BF'::text
	) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON zurowski_407589.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('zurowski_407589'::name, 'porto_ndvi2'::name,'rast'::name);

------------------------------------
-- 5.3 Funkcja zwrotna TPI
-- W public -> functions:
-- - public._st_tpi4ma - funkcja używana w algebrze map
-- - public.st_tpi - wywoluje poprzednią

------------------------------------
------------------------------------
-- 6. EKSPORT DANYCH
-- 6.0 Poprzez QGIS

------------------------------------
-- 6.1 ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM zurowski_407589.porto_ndvi;

------------------------------------
-- 6.2 ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM zurowski_407589.porto_ndvi;

SELECT ST_GDALDrivers(); --> Lista obsługiwanych formatów

------------------------------------
-- 6.3 Za pomocą dużego obiektu (large object, lo)
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
	ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
	) AS loid
FROM zurowski_407589.porto_ndvi;
----------------------------------------------
SELECT lo_export(loid, 'D:\myraster.tiff') --> Save the file in a place where the user postgres have access. In windows a flash drive usualy works fine.
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.

