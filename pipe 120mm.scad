$fn = 512;
difference() {
    union() {
        cylinder(5, 120/2, 120/2+2.5);
        translate([0, 0, 5]) cylinder(5, 120/2+2.5, 120/2+2.5);
        translate([0, 0, 10]) cylinder(5, 120/2+2.5, 120/2);
        translate([0, 0, 15]) cylinder(150-15-15, 120/2, 120/2);
        translate([0, 0, 150-15]) cylinder(5, 120/2, 120/2+2.5);
        translate([0, 0, 150-15+5]) cylinder(5, 120/2+2.5, 120/2+2.5);
        translate([0, 0, 150-15+10]) cylinder(5, 120/2+2.5, 120/2);
    }
    cylinder(150, 114/2, 114/2);
}