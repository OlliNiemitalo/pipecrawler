// From: https://www.thingiverse.com/thing:5977915

bearing_height = 7;
bearing_od = 22;
bearing_id = 8; // Not used
bearing_bevel = 0.5;

wheel_od = 25;
wheel_profile_r = 8;
wheel_lip_height = 0.5;
wheel_lip_width = 1; 

$fn=128;

// Bearing
module bearing_cutout() {
    translate([0, 0, -wheel_lip_height]) cylinder(wheel_lip_height, bearing_od/2 - wheel_lip_width, bearing_od/2 - wheel_lip_width);
    cylinder(bearing_bevel, bearing_od/2 - bearing_bevel, bearing_od/2);
    translate([0, 0, bearing_bevel]) cylinder(bearing_height - 2*bearing_bevel, bearing_od/2, bearing_od/2);
    translate([0, 0, bearing_height - bearing_bevel]) cylinder(bearing_bevel, bearing_od/2, bearing_od/2 - bearing_bevel);
    translate([0, 0, bearing_height]) cylinder(wheel_lip_height, bearing_od/2 - wheel_lip_width, bearing_od/2 - wheel_lip_width);
}

module wheel_profile(height,wheel_r, r, $fn = $fn/8) {   
    if (r*sqrt(2)/2 > height) {
        angles = [-asin(height/r), asin(height/r)];
        points = [[0, -height],
            for(step = [0:$fn]) 
                [wheel_r - r + r * cos(angles[0] + (angles[1] - angles[0])*step/$fn), r * sin(angles[0] + (angles[1] - angles[0])*step/$fn)], [0, height]
        ];
        polygon(points);
    } else {
        angles = [-45, 45];
        points = [[0, -height], [wheel_r - r + sqrt(2)*r - height, -height],
        for(step = [0:$fn]) 
                [wheel_r - r + r * cos(angles[0] + (angles[1] - angles[0])*step/$fn), r * sin(angles[0] + (angles[1] - angles[0])*step/$fn)],   
        [wheel_r - r + sqrt(2)*r - height, height], [0, height]];
        polygon(points);
    }
}

module wheel() {
    translate([0, 0, bearing_height/2]) {
        rotate_extrude(angle=360, $fn=$fn) wheel_profile(bearing_height/2 + wheel_lip_height, wheel_od/2, wheel_profile_r);
    }
}

difference() {
    wheel();
    bearing_cutout();    
}