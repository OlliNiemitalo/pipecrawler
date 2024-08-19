use <3rd-party/threads-scad/threads.scad>; // https://github.com/rcolyer/threads-scad

use <friction_clutch.scad>;

fc_body_base_h = 2;  // Friction clutch: body base height
fc_body_r = 9;  // Friction clutch: body radius
fc_height=25;  // Friction clutch: mechanism height
fc_shaft_diam=8;  // Friction clutch: shaft diameter
fc_tol=0.1;  // Friction clutch: tolerance by which to increase shaft radius in model
fc_tight=0.4;  // Friction clutch: spring preloading shift length
fc_t=1;  // Friction clutch: spring thickness
fc_gap=0.5;  // Friction clutch: gap between mechanism parts
fc_support_h=3;  // Friction clutch: height of the thin, printing support part of the mechanism
fc_support_t=0.4;  // Friction clutch: thickness of the of the thin, printing support part of the mechanism

motor_diam = 25;
motor_h = 60;
motor_shaft_support_h = 3.6;
motor_shaft_h = 12.1 - motor_shaft_support_h;
motor_shaft_cut_h = 8;
motor_shaft_diam = 3.9;
motor_z = 0;

coupler_z = motor_z + motor_h + motor_shaft_support_h;

body_id = 34;
body_od = 50;
body_screw_r = (body_id/2 + body_od/2)/2;

bearing_z = coupler_z + motor_shaft_h + fc_body_base_h + fc_height;

motor_support_h = bearing_z + 10;
motor_support_t = 2;
motor_support_base_h = 2;

bolt_nominal_diameter = 3;
bolt_head_diameter = 10;
bolt_head_height = 3;

motor_gummy_w = 10;

if (true) translate([0, 0, coupler_z]) {
    difference() {
        cylinder(motor_shaft_h + fc_body_base_h + fc_height, fc_body_r, fc_body_r, $fn=32);
        translate([0, 0, motor_shaft_h + fc_body_base_h]) friction_clutch(height=fc_height + 1/4096, shaft_diam=fc_shaft_diam, tol=fc_tol, tight=fc_tight, t=fc_t, gap=fc_gap, support_h=fc_support_h, support_t=fc_support_t);
    }
}

if (true) {
    shifted_arc(h=motor_support_base_h, orb=body_od/2, ort=body_od/2, irb=body_id/2, irt=body_id/2, sxb=0, sxt=0, syb=0, syt=0, angle0=0, angle1=360, $fn=36);
    difference() {
        union() {
            translate([0, 0, motor_support_base_h])shifted_arc(h=motor_support_base_h, orb=body_od/2, ort=body_od/2, irb=body_od/2-motor_support_t-motor_support_base_h, irt=body_od/2-motor_support_t, sxb=0, sxt=0, syb=0, syt=0, angle0=0, angle1=360, $fn=36);
            difference() {
                translate([0, 0, motor_support_base_h*2]) shifted_arc(h=motor_support_h - motor_support_base_h*2, orb=body_od/2, ort=bearing_od/2+motor_support_t, irb=body_od/2-motor_support_t, irt=bearing_od/2, sxb=0, sxt=0, syb=0, syt=0, angle0=0, angle1=360, $fn=36);
                //for (i = [0:2]) rotate([0, 0, 360/6+i*360/3 + 360/72]) translate([-20, 0, coupler_z - motor_shaft_support_h]) rotate([0, 0, 360/32]) cylinder(motor_support_h, bolt_head_diameter/2, bolt_head_diameter/2, $fn=16);
                for (i = [0:2]) rotate([0, 0, i*360/3 + 360/72]) translate([0, -motor_gummy_w/2, coupler_z - motor_shaft_support_h]) cube([body_od/2, motor_gummy_w, motor_shaft_support_h], center=false);
            }
        }
        for (i = [0:2]) rotate([0, 0, i*360/3 + 360/72]) translate([-(body_od/2 + body_id/2)/2, 0, 0]) rotate([0, 0, 360/32]) cylinder(motor_support_h, bolt_head_diameter/2, bolt_head_diameter/2, $fn=16);
    }
}

bat_l = 70.5;

bearing_height = 7;
bearing_od = 22;
bearing_id = 8; // Not used
bearing_bevel = 0.5;

wheel_od = 26;
wheel_profile_r = 8;
wheel_lip_height = 0.5;
wheel_lip_width = 1; 

$fn=32;

shaft_support_h = 120;
shaft_support_t = 2;

conn_screw_r = 21;

con_r = 15;

// Bearing
module bearing_cutout() {
    translate([0, 0, -wheel_lip_height - 10]) cylinder(wheel_lip_height + 10, bearing_od/2 - wheel_lip_width, bearing_od/2 - wheel_lip_width);
    cylinder(bearing_bevel, bearing_od/2 - bearing_bevel, bearing_od/2);
    translate([0, 0, bearing_bevel]) cylinder(bearing_height - 2*bearing_bevel, bearing_od/2, bearing_od/2);
    translate([0, 0, bearing_height - bearing_bevel]) cylinder(bearing_bevel, bearing_od/2, bearing_od/2 - bearing_bevel);
    translate([0, 0, bearing_height]) cylinder(wheel_lip_height, bearing_od/2 - wheel_lip_width, bearing_od/2 - wheel_lip_width);
}

if (false) difference() {
    union() {
        minkowski() {
            translate([0, 0, shaft_support_h - 30 - 0.5]) cube([4-0.75, 42, 60], center=true);
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
    // Half cut
    translate([-50, 0, shaft_support_h/2 - 5]) cube([100, 100, shaft_support_h + 20], center = true);
    // Main attachment screws
    for (i = [0: 3]) {
        rotate([0, 0, i*120]) {
            translate([conn_screw_r + (bolt_head_diameter - true_bolt_head_diameter)/2 - 1, 0, 1]) rotate([0, 0, 360/16]) cylinder(100, bolt_head_diameter/2 + 0.5, bolt_head_diameter/2 + 0.5, $fn=8);
            translate([conn_screw_r, 0, 0]) cylinder(1, bolt_nominal_diameter/2, bolt_nominal_diameter/2);
        }            
    }
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