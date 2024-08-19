use <3rd-party/threads-scad/threads.scad>; // https://github.com/rcolyer/threads-scad

bat_l = 70.5;

bearing_height = 7;
bearing_od = 22;
bearing_id = 8; // Not used
bearing_bevel = 0.5;

wheel_od = 26;
wheel_profile_r = 8;
wheel_lip_height = 0.5;
wheel_lip_width = 1; 

bolt_nominal_diameter = 3;
true_bolt_head_diameter = 6;
bolt_head_diameter = true_bolt_head_diameter + 4.5;
bolt_head_height = 3;

$fn=32;

body_id = 34;
body_od = 50;

shaft_support_h = 80;
shaft_support_t = 1;

conn_screw_r = 21;

motor_h = 25.5;
motor_d = 32.5;
motor_offset = (27.9 - 12.2) / 2;
motor_hole_d = (35.5 + 41.5) / 2;
motor_ear_w = 8.5;
motor_ear_t = 2;
motor_ear_d = 47 + 10;
motor_y = bolt_head_height + 1;

con_r = 15;

// Bearing
module bearing_cutout() {
    translate([0, 0, -wheel_lip_height - 10]) cylinder(wheel_lip_height + 10, bearing_od/2 - wheel_lip_width, bearing_od/2 - wheel_lip_width);
    cylinder(bearing_bevel, bearing_od/2 - bearing_bevel, bearing_od/2);
    translate([0, 0, bearing_bevel]) cylinder(bearing_height - 2*bearing_bevel, bearing_od/2, bearing_od/2);
    translate([0, 0, bearing_height - bearing_bevel]) cylinder(bearing_bevel, bearing_od/2, bearing_od/2 - bearing_bevel);
    translate([0, 0, bearing_height]) cylinder(wheel_lip_height, bearing_od/2 - wheel_lip_width, bearing_od/2 - wheel_lip_width);
}

if (true) ScrewHole( bolt_nominal_diameter, motor_y + motor_h, position=[motor_offset, motor_hole_d/2, 0]) ScrewHole( bolt_nominal_diameter, motor_y + motor_h, position=[motor_offset, -motor_hole_d/2, 0]) difference() {
    union() {
        minkowski() {
            translate([0, 0, shaft_support_h - 15 - 0.5]) cube([4-0.75, 42, 30], center=true);
            sphere(0.5, $fn=8);
        }
        cylinder(shaft_support_h/2, body_od/2, body_od/2);
        translate([0, 0, shaft_support_h/2]) cylinder(shaft_support_h/2, body_od/2, bearing_od/2 + shaft_support_t);
    }
    translate([0, 0, shaft_support_h/2 - 1]) rotate([0, 0, 360/24]) cylinder(shaft_support_h/2  - bearing_height, body_od/2 - shaft_support_t, bearing_od/2 - 1, $fn = 12);
    difference() {
        union() {
        translate([0, 0, 1 + bolt_head_height + 1]) rotate([0, 0, 360/24]) cylinder(shaft_support_h/2 - bolt_head_height - 2 - 1, body_od/2 - shaft_support_t, body_od/2 - shaft_support_t, $fn=12);
        translate([0, 0, 1 + bolt_head_height]) rotate([0, 0, 360/24]) cylinder(1, body_od/2 - shaft_support_t - 1, body_od/2 - shaft_support_t, $fn=12);
        }
        translate([motor_offset, 0, motor_y]) {
            difference() {
                translate([0, 0, (motor_h - motor_ear_t)/2]) cube([motor_ear_w, motor_ear_d, motor_h - motor_ear_t], center=true);
                cylinder(motor_h, motor_d/2, motor_d/2, $fn=64);
            }            
        }
    }
    translate([0, 0, shaft_support_h - bearing_height - 0.5]) bearing_cutout();
    translate([-50, 0, 50]) cube([100, 100, 120], center = true);
    for (i = [0: 3]) {
        rotate([0, 0, i*120]) {
            translate([conn_screw_r + (bolt_head_diameter - true_bolt_head_diameter)/2 - 1, 0, 1]) rotate([0, 0, 360/16]) cylinder(100, bolt_head_diameter/2 + 0.5, bolt_head_diameter/2 + 0.5, $fn=8);
            translate([conn_screw_r, 0, 0]) cylinder(1, bolt_nominal_diameter/2, bolt_nominal_diameter/2);
        }            
    }
    //translate([motor_offset, 0, motor_y]) motor();
    translate([motor_offset, motor_hole_d/2, motor_y + motor_h - motor_ear_t]) rotate([0, 0, 360/24 - 360/16]) cylinder(100, bolt_head_diameter/2 + 0.5, bolt_head_diameter/2 + 0.5, $fn=8);
    mirror([0, 1, 0]) translate([motor_offset, motor_hole_d/2, motor_y + motor_h - motor_ear_t]) rotate([0, 0, 360/24 - 360/16]) cylinder(100, bolt_head_diameter/2 + 0.5, bolt_head_diameter/2 + 0.5, $fn=8);
    {
    translate([-3, bearing_od/2 + 1 + 4, shaft_support_h - 5]) rotate([0, 90, 0]) cylinder(4, 2, 2);
    translate([2, bearing_od/2 + 1 + 4, shaft_support_h - 5]) rotate([0, 90, 0]) cylinder(10, 4, 4);
    translate([-2, bearing_od/2 + 1 + 4, shaft_support_h - 5]) rotate([0, -90, 0]) cylinder(10, 4, 4);
    }
    mirror([0, 1, 0]) {
    translate([-3, bearing_od/2 + 1 + 4, shaft_support_h - 5]) rotate([0, 90, 0]) cylinder(4, 2, 2);
    translate([2, bearing_od/2 + 1 + 4, shaft_support_h - 5]) rotate([0, 90, 0]) cylinder(10, 4, 4);
    translate([-2, bearing_od/2 + 1 + 4, shaft_support_h - 5]) rotate([0, -90, 0]) cylinder(10, 4, 4);
    }
    translate([10, 10, 0]) cylinder(5, 6, 6);
    translate([10, -10, 0]) cylinder(5, 6, 6);
    translate([-12, 0, 0]) cylinder(5, 10, 10);
}

module motor() {
    cylinder(motor_h, motor_d/2, motor_d/2);
    translate([0, 0, motor_h - motor_ear_t/2]) cube([motor_ear_w, motor_ear_d, motor_ear_t], center=true);
}

module con() ScrewHole(bolt_nominal_diameter, con_r - bolt_head_height, position=[0, -con_r + bolt_head_height, 2 + 5/2], rotation=[-90,0,0]) ScrewHole(bolt_nominal_diameter, con_r - bolt_head_height, position=[0, -(-con_r + bolt_head_height), 2 + 5/2], rotation=[90,0,0]) ScrewHole(bolt_nominal_diameter, con_r - bolt_head_height, position=[0, -con_r + bolt_head_height, 20 - (2 + 5/2)], rotation=[-90,0,0]) ScrewHole(bolt_nominal_diameter, con_r - bolt_head_height, position=[0, -(-con_r + bolt_head_height), 20 - (2 + 5/2)], rotation=[90,0,0]){
    difference() {
        union() {
            cylinder(20, con_r, con_r);
            translate([0, 0, 20]) cylinder(21, con_r, 8/2 + 2);
        }
        difference() {
            cylinder(7, 5/2, 5/2);
            translate([0, 2.5+4/2, 2.5 + 2]) cube([5, 5, 5], center = true);
            translate([0, -2.5-4/2, 2.5 + 2]) cube([5, 5, 5], center = true);
        }
        translate([0, 0, 7]) cylinder(2, 5/2, 8/2);
        translate([0, 0, 7 + 2]) cylinder(40-7, 8/2, 8/2);
        //translate([-50, 0, 50]) cube([100, 100, 120], center = true);
        {
        translate([0, con_r, 2 + 5/2]) rotate([90, 360/16, 0]) cylinder(bolt_head_height, true_bolt_head_diameter/2 + 1, true_bolt_head_diameter/2 + 1, $fn=8);
        translate([0, con_r, 20 - (2 + 5/2)]) rotate([90, 360/16, 0]) cylinder(bolt_head_height, true_bolt_head_diameter/2 + 1, true_bolt_head_diameter/2 + 1, $fn=8);
        }
        mirror([0, 1, 0]) {
        translate([0, con_r, 2 + 5/2]) rotate([90, 360/16, 0]) cylinder(bolt_head_height, true_bolt_head_diameter/2 + 1, true_bolt_head_diameter/2 + 1, $fn=8);
        translate([0, con_r, 20 - (2 + 5/2)]) rotate([90, 360/16, 0]) cylinder(bolt_head_height, true_bolt_head_diameter/2 + 1, true_bolt_head_diameter/2 + 1, $fn=8);
        }
    }    
}

if (false) translate([0, 0, motor_y + motor_h + 2]) con();

if (false) 
        ScrewHole( bolt_nominal_diameter, body_od/2, position=[0, 0, 4], rotation=[-90, 0, -30 + 0*360/3])
ScrewHole( bolt_nominal_diameter, body_od/2, position=[0, 0, 4], rotation=[-90, 0, -30 + 1*360/3])
ScrewHole( bolt_nominal_diameter, body_od/2, position=[0, 0, 4], rotation=[-90, 0, -30 + 2*360/3])

        ClearanceHole( bolt_nominal_diameter, 10, position=[cos(120*0)*conn_screw_r, sin(120*0)*conn_screw_r,0])
        ClearanceHole( bolt_nominal_diameter, 10, position=[cos(120*1)*conn_screw_r, sin(120*1)*conn_screw_r,0])
        ClearanceHole( bolt_nominal_diameter, 10, position=[cos(120*2)*conn_screw_r, sin(120*2)*conn_screw_r,0])
    {    
    difference() {
        union() {
            cylinder(8, body_od/2, body_od/2, $fn = 64);
            translate([0, 0, 8]) cylinder(33, body_id/2-0.2, body_id/2-0.2, $fn = 64);
        }
        for (i = [0:2]) rotate([0, 0, 360/3*i]) {
        translate([conn_screw_r, 0, 0]) cylinder(bolt_head_height, true_bolt_head_diameter/2, true_bolt_head_diameter/2);
        translate([conn_screw_r, 0, bolt_head_height]) cylinder(true_bolt_head_diameter/2, true_bolt_head_diameter/2, 0);
    }
    for (i = [0:2]) rotate([0, 0, 60 + 360/3*i]) {
        translate([body_od/2, 0, 4]) rotate([0, -90, 0]) rotate([0, 0, 360/16]) cylinder(bolt_head_height, true_bolt_head_diameter/2 + 1, true_bolt_head_diameter/2 + 1, $fn=8);
        translate([body_od/2, 0, 4]) rotate([0, -90, 0]) translate([0, 0, bolt_head_height]) rotate([0, 0, 360/16]) cylinder(true_bolt_head_diameter/2 + 1, true_bolt_head_diameter/2 + 1, 0, $fn=8);
    }
        cylinder(8 + 33, 4, 4);
    }
}

if (false) ClearanceHole( bolt_nominal_diameter, 10, position=[cos(60 - 40 + 120*0)*conn_screw_r, sin(60 - 40 + 120*0)*conn_screw_r,0])
        ClearanceHole( bolt_nominal_diameter, 10, position=[cos(60 - 40 + 120*1)*conn_screw_r, sin(60 - 40 + 120*1)*conn_screw_r,0])
        ClearanceHole( bolt_nominal_diameter, 10, position=[cos(60 - 40 + 120*2)*conn_screw_r, sin(60 - 40 + 120*2)*conn_screw_r,0])difference() {
    union() {
        cylinder(4, 98/2, 98/2, $fn=64);
        cylinder(6, body_od/2 + 6, body_od/2, $fn=64);
    }
    cylinder(6, body_id/2, body_id/2, $fn=64);
    for (x = [-4:4]) {
        for (y = [-4:4]) {
            if (x*10*x*10 + y*10*y*10 > (body_od/2 + 3)*(body_od/2 + 3) && (x*10*x*10 + y*10*y*10 < (100/2 - 3)*(100/2 - 3))) {
                translate([x*10, y*10, 0]) cylinder(4, 3/2, 3/2, $fn=64);
                translate([x*10, y*10, 1]) cylinder(7, 6.5/2, 6.5/2, $fn=64);
            }
        }
    }    
}

if (false) {
    ScrewHole( bolt_nominal_diameter, 10, position=[-9, -15, 0], tolerance=0.1)
    ScrewHole( bolt_nominal_diameter, 10, position=[-9, 15, 0], tolerance=0.1)
    ScrewHole( bolt_nominal_diameter, 10, position=[-4, -15, 0], tolerance=0.1)
    ScrewHole( bolt_nominal_diameter, 10, position=[-4, 15, 0], tolerance=0.1)
    difference() {
        union() {
            translate([-19/4, 0, (bat_l + 4)/2]) cube([19/2+4, 19+4, bat_l + 4], center=true);
            translate([-19/4, 0, 10/2]) cube([19/2+4, 19+4 + 16, 10], center=true);
            cylinder(2, 19/2 + 2, 19/2 + 2, $fn=64);
            translate([0, 0, bat_l + 2]) cylinder(2, 19/2 + 2, 19/2 + 2, $fn=64);        
        }
        translate([0, 0, 2]) cylinder(bat_l, 19/2, 19/2);
        translate([-19/4, 0, (bat_l + 4)/2]) cube([19/2+4, 19, 50], center=true);
    }
}