$fn=128;
difference() {
    cylinder(30, 25, 25);
    for (i = [0 : 2]) {
        rotate([0, 0, i*360/3]) translate([20, 0, 0]) cylinder(50, 4, 4);
    }
    for (i = [0 : 2]) {
        rotate([0, 0, i*360/3]) translate([20, 0, 0]) cylinder(30, 3, 3);
    }    
}
cylinder(100, 4, 4);

translate([0, 0, -10]) for (i = [0 : 2]) {
    rotate([0, 0, i*360/3]) translate([20, 0, 0]) cylinder(50, 2, 2);
}    

translate([0, 0, 40]) difference() {
    cylinder(2, 25, 25);
    cylinder(2, 6, 6);
}
