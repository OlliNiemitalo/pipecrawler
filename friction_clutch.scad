module shifted_sector(h, orb, ort, sxb, sxt, syb, syt, angle0, angle1, $fn=$fn) {
    outer_bottom = 0;
    outer_top = $fn+1;
    inner_bottom = ($fn+1)*2;
    inner_top = ($fn+1)*2+1;
    points = [
        // Bottom outer
        for (i = [0:$fn]) [sxb+orb*cos(angle0+i*(angle1-angle0)/$fn), syb+orb*sin(angle0+i*(angle1-angle0)/$fn), 0],
        // Top outer
        for (i = [0:$fn]) [sxt+ort*cos(angle0+i*(angle1-angle0)/$fn), syt+ort*sin(angle0+i*(angle1-angle0)/$fn), h],
        // Bottom inner
        [sxb, syb, 0],
        // Top inner
        [sxt, syt, h]
    ];
    faces = [
        // Outer arc
        for (i = [0:$fn-1]) [outer_bottom + i + 1, outer_bottom + i, outer_top + i, outer_top + i + 1],
        // Top
        for (i = [0:$fn-1]) [inner_top, outer_top + i + 1, outer_top + i],
        // Bottom
        for (i = [0:$fn-1]) [outer_bottom + i, outer_bottom + i + 1, inner_bottom],
        // Start cap
        [outer_bottom, inner_bottom, inner_top, outer_top],
        // End cap
        [inner_bottom, outer_bottom + $fn, outer_top + $fn, inner_top]
    ];
    polyhedron(points=points, faces=faces);
}


module shifted_arc(h, orb, ort, irb, irt, sxb, sxt, syb, syt, angle0, angle1, $fn=$fn) {
    inner_bottom = 0;
    outer_bottom = $fn+1;
    inner_top = ($fn+1)*2;
    outer_top = ($fn+1)*3;
    angles = (angle1 == angle0 + 360)? concat([for (i = [0:$fn - 1]) angle0+i*(angle1-angle0)/$fn], [angle0]): [for (i = [0:$fn]) angle0+i*(angle1-angle0)/$fn];
    points = [
        // Bottom inner
        for (i = [0:$fn]) [sxb+irb*cos(angles[i]), syb+irb*sin(angles[i]), 0],
        // Bottom outer
        for (i = [0:$fn]) [sxb+orb*cos(angles[i]), syb+orb*sin(angles[i]), 0],
        // Top inner
        for (i = [0:$fn]) [sxt+irt*cos(angles[i]), syt+irt*sin(angles[i]), h],
        // Top outer
        for (i = [0:$fn]) [sxt+ort*cos(angles[i]), syt+ort*sin(angles[i]), h]
    ];
    faces = [
        // Inner arc
        for (i = [0:$fn-1]) [inner_bottom + i, inner_bottom + i + 1, inner_top + i + 1, inner_top + i],
        // Outer arc
        for (i = [0:$fn-1]) [outer_bottom + i + 1, outer_bottom + i, outer_top + i, outer_top + i + 1],
        // Top
        for (i = [0:$fn-1]) [inner_top + i, inner_top + i + 1, outer_top + i + 1, outer_top + i],
        // Bottom
        for (i = [0:$fn-1]) [outer_bottom + i, outer_bottom + i + 1, inner_bottom + i + 1, inner_bottom + i],
    ];
    caps = (angle1 == angle0+360)?[]: [
        // Start cap
        [outer_bottom, inner_bottom, inner_top, outer_top],
        // End cap
        [inner_bottom + $fn, outer_bottom + $fn, outer_top + $fn, inner_top + $fn]
    ];
    polyhedron(points=points, faces=concat(faces, caps));
}

module friction_clutch_sub(height, shaft_diam, tol, tight, t, gap, thin_b, thin_t) {
    // Tightened hole half
    difference() {
        shifted_sector(h=height, orb=shaft_diam/2+(thin_b?0:tol)+thin_b, ort=shaft_diam/2+(thin_t?0:tol)+thin_t, sxb=thin_b?0:-tight, sxt=thin_t?0:-tight, syb=0, syt=0, angle0=-90, angle1=90, $fn=32);
        translate([-tight, -(shaft_diam/2+tol+1), 0]) cube([tight, shaft_diam+tol*2+2, height], center=false);
    }
    // Slot for spring
    difference() {
        shifted_arc(h=height, orb=shaft_diam/2+t+gap+t+gap, ort=shaft_diam/2+t+gap+t+gap, irb=shaft_diam/2+t+gap+t, irt=shaft_diam/2+t+gap+t, sxb=0, sxt=0, syb=0, syt=0, angle0=-90, angle1=90, $fn=32);
        // Bridge
        if (thin_b == 0) translate([shaft_diam/2+t+gap+t-1, -t/2, 0]) cube([gap+2, t, height],center=false);
    }
    // Slot Between spring and cup
    difference() {
        shifted_arc(h=height, orb=shaft_diam/2+t+gap+thin_b, ort=shaft_diam/2+t+gap+thin_t, irb=shaft_diam/2+t, irt=shaft_diam/2+t, sxb=0, sxt=0, syb=0, syt=0, angle0=-90, angle1=90, $fn=32);
        // Bridge
        if (thin_b == 0) translate([0, -(shaft_diam/2+t+gap+1), 0]) cube([gap+1, 2*(shaft_diam/2+t+gap+1), height], center=false);
    }
    // Center slot
    translate([0, -(shaft_diam/2+t+gap+t+gap/2), 0]) cube([gap, 2*(shaft_diam/2+t+gap+t+gap/2), height], center=false);
}

module friction_clutch(height, shaft_diam, tol, tight, t, gap, support_h, support_t) {
    // Nominal hole half
    translate([1/4096, 0, 0]) shifted_sector(h=height, orb=shaft_diam/2+tol, ort=shaft_diam/2+tol, sxb=0, sxt=0, syb=0, syt=0, angle0=90, angle1=270, $fn=32);
    // Spring mechanism
    translate([0, 0, support_h]) friction_clutch_sub(height-support_h, shaft_diam, tol, tight, t, gap, 0, 0);
    // Spring mechanism support
    friction_clutch_sub(support_h - (tight+t-support_t) + 1/4096, shaft_diam, tol, tight, t, gap, t-support_t, t-support_t);
    translate([0, 0, support_h - (tight+t-support_t)]) friction_clutch_sub(tight+t-support_t + 1/4096, shaft_diam, tol, tight, t, gap, t-support_t, 0);
}