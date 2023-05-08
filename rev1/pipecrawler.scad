use <3rd-party/threads-scad/threads.scad>; // https://github.com/rcolyer/threads-scad

pipe_id = 103.6; // Not sure
pipe_od = 110;
pipe_height = 300;

helix_pitch = 20;
wheel_angle = atan2(helix_pitch, PI*pipe_id);

wheel_bearing_with_washers_height = 10;
wheel_bearing_height = 7;
wheel_bearing_od = 22;
wheel_bearing_id = 8;
wheel_bearing_bevel = 0.5;

wheel_od = 25;
wheel_height = 8;

wheel_tight = 2;

bolt_diameter = 4;
bolt_head_diameter = 8;
bolt_head_height = 3.5;

wheel_support_height = 10;
wheel_vertical_clearance = 2;
wheel_horizontal_clearance = 10;
wheel_support_diameter = 13;
wheel_shoulder_diameter = 12;

body_id = 7.8;
body_od = 50;

spring_t = 1;

$fn = 16;

// Pipe
module pipe() {
    /*translate([0, 0, -pipe_height/2])*/
    difference() {
        cylinder(pipe_height, pipe_od/2, pipe_od/2);
        cylinder(pipe_height, pipe_id/2, pipe_id/2);
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

module wheel_support(top = true) {
    if (top) {
        // Bolt head hole and bolt hole
        translate([0, 0, -wheel_vertical_clearance - 1]) cylinder(wheel_vertical_clearance + 1, wheel_shoulder_diameter/2, wheel_shoulder_diameter/2);
    } else {
        // Bolt counterthread
        translate([0, 0, -wheel_support_height - 5]) cylinder(wheel_support_height + 5, wheel_support_diameter/2, wheel_support_diameter/2);
    }
    // Hole inside bearing
    cylinder(wheel_bearing_with_washers_height / 2 + 5, wheel_bearing_id/2, wheel_bearing_id/2);
}

// Sewage pipe
//pipe();

module sector(height, small_r, big_r, angles = [-60, 60], $fn = $fn) {    
    points = [
        for(step = [0:$fn]) [big_r * cos(angles[0] + (angles[1] - angles[0])*step/$fn), big_r * sin(angles[0] + (angles[1] - angles[0])*step/$fn)],
        for(step = [0:$fn]) [small_r * cos(angles[1] + (angles[0] - angles[1])*step/$fn), small_r * sin(angles[1] + (angles[0] - angles[1])*step/$fn)]
    ];
    linear_extrude(height) polygon(points);
}

  
// Spring cylinder
/*difference() {
    translate([0, 0, -wheel_bearing_with_washers_height/2 -wheel_support_height]) cylinder(wheel_support_height - wheel_vertical_clearance, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2);
    translate([0, 0, -wheel_bearing_with_washers_height/2 -wheel_support_height]) cylinder(wheel_support_height - wheel_vertical_clearance, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2 - spring_t, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2 - spring_t);
    for (i = [0:2]) {
        rotate([0, 0, 360/3*i]) translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, 0]) rotate([wheel_angle, 0, 0]) translate([0, 0, -wheel_support_height/2]) cube([wheel_bearing_id, wheel_bearing_id, wheel_support_height + 5], center=true);
    }
}*/

function ease(x, n) = pow(1 - 2*sqrt(x*(1 - x)), n);

function smooth(x) = 0.5 - 0.5*cos(180*x);

module spring(r, t_in, extra_in, t_out, extra_out, height, $fn = $fn) {
    angles = [-45, -7.8];
    n = 4;
    points = [
        for(step = [0:$fn]) [r * cos(angles[0] + (angles[1] - angles[0])*smooth(step/$fn)) + (t_out + extra_out*ease(smooth(step/$fn), n))/cos(angles[0] + (angles[1] - angles[0])*smooth(step/$fn)), r * sin(angles[0] + (angles[1] - angles[0])*smooth(step/$fn))],
        for(step = [0:$fn]) [r * cos(angles[1] + (angles[0] - angles[1])*smooth(step/$fn)) - (t_in + extra_in*ease(smooth(step/$fn), n))/cos(angles[1] + (angles[0] - angles[1])*smooth(step/$fn)), r * sin(angles[1] + (angles[0] - angles[1])*smooth(step/$fn))]
    ];
    linear_extrude(height) polygon(points);
}

module crown(top = false) {
// Wheels and springs
for (i = [0:2]) rotate([0, 0, 360/3*i]) {
    difference() {
        union() {
            // Spring
            for (j = [0: 1]) mirror([0, j, 0]) {
                translate([0, 0, -wheel_bearing_with_washers_height/2 -wheel_support_height]) spring(pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2, spring_t, spring_t, 1, 0, wheel_support_height - wheel_vertical_clearance, $fn=64);
                translate([-wheel_support_diameter, 0, -wheel_bearing_with_washers_height/2 -wheel_support_height]) spring(pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2, 1, 0, spring_t, spring_t, wheel_support_height - wheel_vertical_clearance, $fn=64);
            }
            
            // Spring-to-spring column
            difference() {
                translate([0, 0, -wheel_bearing_with_washers_height/2 -wheel_support_height]) sector(wheel_bearing_with_washers_height/2 +wheel_support_height, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2 - wheel_support_diameter/2*sqrt(2), pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2, [45, 120-45], $fn=32);            
                for (j = [0: 1]) rotate([0, 0, 120*j]) translate([0, 0, (-wheel_bearing_with_washers_height/2 -wheel_support_height)/2]) cube([pipe_id, sqrt(2)*(pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2), wheel_support_height*3], center=true);
            }
            
     translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, 0]) difference() {
        union() {
        rotate([wheel_angle, 0, 0]) {
            // Wheel boltway
            translate([0, 0, -wheel_bearing_with_washers_height/2]) wheel_support();            
        }
        translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height/2 - wheel_vertical_clearance]) cube([wheel_support_diameter+2, wheel_support_diameter, wheel_support_height], center=true); 
        }
        translate([0, 0, -wheel_bearing_with_washers_height/2 -wheel_support_height - 5]) cube([wheel_support_diameter + 5, wheel_support_diameter + 5, 10], center = true);
        translate([0, 0, + 5]) cube([wheel_support_diameter + 5, wheel_support_diameter + 5, 10], center = true);
    }
    }
    translate([0, 0, -wheel_bearing_with_washers_height/2 -wheel_support_height]) {
        sector(wheel_support_height, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2 + 5, [-45, 45], $fn=32);
        translate([-wheel_support_diameter, 0, 0]) sector(wheel_support_height, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2, pipe_id/2 - wheel_od/2 + wheel_tight + wheel_support_diameter/2 - 5, [-45, 45], $fn=32);
        }
    }
}
// Structural parts
for (i = [0:2]) rotate([0, 0, 60 + 360/3*i]) {
    translate([body_id/2, -2, -wheel_bearing_with_washers_height/2 - wheel_support_height]) cube([pipe_id/2 - wheel_od/2 + wheel_tight - body_id/2, 4, wheel_bearing_with_washers_height/2 + wheel_support_height], center = false);
}
    // Center cylinder
    difference() {
        translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height]) cylinder(wheel_bearing_with_washers_height/2 + wheel_support_height, body_od/2, body_od/2);
        translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height]) cylinder(wheel_bearing_with_washers_height/2 + wheel_support_height, body_id/2, body_id/2);
        translate([0, 0, -wheel_bearing_with_washers_height/2 - wheel_support_height]) cylinder(wheel_bearing_with_washers_height/2 + wheel_support_height, body_id/2, body_id/2);
        for (i = [0:2]) rotate([0, 0, 360/3*i]) {
            translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, -wheel_bearing_with_washers_height/2 - wheel_vertical_clearance]) cylinder(wheel_bearing_with_washers_height/2 + wheel_vertical_clearance, wheel_od/2 + wheel_horizontal_clearance, wheel_od/2 + wheel_horizontal_clearance);
        }
    }
 }
 
 
 module drilledcrown(top = false) {
    if (top) {
        // Wheel screws
        ClearanceHole(bolt_head_diameter, bolt_head_height, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_support_height, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_bearing_with_washers_height/2, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])   
         
        ClearanceHole(bolt_head_diameter, bolt_head_height, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_support_height, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_bearing_with_washers_height/2, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])   
         
        ClearanceHole(bolt_head_diameter, bolt_head_height, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_support_height, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_bearing_with_washers_height/2, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])
         
        // Spring connecting column screws
        ClearanceHole(bolt_diameter, wheel_support_height + wheel_bearing_with_washers_height/2, position=[cos(60 + 120*0)*(pipe_id/2 - wheel_od/2.4 + wheel_tight), sin(60 + 120*0)*(pipe_id/2 - wheel_od/2.4 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_support_height + wheel_bearing_with_washers_height/2, position=[cos(60 + 120*1)*(pipe_id/2 - wheel_od/2.4 + wheel_tight), sin(60 + 120*1)*(pipe_id/2 - wheel_od/2.4 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_support_height + wheel_bearing_with_washers_height/2, position=[cos(60 + 120*2)*(pipe_id/2 - wheel_od/2.4 + wheel_tight), sin(60 + 120*2)*(pipe_id/2 - wheel_od/2.4 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
             
        // Body screws
        ClearanceHole(bolt_head_diameter, bolt_head_height, position=[cos(60 + 120*0)*(body_od + body_id)/4, sin(60 + 120*0)*(body_od + body_id)/4,-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height), position=[cos(60 + 120*0)*(body_od + body_id)/4, sin(60 + 120*0)*(body_od + body_id)/4,-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        
        ClearanceHole(bolt_head_diameter, bolt_head_height, position=[cos(60 + 120*1)*(body_od + body_id)/4, sin(60 + 120*1)*(body_od + body_id)/4,-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height), position=[cos(60 + 120*1)*(body_od + body_id)/4, sin(60 + 120*1)*(body_od + body_id)/4,-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        
        ClearanceHole(bolt_head_diameter, bolt_head_height, position=[cos(60 + 120*2)*(body_od + body_id)/4, sin(60 + 120*2)*(body_od + body_id)/4,-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, (wheel_bearing_with_washers_height/2 + wheel_support_height), position=[cos(60 + 120*2)*(body_od + body_id)/4, sin(60 + 120*2)*(body_od + body_id)/4,-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
         
        crown(top);
    } else {
        // Wheel screws
        ScrewHole(bolt_diameter, wheel_support_height, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_bearing_with_washers_height/2, position=[cos(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*0)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])   
         
        ScrewHole(bolt_diameter, wheel_support_height, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_bearing_with_washers_height/2, position=[cos(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*1)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])   
         
        ScrewHole(bolt_diameter, wheel_support_height, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ClearanceHole(bolt_diameter, wheel_bearing_with_washers_height/2, position=[cos(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight), sin(120*2)*(pipe_id/2 - wheel_od/2 + wheel_tight),-wheel_bearing_with_washers_height/2])
         
        // Spring connecting column screws
        ScrewHole(bolt_diameter, wheel_support_height + wheel_bearing_with_washers_height/2, position=[cos(60 + 120*0)*(pipe_id/2 - wheel_od/2.4 + wheel_tight), sin(60 + 120*0)*(pipe_id/2 - wheel_od/2.4 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ScrewHole(bolt_diameter, wheel_support_height + wheel_bearing_with_washers_height/2, position=[cos(60 + 120*1)*(pipe_id/2 - wheel_od/2.4 + wheel_tight), sin(60 + 120*1)*(pipe_id/2 - wheel_od/2.4 + wheel_tight),-(wheel_bearing_with_washers_height/2 + wheel_support_height)])
        ScrewHole(bolt_diameter, wheel_support_height + wheel_bearing_with_washers_height/2, position=[cos(60 + 120*2)*(pipe_id/2 - wheel_od/2.4 + wheel_tight), sin(60 + 120*2)*(pipe_id/2 - wheel_od/2.4 + wheel_tight),-(wheel_bearing_height/2 + wheel_support_height)])
             
        // Body screws
        ScrewHole(bolt_diameter, (wheel_bearing_height/2 + wheel_support_height), position=[cos(60 + 120*0)*(body_od + body_id)/4, sin(60 + 120*0)*(body_od + body_id)/4,-(wheel_bearing_height/2 + wheel_support_height)])        
        ScrewHole(bolt_diameter, (wheel_bearing_height/2 + wheel_support_height), position=[cos(60 + 120*1)*(body_od + body_id)/4, sin(60 + 120*1)*(body_od + body_id)/4,-(wheel_bearing_height/2 + wheel_support_height)])
        ScrewHole(bolt_diameter, (wheel_bearing_height/2 + wheel_support_height), position=[cos(60 + 120*2)*(body_od + body_id)/4, sin(60 + 120*2)*(body_od + body_id)/4,-(wheel_bearing_height/2 + wheel_support_height)])
         
        crown(top);
    }
 }
 
 module hardware() {
     for (i = [0:2]) rotate([0, 0, 360/3*i]) translate([pipe_id/2 - wheel_od/2 + wheel_tight, 0, 0]) rotate([wheel_angle, 0, 0]) translate([0, 0, -wheel_bearing_with_washers_height/2]) wheel();
 }
 
 drilledcrown(false);
 rotate([180, 0, 0]) drilledcrown(true);
 
 hardware();