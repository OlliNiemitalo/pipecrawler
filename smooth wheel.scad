$fn = 256;

bearing_height = 7;
bearing_od = 22 + 0.4;
bearing_bevel = 0.5;
extra_bevel = 0.75;
n = 32;

cylinder(extra_bevel + bearing_bevel, bearing_od/2 - bearing_bevel - extra_bevel, bearing_od/2);
for (i = [0 : n - 1]) {
    rel_z = i/n;
    rel_z_2 = (i + 1)/n;
    extra = 4*rel_z*(1 - rel_z)*4*rel_z*(1 - rel_z);   
    extra_2 = 4*rel_z_2*(1 - rel_z_2)*4*rel_z_2*(1 - rel_z_2);
    multiplier = 0 + extra*0.75;
    multiplier_2 = 0 + extra_2*0.75;
    translate([0, 0, extra_bevel + bearing_bevel + i*(bearing_height - bearing_bevel*2)/n]) cylinder((bearing_height - bearing_bevel*2)/n, bearing_od/2+1.2/2*multiplier, bearing_od/2+1.2/2*multiplier_2);
}
translate([0, 0, extra_bevel + bearing_bevel]) cylinder(bearing_height - bearing_bevel*2, bearing_od/2, bearing_od/2);
translate([0, 0, extra_bevel + bearing_height - bearing_bevel]) cylinder(bearing_bevel + extra_bevel, bearing_od/2, bearing_od/2 - bearing_bevel - extra_bevel);