use <3rd-party/threads-scad/threads.scad>; // https://github.com/rcolyer/threads-scad

use <flexure.scad>;

pipe_id = 114;
pipe_od = 120;
pipe_height = 300;

wheel_bearing_with_washers_height = 7; // 10 if washers, 7 if without
wheel_bearing_height = 7;
wheel_bearing_od = 22;
wheel_bearing_id = 8;
wheel_bearing_bevel = 0.5;

wheel_od = 26;
wheel_height = 8;

wheel_tight = 2.5; // How much to increase the radius of the wheel location, in order to press the wheel against the pipe

bolt_nominal_diameter = 3;
bolt_head_diameter = 6;
bolt_head_height = 3;

wheel_support_height = 11;
wheel_vertical_clearance = 0.5;
wheel_horizontal_clearance = 10;
wheel_support_diam = 13;
wheel_shoulder_diameter = 12;

vertical_wheel_support_tiehole_x = 20;
vertical_wheel_support_tiehole_y = 0;
vertical_wheel_support_tieholeb_x = 28;
vertical_wheel_support_tieholeb_y = 25;

spring_radii = [19.5,19.5];
spring_shift_x = pipe_id/2 - wheel_od/2 + wheel_tight - spring_radii[0] + 5;
spring_shift_y = wheel_support_diam/2;
spring_angles = [-8.27, 135];
spring_extra_t = [2, 0, 2, 1];
spring_extra_angles = [-38.65, -24.1];
spring_p = 2;
spring_t = 1;
spring_n = 64;
spring_skips = [1, 0, 0, 2];

spring2_radii = [pipe_id/2 - wheel_od/2 + wheel_tight, pipe_id/2 - wheel_od/2 + wheel_tight];
spring2_shift_x = 4;
spring2_shift_y = 0.16;
spring2_angles = [6.1, 43];
spring2_extra_t = [2, 0, 2, 1];
spring2_extra_angles = [-39, 25];
spring2_p = 2;
spring2_t = 1;
spring2_n = 64;
spring2_skips = [1, 0, 0, 2];

spring2_support_extra = 2.885;

support_t = 5;

body_id = 34;
body_od = 50;

conn_screw_r = 21;

$fn = 16;

// Pipe
module pipe() {
    translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_vertical_clearance - wheel_support_height])
    difference() {
        cylinder(pipe_height, pipe_od/2, pipe_od/2, $fn = 32);
        cylinder(pipe_height, pipe_id/2, pipe_id/2, $fn = 32);
        // Cutout to show what's inside
        translate([0, -pipe_od/2, 0]) cube([pipe_od, pipe_od, pipe_height], center=false);
    }
}

// wheel_bearing
module wheel_bearing() {
    translate([0, 0, (wheel_bearing_with_washers_height - wheel_bearing_height)/2]) difference() {
        union() {
            cylinder(wheel_bearing_bevel, wheel_bearing_od/2 - wheel_bearing_bevel, wheel_bearing_od/2);
            translate([0, 0, wheel_bearing_bevel]) cylinder(wheel_bearing_height - 2*wheel_bearing_bevel, wheel_bearing_od/2, wheel_bearing_od/2);
            translate([0, 0, wheel_bearing_height - wheel_bearing_bevel]) cylinder(wheel_bearing_bevel, wheel_bearing_od/2, wheel_bearing_od/2 - wheel_bearing_bevel);    
        }
        cylinder(wheel_bearing_height, wheel_bearing_id/2, wheel_bearing_id/2);
    }
}

module wheel() {
    wheel_bearing();
    translate([0, 0, (wheel_bearing_with_washers_height - wheel_bearing_height)/2]) import("wheel.stl", convexity=3);
}

module sector(height, small_r, big_r, angles = [-60, 60], $fn = $fn) {    
    points = [
        for(step = [0:$fn]) [big_r * cos(angles[0] + (angles[1] - angles[0])*step/$fn), big_r * sin(angles[0] + (angles[1] - angles[0])*step/$fn)],
        for(step = [0:$fn]) [small_r * cos(angles[1] + (angles[0] - angles[1])*step/$fn), small_r * sin(angles[1] + (angles[0] - angles[1])*step/$fn)]
    ];
    linear_extrude(height) polygon(points);
}

module wheelsupport(top = false) {
// Wheels and springs
  {
    difference() {
        union() {
            mirror([0, top?1:0, 0]) {
            // Bent spring
            translate([spring_shift_x, spring_shift_y, -wheel_bearing_with_washers_height/2 - wheel_vertical_clearance - wheel_support_height]) color([1, 1, 0.5]) linear_extrude(wheel_support_height) spiral_flexure(spring_radii, spring_angles, spring_angles + spring_extra_angles, spring_t/2, spring_extra_t[0], spring_extra_t[2], spring_t/2, spring_extra_t[3], spring_extra_t[1], spring_p, spring_skips, spring_n);
            // Almost straight spring
            translate([spring2_shift_x, spring2_shift_y, -wheel_bearing_with_washers_height/2 - wheel_vertical_clearance - wheel_support_height]) mirror([0, 1, 0]) color([1, 1, 0.5]) linear_extrude(wheel_support_height) spiral_flexure(spring2_radii, spring2_angles, spring2_angles + spring2_extra_angles, spring2_t/2, spring2_extra_t[0], spring2_extra_t[2], spring2_t/2, spring2_extra_t[3], spring2_extra_t[1], spring2_p, spring2_skips, spring2_n);
            // Spring supports
            translate([0, 0, -15]) linear_extrude(15) polygon([[38.22, -32.064], [8.7, -32], [8.7, 11], [18.02, 20.804]]);
    }

     translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, 0]) difference() {
        union() {
        // Wheel boltway
        translate([0, 0, -wheel_bearing_with_washers_height/2])    cylinder(wheel_bearing_with_washers_height / 2 + 5, wheel_bearing_id/2, wheel_bearing_id/2, $fn=64);

        hull() {
        // Wheel support shoulder
        translate([0, 0, -wheel_bearing_with_washers_height/2])    translate([0, 0, -0.25]) cylinder(0.25, wheel_shoulder_diameter/2, wheel_shoulder_diameter/2, $fn=64);
        // Wheel support
        translate([0, 0,  - wheel_bearing_with_washers_height/2 - wheel_vertical_clearance - wheel_support_height]) cylinder(wheel_support_height, wheel_support_diam/2, wheel_support_diam/2, $fn=64); 
        }       
    } 
    // Deleting slab
    translate([0, -wheel_support_diam/2, 5 - 1]) cube([wheel_support_diam, wheel_support_diam, 10], center = true);
    translate([0, 0, 5 + 1]) cube([wheel_support_diam, wheel_support_diam, 10], center = true);
    }
    }
}
// Center hole
        
}
 }
 
module drilledwheelsupport(top = false) {
    if (top) {
        // TOP
        // Wheel screws
                   
        rotate([90, 0, 0]) {
            difference() {
    
        // Vertical wheel support tiehole                
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance + 1, position=[vertical_wheel_support_tiehole_x, vertical_wheel_support_tiehole_y,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], rotation=[0, 0, 0], tolerance=0.15)   
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance + 1, position=[vertical_wheel_support_tieholeb_x, vertical_wheel_support_tieholeb_y,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], rotation=[0, 0, 0], tolerance=0.15)   
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance + 1, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], rotation=[0, 0, 0], tolerance=0.15)
        wheelsupport(top);
           // Screw top slots
            translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)]) cylinder(bolt_head_height, bolt_head_diameter/2+0.15, bolt_head_diameter/2+0.15);
            translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance) + bolt_head_height]) cylinder(bolt_head_diameter/2+0.15, bolt_head_diameter/2+0.15, 0);
            translate([vertical_wheel_support_tiehole_x, vertical_wheel_support_tiehole_y, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)]) cylinder(bolt_head_height, bolt_head_diameter/2+0.15, bolt_head_diameter/2+0.15);
            translate([vertical_wheel_support_tiehole_x, vertical_wheel_support_tiehole_y, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance) + bolt_head_height]) cylinder(bolt_head_diameter/2+0.15, bolt_head_diameter/2+0.15, 0);          
            translate([vertical_wheel_support_tieholeb_x, vertical_wheel_support_tieholeb_y, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)]) cylinder(bolt_head_height, bolt_head_diameter/2+0.15, bolt_head_diameter/2+0.15);
            translate([vertical_wheel_support_tieholeb_x, vertical_wheel_support_tieholeb_y, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance) + bolt_head_height]) cylinder(bolt_head_diameter/2+0.15, bolt_head_diameter/2+0.15, 0);                               
        }
    }
    } else {
        // BOTTOM
        rotate([90, 0, 0])
        // Vertical wheel support tiehole
        ScrewHole( bolt_nominal_diameter, wheel_support_height + wheel_vertical_clearance+4, position=[vertical_wheel_support_tiehole_x, -vertical_wheel_support_tiehole_y,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, wheel_support_height + wheel_vertical_clearance+4, position=[vertical_wheel_support_tieholeb_x, -vertical_wheel_support_tieholeb_y,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        // Wheel screwhole
        ScrewHole( bolt_nominal_diameter, wheel_support_height + wheel_vertical_clearance, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15, rotation=[0, 0, 0])
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + 1, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2], rotation=[0, 0, 0])
        wheelsupport(top); 
    }
}

module crown(top = false) {
    // Center cylinder
    difference() {
        union() {
            translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height - wheel_vertical_clearance]) cylinder(wheel_bearing_with_washers_height/2 + wheel_vertical_clearance + wheel_support_height, body_od/2, body_od/2, $fn = 64);        

        }
        
        // Center hole
        translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height - wheel_vertical_clearance]) cylinder(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance, body_id/2, body_id/2, $fn = 64);                
    }
 }
 
module drilledcrown(top = false) {
    difference() {
    if (top) {
        // TOP
             
        // Body screws
        ClearanceHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 120*0)*conn_screw_r, sin(180+60 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])
        
        ClearanceHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 120*1)*conn_screw_r, sin(180+60 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])
        
        ClearanceHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 120*2)*conn_screw_r, sin(180+60 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])

        // Additional body screws
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 40 + 120*0)*conn_screw_r, sin(180+60 + 40 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)        
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 40 + 120*1)*conn_screw_r, sin(180+60 + 40 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 40 + 120*2)*conn_screw_r, sin(60 + 40 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
         
        crown(top);
    } else {
        // BOTTOM
        // Body screws
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 120*0)*conn_screw_r, sin(180+60 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)        
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 120*1)*conn_screw_r, sin(180+60 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 120*2)*conn_screw_r, sin(180+60 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)

        // Additional body screws
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 40 + 120*0)*conn_screw_r, sin(180+60 + 40 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 40 + 120*1)*conn_screw_r, sin(180+60 + 40 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(180+60 + 40 + 120*2)*conn_screw_r, sin(180+60 + 40 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
         
        crown(top);
    }
    if (top) {
    // Wheel support bolt head slots
    for (i = [0:2]) rotate([0, 0, 360/3*i]) {
        translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)]) cylinder(bolt_head_height, bolt_head_diameter/2, bolt_head_diameter/2);
        translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance) + bolt_head_height]) cylinder(bolt_head_diameter/2, bolt_head_diameter/2, 0);
    }

    // Body bolt head slots
    for (i = [0:2]) rotate([0, 0, 60 + 360/3*i]) {
        translate([conn_screw_r, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)]) cylinder(bolt_head_height, bolt_head_diameter/2, bolt_head_diameter/2);
        translate([conn_screw_r, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance) + bolt_head_height]) cylinder(bolt_head_diameter/2, bolt_head_diameter/2, 0);
    }
    
    }
    // Additional Body bolt head channels
    for (i = [0:2]) rotate([0, 0, 180+60 + 80 + 360/3*i]) {
        translate([conn_screw_r, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)]) cylinder((wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), bolt_head_diameter/2, bolt_head_diameter/2);
    }
    }
 }
 
 module hardware() {
     for (i = [0:2]) rotate([0, 0, 360/3*i]) translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, 0]) translate([0, 0, -wheel_bearing_with_washers_height/2]) wheel();
 }
 
 //pipe();
 
 difference() {
     // Body screwhole
     union() {
        ScrewHole( bolt_nominal_diameter, 30, position=[cos(-360/18)*conn_screw_r, sin(-360/18)*conn_screw_r,-34], tolerance=0.15) rotate([180, 0, 0]) drilledwheelsupport(true);     
        //ScrewHole( bolt_nominal_diameter, 30, position=[cos(360/18)*conn_screw_r, sin(360/18)*conn_screw_r,-34], tolerance=0.15) drilledwheelsupport(false);
     }
     translate([0, 0, -33]) cylinder(55, body_id/2+0.15, body_id/2+0.15, $fn = 64);      
 }
 //crown();
 //translate([0, 0, -16.5]) cylinder(16.5, body_od, body_od);
//hardware();
 
//crown(true);