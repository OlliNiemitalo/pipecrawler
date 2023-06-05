vase_slicer_thickness = 1.2;
vase_slicer_offset = -vase_slicer_thickness/2;
function vase_use_offset(thickness) = thickness/2 - vase_slicer_offset;

$fn = 256;

min_thickness = 0.4;
max_thickness = 1.2;

bearing_height = 7;
bearing_od = 22;
bearing_bevel = 0.5;
extra_bevel = 0.75;
n = 32;

function calc_thickness(rel_z) = (rel_z < 0 || rel_z > 1) ? min_thickness : min_thickness + (max_thickness - min_thickness)*4*rel_z*(1 - rel_z);

cylinder(extra_bevel + bearing_bevel, bearing_od/2 - bearing_bevel - extra_bevel + vase_use_offset(min_thickness), bearing_od/2 + vase_use_offset(min_thickness));

for (i = [0 : n - 1]) {
    rel_z = i/n;
    rel_z_2 = (i + 1)/n;
    translate([0, 0, extra_bevel + bearing_bevel + i*(bearing_height - bearing_bevel*2)/n]) cylinder((bearing_height - bearing_bevel*2)/n, bearing_od/2+vase_use_offset(calc_thickness(rel_z)), bearing_od/2+vase_use_offset(calc_thickness(rel_z_2)));
}

translate([0, 0, extra_bevel + bearing_height - bearing_bevel]) cylinder(bearing_bevel + extra_bevel, bearing_od/2 + vase_use_offset(min_thickness), bearing_od/2 - bearing_bevel - extra_bevel + vase_use_offset(min_thickness));