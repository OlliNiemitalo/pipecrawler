use <3rd-party/threads-scad/threads.scad>; // https://github.com/rcolyer/threads-scad

pipe_id = 114.5;
pipe_od = 120;

sealant_hole_diam = 5;
bottom_plug_inner_height = 9;
bottom_plug_plate_height = 2;
channel1_y = 2;
//channel2_y = 8;
channel_h = 5;
channel_t = 1;

difference() {
union() {

cylinder(bottom_plug_plate_height/2, pipe_od/2 - bottom_plug_plate_height/4, pipe_od/2, $fn=256);
translate([0, 0, bottom_plug_plate_height/2]) cylinder(bottom_plug_plate_height/2, pipe_od/2, pipe_od/2, $fn=256);

translate([0, 0, bottom_plug_plate_height]) cylinder(channel1_y, pipe_id/2, pipe_id/2, $fn=256);

// Channel 1
translate([0, 0, bottom_plug_plate_height + channel1_y]) cylinder(channel_t*2, pipe_id/2, pipe_id/2 - channel_t, $fn=256);
translate([0, 0, bottom_plug_plate_height + channel1_y + channel_t*2]) cylinder(channel_h - channel_t*4, pipe_id/2 - channel_t, pipe_id/2 - channel_t, $fn=256);
translate([0, 0, bottom_plug_plate_height + channel1_y + channel_h - channel_t*2]) cylinder(channel_t*2, pipe_id/2 - channel_t, pipe_id/2, $fn=256);

/*
// Between channels
translate([0, 0, bottom_plug_plate_height + channel1_y + channel_h]) cylinder(channel2_y - channel_h - channel1_y, pipe_id/2, pipe_id/2, $fn=256);

// Channel 2
translate([0, 0, bottom_plug_plate_height + channel2_y]) cylinder(channel_t*2, pipe_id/2, pipe_id/2 - channel_t, $fn=256);
translate([0, 0, bottom_plug_plate_height + channel2_y + channel_t*2]) cylinder(channel_h - channel_t*4, pipe_id/2 - channel_t, pipe_id/2 - channel_t, $fn=256);
translate([0, 0, bottom_plug_plate_height + channel2_y + channel_h - channel_t*2]) cylinder(channel_t*2, pipe_id/2 - channel_t, pipe_id/2, $fn=256);
*/

// Above channels
translate([0, 0, bottom_plug_plate_height + channel1_y + channel_h]) cylinder(bottom_plug_inner_height - (channel1_y + channel_h) - 1, pipe_id/2, pipe_id/2, $fn=256);
translate([0, 0, bottom_plug_plate_height + bottom_plug_inner_height - 1]) cylinder(1, pipe_id/2, pipe_id/2 - 1, $fn=256);
}

translate([pipe_id/2 - 10, 0, 0]) cylinder(channel1_y + channel_h - channel_t, sealant_hole_diam/2, sealant_hole_diam/2, $fn=64);
translate([pipe_id/2 - 10, -sealant_hole_diam/2, channel1_y + channel_h - channel_t]) cube([10, sealant_hole_diam, channel_h - channel_t*4], center=false);
translate([pipe_id/2 - 10 + 1, 0, bottom_plug_plate_height + channel1_y + channel_h/2]) translate([9.687, 0, 0]) multmatrix([[0.75, 0, 0, 0], [0, 1, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]) rotate([0, 45, 0]) cube([4, sealant_hole_diam, 4], center=true);

}