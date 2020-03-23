﻿TRUNCATE niamoto_portal.data_shape_shape CASCADE;
INSERT INTO niamoto_portal.data_shape_shape(
            id, label, location, forest_area, forest_in, forest_perimeter, 
            forest_um_area, land_area, n_unique_species, nb_plots, nb_families, nb_occurence, 
            nb_patchs, nb_patchs_in, nb_species, r_in_median, type_shape, 
            land_um_area, um_geom)
    SELECT gid,
     name,
     geom,
     round(forest_area_ha::numeric,0),
     round(forest_in_ha::numeric,0),
     round(forest_perimeter_km::numeric,0),
     round(forest_um_area_ha::numeric,0),
     round(land_area_ha::numeric,0),
     n_unique_species,
     nb_plots,
     nb_families,
     nb_occurences,
     nb_patchs,
     nb_patchs_in,
     nb_species,
     r_in_median,
     type, 
     round(landum_area_ha::numeric,0),
     um_geom
  FROM atlas_pn.pn_emprises;
