use <3rd-party/threads-scad/threads.scad>; // https://github.com/rcolyer/threads-scad

pipe_id = 114;
pipe_od = 120;
pipe_height = 300;

helix_pitch = 20;
wheel_angle = atan2(helix_pitch, PI*pipe_id);

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
wheel_vertical_clearance = 2;
wheel_horizontal_clearance = 10;
wheel_support_diam = 13;
wheel_shoulder_diameter = 12;

spring_radius = 20;
spring_shift_x = pipe_id/2 - wheel_od/2 + wheel_tight - spring_radius + 5;
spring_shift_y = wheel_support_diam/2;
spring_angles = [-7.7, 141];
spring_extra_angles = [-43.9, 0];
spring_n = 3;
spring_t = 1;

spring_support_angle0 = 20;
spring_support_angle = 60;
spring_support_angle2 = 25;

spring2_radius = pipe_id/2 - wheel_od/2 + wheel_tight;
spring2_shift_x = 4;
spring2_shift_y = 0.16;
spring2_angles = [6.2, 43];
spring2_extra_angles = [-43, 25];
spring2_n = 3;
spring2_t = 1;

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

function ease(x, n) = pow(1 - 2*sqrt(x*(1 - x)), n);

function smooth(x) = 0.5 - 0.5*cos(180*x);

module spring(r, angles, t_angles, t_in, extra_in_start, extra_in_end, t_out, extra_out_start, extra_out_end, n, height, $fn = $fn) {    
    points = [
        for(step = [0:$fn]) [
            r * cos(angles[0] + (angles[1] - angles[0])*smooth(step/$fn)) + 
            (t_out + (step < $fn/2? extra_out_start : extra_out_end)*ease(smooth(step/$fn), n)) * cos(t_angles[0] + (t_angles[1] - t_angles[0])*smooth(step/$fn)) / cos(t_angles[0]-angles[0] + (t_angles[1] - angles[1] - t_angles[0] + angles[0])*smooth(step/$fn)),
            r * sin(angles[0] + (angles[1] - angles[0])*smooth(step/$fn)) +
            (t_out + (step < $fn/2? extra_out_start : extra_out_end)*ease(smooth(step/$fn), n)) * sin(t_angles[0] + (t_angles[1] - t_angles[0])*smooth(step/$fn)) / cos(t_angles[0]-angles[0] + (t_angles[1]-angles[1] - t_angles[0]+angles[0])*smooth(step/$fn))
        ],
        for(step = [0:$fn]) [
            r * cos(angles[1] + (angles[0] - angles[1])*smooth(step/$fn)) -
            (t_in + (step < $fn/2?extra_in_start : extra_in_end)*ease(smooth(step/$fn), n)) * cos(t_angles[1] + (t_angles[0] - t_angles[1])*smooth(step/$fn)) / cos(t_angles[1]-angles[1] + (t_angles[0]-angles[0] - t_angles[1]+angles[1])*smooth(step/$fn)),
            r * sin(angles[1] + (angles[0] - angles[1])*smooth(step/$fn)) -
            (t_in + (step < $fn/2?extra_in_start : extra_in_end)*ease(smooth(step/$fn), n)) * sin(t_angles[1] + (t_angles[0] - t_angles[1])*smooth(step/$fn)) / cos(t_angles[1]-angles[1] + (t_angles[0]-angles[0] - t_angles[1]+angles[1])*smooth(step/$fn))
        ]
    ];
    linear_extrude(height) polygon(points);
}

module crown(top = false) {
// Wheels and springs
for (i = [0:2]) rotate([0, 0, 360/3*i]) {
    difference() {
        union() {
            mirror([0, top?1:0, 0]) {
            // Bent spring
            translate([spring_shift_x, spring_shift_y, -wheel_bearing_with_washers_height/2 - wheel_vertical_clearance - wheel_support_height]) spring(spring_radius, spring_angles, spring_angles + spring_extra_angles, spring_t/2, 1, 1, spring_t/2, 1, 1, spring_n, wheel_support_height, $fn=64);
            // Straight spring
            translate([spring2_shift_x, spring2_shift_y, -wheel_bearing_with_washers_height/2 - wheel_vertical_clearance - wheel_support_height]) mirror([0, 1, 0]) spring(spring2_radius, spring2_angles, spring2_angles + spring2_extra_angles, spring2_t/2, 2/cos(30), 1, spring2_t/2, 1, 0, spring2_n, wheel_support_height, $fn=64);
    // Spring support
    rotate([0, 0, spring_support_angle0]) difference() {
        translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height - wheel_vertical_clearance]) linear_extrude(wheel_support_height) polygon([[cos(60 + spring_support_angle)*body_od/2*0.996, sin(60 + spring_support_angle)*body_od/2*0.996], [cos(60 - spring_support_angle2)*body_od/2*0.996, sin(60 - spring_support_angle2)*body_od/2*0.996], [cos(60)*(pipe_id/2 - wheel_od/2 + wheel_tight + spring2_t/2 + spring2_support_extra), sin(60)*(pipe_id/2 - wheel_od/2 + wheel_tight + spring2_t/2 + spring2_support_extra)]]);
        translate([cos(180 + 57)*support_t, sin(180+57)*support_t, -wheel_bearing_with_washers_height/2 - wheel_support_height - wheel_vertical_clearance]) linear_extrude(wheel_support_height) polygon([[cos(60 + spring_support_angle)*body_od/2*0.996, sin(60 + spring_support_angle)*body_od/2*0.996], [cos(60 - spring_support_angle2)*body_od/2*0.996, sin(60 - spring_support_angle2)*body_od/2*0.996], [cos(60)*(pipe_id/2 - wheel_od/2 + wheel_tight + spring2_t/2 + spring2_support_extra), sin(60)*(pipe_id/2 - wheel_od/2 + wheel_tight + spring2_t/2 + spring2_support_extra)]]);
    }
    }

     translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, 0]) difference() {
        union() {
        rotate([wheel_angle, 0, 0]) {
            // Wheel boltway
            translate([0, 0, -wheel_bearing_with_washers_height/2])    cylinder(wheel_bearing_with_washers_height / 2 + 5, wheel_bearing_id/2, wheel_bearing_id/2, $fn=64);

        }
        hull() {
        rotate([wheel_angle, 0, 0]) {
            // Wheel support shoulder
            translate([0, 0, -wheel_bearing_with_washers_height/2])    translate([0, 0, -0.25]) cylinder(0.25, wheel_shoulder_diameter/2, wheel_shoulder_diameter/2, $fn=64);
        }
        // Wheel support
        translate([0, 0,  - wheel_bearing_with_washers_height/2 - wheel_vertical_clearance - wheel_support_height]) cylinder(wheel_support_height, wheel_support_diam/2, wheel_support_diam/2, $fn=64); 
        }       
    } 
        // Deleting slab
        multmatrix([[1, 0, 0, 0], [0, 1, -tan(wheel_angle), 0], [0, 0, 1, 0], [0, 0, 0, 1]]) {
        translate([0, -wheel_support_diam/2, 5 - 1]) cube([wheel_support_diam, wheel_support_diam, 10], center = true);
        translate([0, 0, 5 + 1]) cube([wheel_support_diam, wheel_support_diam, 10], center = true);
        }
    }
    }
}}
// Structural parts

    // Center cylinder
    difference() {
        union() {
            translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height - wheel_vertical_clearance]) cylinder(wheel_bearing_with_washers_height/2 + wheel_vertical_clearance + wheel_support_height, body_od/2, body_od/2, $fn = 64);        

        }
        
        // Center hole
        translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height - wheel_vertical_clearance]) cylinder(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance, body_id/2, body_id/2, $fn = 64);                
    }
 }
 
 
 module drilledcrown(top = false, mir = false) {
    difference() {
    if (top) {
        // TOP
        // Wheel screws
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance + 1, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])  
         
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance + 1, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])  
   
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance + 1, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])  
         
             
        // Body screws
        ClearanceHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 120*0)*conn_screw_r, sin(60 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])
        
        ClearanceHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 120*1)*conn_screw_r, sin(60 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])
        
        ClearanceHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 120*2)*conn_screw_r, sin(60 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)])

        // Additional body screws
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 40 + 120*0)*conn_screw_r, sin(60 + 40 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)        
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 40 + 120*1)*conn_screw_r, sin(60 + 40 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 40 + 120*2)*conn_screw_r, sin(60 + 40 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
         
        mirror([0, mir? 1: 0, 0]) crown(top);
    } else {
        // BOTTOM
        // Wheel screws
        ScrewHole( bolt_nominal_diameter, wheel_support_height + wheel_vertical_clearance, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + 1, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])   
         
        ScrewHole( bolt_nominal_diameter, wheel_support_height + wheel_vertical_clearance, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + 1, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])   
         
        ScrewHole( bolt_nominal_diameter, wheel_support_height + wheel_vertical_clearance, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ClearanceHole( bolt_nominal_diameter, wheel_bearing_with_washers_height/2 + 1, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])
                     
        // Body screws
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 120*0)*conn_screw_r, sin(60 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)        
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 120*1)*conn_screw_r, sin(60 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 120*2)*conn_screw_r, sin(60 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)

        // Additional body screws
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 40 + 120*0)*conn_screw_r, sin(60 + 40 + 120*0)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 40 + 120*1)*conn_screw_r, sin(60 + 40 + 120*1)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
        ScrewHole( bolt_nominal_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), position=[cos(60 + 40 + 120*2)*conn_screw_r, sin(60 + 40 + 120*2)*conn_screw_r,-(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)], tolerance=0.15)
         
        mirror([0, mir? 1: 0, 0]) crown(top);
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
    for (i = [0:2]) rotate([0, 0, 60 + 80 + 360/3*i]) {
        translate([conn_screw_r, 0, -(wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance)]) cylinder((wheel_bearing_with_washers_height/2 + wheel_support_height + wheel_vertical_clearance), bolt_head_diameter/2, bolt_head_diameter/2);
    }
    }
 }
 
 module hardware() {
     for (i = [0:2]) rotate([0, 0, 360/3*i]) translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, 0]) rotate([wheel_angle, 0, 0]) translate([0, 0, -wheel_bearing_with_washers_height/2]) wheel();
 }
 
 //pipe();
 
 rotate([180, 0, 0]) drilledcrown(true);
 // drilledcrown(false, false);
 //translate([0, 0, -16.5]) cylinder(16.5, body_od, body_od);
//hardware();
 
//crown(true);