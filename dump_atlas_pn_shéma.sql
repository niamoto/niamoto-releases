PGDMP     	    	                x            amapiac    10.5 (Debian 10.5-1.pgdg80+1) %   10.12 (Ubuntu 10.12-0ubuntu0.18.04.1)     L           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            M           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            N           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false                        2615    1922109    atlas_pn    SCHEMA        CREATE SCHEMA atlas_pn;
    DROP SCHEMA atlas_pn;
             amapiac    false                       1255    2198919 2   pn_classifyraster(public.raster, integer, integer)    FUNCTION     J  CREATE FUNCTION atlas_pn.pn_classifyraster(rast public.raster, classmin integer, classmax integer) RETURNS TABLE(classe double precision, pixelcount integer)
    LANGUAGE plpgsql STABLE
    AS $$
	BEGIN
	RETURN QUERY 
		(SELECT
			min ::float as classe,
			sum(count) ::integer pixelcount
		FROM
			(SELECT	
				(ST_Histogram(rast,1,classmax,ARRAY[1])).* AS hist
			  WHERE NOT ST_BandIsNoData(rast,1,true) --exclude rasters with only NODATA values (speed the query for rasters in multi-rows)
			) b
		WHERE min between classmin and classmax
		GROUP BY min
		ORDER BY min
		);
	END
$$;
 b   DROP FUNCTION atlas_pn.pn_classifyraster(rast public.raster, classmin integer, classmax integer);
       atlas_pn       amapiac    false    6            O           0    0 R   FUNCTION pn_classifyraster(rast public.raster, classmin integer, classmax integer)    COMMENT     �   COMMENT ON FUNCTION atlas_pn.pn_classifyraster(rast public.raster, classmin integer, classmax integer) IS 'return a table of the pixel distribution of the input raster splitted by classes';
            atlas_pn       amapiac    false    1561                       1255    2198590 1   pn_makegrid_2d(public.geometry, integer, integer)    FUNCTION     z  CREATE FUNCTION atlas_pn.pn_makegrid_2d(bound_polygon public.geometry, width_step integer, height_step integer) RETURNS public.geometry
    LANGUAGE plpgsql
    AS $$
DECLARE
  Xmin DOUBLE PRECISION;
  Xmax DOUBLE PRECISION;
  Ymax DOUBLE PRECISION;
  X DOUBLE PRECISION;
  Y DOUBLE PRECISION;
  NextX DOUBLE PRECISION;
  NextY DOUBLE PRECISION;
  CPoint public.geometry;
  sectors public.geometry[];
  i INTEGER;
  SRID INTEGER;
BEGIN
  Xmin := ST_XMin(bound_polygon);
  Xmax := ST_XMax(bound_polygon);
  Ymax := ST_YMax(bound_polygon);
  SRID := ST_SRID(bound_polygon);

  Y := ST_YMin(bound_polygon); --current sector's corner coordinate
  i := -1;
  <<yloop>>
  LOOP
    IF (Y > Ymax) THEN  
        EXIT;
    END IF;

    X := Xmin;
    <<xloop>>
    LOOP
      IF (X > Xmax) THEN
          EXIT;
      END IF;

      CPoint := ST_SetSRID(ST_MakePoint(X + width_step/2, Y+ height_step/2), SRID);
      NextX := X + width_step;
     

      i := i + 1;
      sectors[i] := ST_Expand(CPoint,width_step/2,height_step/2);

      X := NextX;
    END LOOP xloop;
    Y := Y + height_step;
  END LOOP yloop;

  RETURN ST_Collect(sectors);
END;
$$;
 o   DROP FUNCTION atlas_pn.pn_makegrid_2d(bound_polygon public.geometry, width_step integer, height_step integer);
       atlas_pn       amapiac    false    6            d           1259    2199011    pn_carto_forest    TABLE     j  CREATE TABLE atlas_pn.pn_carto_forest (
    id integer NOT NULL,
    gid_carto integer,
    f_geom public.geometry(Polygon,4326),
    f_geom100 public.geometry(MultiPolygon,4326),
    f_geom300 public.geometry(MultiPolygon,4326),
    f_geomssdm public.geometry(MultiPolygon,4326),
    f_geomaob public.geometry(MultiPolygon,4326),
    count_holdridge integer
);
 %   DROP TABLE atlas_pn.pn_carto_forest;
       atlas_pn         amapiac    false    6            c           1259    2199009    pn_carto_forest_id_seq    SEQUENCE     �   CREATE SEQUENCE atlas_pn.pn_carto_forest_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE atlas_pn.pn_carto_forest_id_seq;
       atlas_pn       amapiac    false    356    6            P           0    0    pn_carto_forest_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE atlas_pn.pn_carto_forest_id_seq OWNED BY atlas_pn.pn_carto_forest.id;
            atlas_pn       amapiac    false    355            b           1259    2198922    pn_emprises    TABLE     &  CREATE TABLE atlas_pn.pn_emprises (
    gid integer NOT NULL,
    type character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    land_area_ha numeric DEFAULT 0,
    land_um_area_ha numeric DEFAULT 0,
    reserve_area_ha numeric DEFAULT 0,
    reserve_um_area_ha numeric DEFAULT 0,
    mining_area_ha numeric DEFAULT 0,
    mining_um_area_ha numeric DEFAULT 0,
    ppe_area_ha numeric DEFAULT 0,
    forest_ppe_ha numeric DEFAULT 0,
    forest_area_ha numeric DEFAULT 0,
    forest_um_area_ha numeric DEFAULT 0,
    forest_reserve_ha numeric DEFAULT 0,
    forest_mining_ha numeric DEFAULT 0,
    forest_100m_ha numeric DEFAULT 0,
    forest_ssdm80_ha numeric DEFAULT 0,
    forest_aob2015_ha numeric DEFAULT 0,
    forest_perimeter_km numeric DEFAULT 0,
    nb_patchs integer DEFAULT 0,
    fragment_meff_cbc numeric DEFAULT 0,
    nb_patchs_in integer DEFAULT 0,
    forest_in_ha numeric DEFAULT 0,
    r_in_median numeric DEFAULT 0,
    nb_plots integer DEFAULT 0,
    nb_occurences integer DEFAULT 0,
    nb_families integer DEFAULT 0,
    nb_species integer DEFAULT 0,
    n_unique_species integer DEFAULT 0,
    geom public.geometry(MultiPolygon,4326),
    um_geom public.geometry(MultiPolygon,4326),
    pt_plot public.geometry(MultiPoint,4326),
    pt_occ public.geometry(MultiPoint,4326)
);
 !   DROP TABLE atlas_pn.pn_emprises;
       atlas_pn         amapiac    false    6            a           1259    2198920    pn_emprises_gid_seq    SEQUENCE     �   CREATE SEQUENCE atlas_pn.pn_emprises_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE atlas_pn.pn_emprises_gid_seq;
       atlas_pn       amapiac    false    354    6            Q           0    0    pn_emprises_gid_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE atlas_pn.pn_emprises_gid_seq OWNED BY atlas_pn.pn_emprises.gid;
            atlas_pn       amapiac    false    353            �           2604    2199014    pn_carto_forest id    DEFAULT     |   ALTER TABLE ONLY atlas_pn.pn_carto_forest ALTER COLUMN id SET DEFAULT nextval('atlas_pn.pn_carto_forest_id_seq'::regclass);
 C   ALTER TABLE atlas_pn.pn_carto_forest ALTER COLUMN id DROP DEFAULT;
       atlas_pn       amapiac    false    355    356    356            �           2604    2198925    pn_emprises gid    DEFAULT     v   ALTER TABLE ONLY atlas_pn.pn_emprises ALTER COLUMN gid SET DEFAULT nextval('atlas_pn.pn_emprises_gid_seq'::regclass);
 @   ALTER TABLE atlas_pn.pn_emprises ALTER COLUMN gid DROP DEFAULT;
       atlas_pn       amapiac    false    353    354    354            �           2606    2199019 *   pn_carto_forest table_pn_carto_forest_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY atlas_pn.pn_carto_forest
    ADD CONSTRAINT table_pn_carto_forest_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY atlas_pn.pn_carto_forest DROP CONSTRAINT table_pn_carto_forest_pkey;
       atlas_pn         amapiac    false    356            �           2606    2198956 "   pn_emprises table_pn_emprises_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY atlas_pn.pn_emprises
    ADD CONSTRAINT table_pn_emprises_pkey PRIMARY KEY (gid);
 N   ALTER TABLE ONLY atlas_pn.pn_emprises DROP CONSTRAINT table_pn_emprises_pkey;
       atlas_pn         amapiac    false    354           