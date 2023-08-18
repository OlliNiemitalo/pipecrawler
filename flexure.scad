function ease(x, n) = pow(1 - 2*sqrt(x*(1 - x)), n);

function smooth(x) = 0.5 - 0.5*cos(180*x);

// spiral flexure
module spiral_flexure(radii, angles, t_angles, t_in, extra_in_start, extra_in_end, t_out, extra_out_start, extra_out_end, n, spring_n = $fn) {    
    points = [
        for(step = [0:spring_n]) [
            (radii[0] + (radii[1] - radii[0])*smooth(step/spring_n)) * cos(angles[0] + (angles[1] - angles[0])*smooth(step/spring_n)) + 
            (t_out + (step < spring_n/2? extra_out_start : extra_out_end)*ease(smooth(step/spring_n), n)) * cos(t_angles[0] + (t_angles[1] - t_angles[0])*smooth(step/spring_n)) / cos(t_angles[0]-angles[0] + (t_angles[1] - angles[1] - t_angles[0] + angles[0])*smooth(step/spring_n)),
            (radii[0] + (radii[1] - radii[0])*smooth(step/spring_n)) * sin(angles[0] + (angles[1] - angles[0])*smooth(step/spring_n)) +
            (t_out + (step < spring_n/2? extra_out_start : extra_out_end)*ease(smooth(step/spring_n), n)) * sin(t_angles[0] + (t_angles[1] - t_angles[0])*smooth(step/spring_n)) / cos(t_angles[0]-angles[0] + (t_angles[1]-angles[1] - t_angles[0]+angles[0])*smooth(step/spring_n))
        ],
        for(step = [0:spring_n]) [
            (radii[1] + (radii[0] - radii[1])*smooth(step/spring_n)) * cos(angles[1] + (angles[0] - angles[1])*smooth(step/spring_n)) -
            (t_in + (step < spring_n/2?extra_in_start : extra_in_end)*ease(smooth(step/spring_n), n)) * cos(t_angles[1] + (t_angles[0] - t_angles[1])*smooth(step/spring_n)) / cos(t_angles[1]-angles[1] + (t_angles[0]-angles[0] - t_angles[1]+angles[1])*smooth(step/spring_n)),
            (radii[1] + (radii[0] - radii[1])*smooth(step/spring_n)) * sin(angles[1] + (angles[0] - angles[1])*smooth(step/spring_n)) -
            (t_in + (step < spring_n/2?extra_in_start : extra_in_end)*ease(smooth(step/spring_n), n)) * sin(t_angles[1] + (t_angles[0] - t_angles[1])*smooth(step/spring_n)) / cos(t_angles[1]-angles[1] + (t_angles[0]-angles[0] - t_angles[1]+angles[1])*smooth(step/spring_n))
        ]
    ];
    polygon(points);
}
