// constants/measurements

$fn = 32;

pi3_width = 85;
pi3_height = 56;

pi3_ether_inset = 37;
pi3_ether_height = 14;
pi3_ether_width = 16.5;
pi3_usb_width = 16;
pi3_usb_height = 17;
pi3_usb1_inset = 1;
pi3_usb2_inset = 18.5;
pi3_sd_width = 16;
pi3_sd_inset = 20;
pi3_sd_height = 3;
pi3_audio_inset = 28;
pi3_audio_width = 7.5;
pi3_audio_height = 7;
pi3_hdmi_inset = 45;
pi3_hdmi_width = 17;
pi3_hdmi_height = 7;
pi3_power_inset = 69;
pi3_power_width = 12;
pi3_power_height = 7;

pi3_standoff_x1 = 23.5;
pi3_standoff_x2 = 81.5;
pi3_standoff_y1 = 3.5;
pi3_standoff_y2 = 52.5;

standoff_width = 5;
standoff_height = 20;
standoff_inset = 1;

switch_well_width = 14;
switch_well_depth = 6;
switch_footprint_depth = 7;
switch_footprint_width = 20;

top_angle = 10; // degrees
plate_upset = standoff_height;
case_underlap = 3;
breathing_room = 2;
wall_thickness = 1.5;
outer_radius = 5;
//cutout_radius = 1;
bevel = 5;

rows = 2;
cols = 4;

// actual output

//translate([0, 0, plate_upset]) rotate([top_angle, 0, 0])
    switchplate();
//pi_housing();

// modules

module rounded_rect(w, h, r) {
    minkowski() {
        circle(r);
        translate([r,r,0]) square([w-2*r, h-2*r]);
    }
}

module pi_housing() {
    housing_width = pi3_width + 2*(breathing_room + wall_thickness);
    housing_height = pi3_height + 2*(breathing_room + wall_thickness);
    housing_depth = case_underlap + plate_upset + housing_height*sin(top_angle);
    
    ct = (breathing_room + wall_thickness) * 3; // cutout_thickness
    ch = ct / 2; // cutout_thickness_half
    
    difference() {
        // base
        translate([0, 0, -case_underlap])
            linear_extrude(0, 0, housing_depth)
                rounded_rect(housing_width, housing_height, outer_radius);
        // chop off the top
        translate([0, 0, plate_upset])
            rotate([top_angle, 0, 0])
                linear_extrude(0, 0, housing_width)
                    square(housing_width);
        // cut out the inside
        translate([wall_thickness, wall_thickness, -case_underlap])
            linear_extrude(0, 0, housing_width)
                rounded_rect(housing_width - 2*wall_thickness, housing_height - 2*wall_thickness, outer_radius - wall_thickness);
        // cutouts for side access
        translate([wall_thickness + breathing_room, wall_thickness + breathing_room, 0]) union() {
            // ethernet + usb (left side)
            translate([-ch, pi3_usb1_inset, 0])
                linear_extrude(0, 0, pi3_usb_height)
                    square([ct, pi3_usb_width]);
            translate([-ch, pi3_usb2_inset, 0])
                linear_extrude(0, 0, pi3_usb_height)
                    square([ct, pi3_usb_width]);
            translate([-ch, pi3_ether_inset, 0])
                linear_extrude(0, 0, pi3_ether_height)
                    square([ct, pi3_ether_width]);
            // audio + hdmi + power (top side)
            translate([0, pi3_height - ch, 0]) union() {
                translate([pi3_audio_inset, 0, 0])
                    linear_extrude(0, 0, pi3_audio_height)
                        square([pi3_audio_width, ct]);
                translate([pi3_hdmi_inset, 0, 0])
                    linear_extrude(0, 0, pi3_hdmi_height)
                        square([pi3_hdmi_width, ct]);
                translate([pi3_power_inset, 0, -case_underlap])
                    linear_extrude(0, 0, pi3_power_height)
                        square([pi3_power_width, ct]);
            }
            // sd (right side)
            translate([pi3_width - ch, pi3_sd_inset, -case_underlap])
                linear_extrude(0, 0, pi3_sd_height)
                    square([ct, pi3_sd_width]);
        }
    }
    
    // internal standoffs
    translate([wall_thickness + breathing_room, wall_thickness, 0])
        linear_extrude(0, 0, standoff_height) union() {
            translate([pi3_standoff_x1 - standoff_width/2, pi3_standoff_y1 - standoff_width/2 - standoff_inset, 0]) square([standoff_width, standoff_width + standoff_inset + breathing_room]);
            translate([pi3_standoff_x2 - standoff_width/2, pi3_standoff_y1 - standoff_width/2 - standoff_inset, 0]) square([standoff_width + standoff_inset + breathing_room, standoff_width + standoff_inset + breathing_room]);
            translate([pi3_standoff_x2 - standoff_width/2, pi3_standoff_y2 - standoff_width/2 + breathing_room, 0]) square([standoff_width + standoff_inset + breathing_room, standoff_width + standoff_inset + breathing_room]);
            translate([pi3_standoff_x1 - standoff_width/2, pi3_standoff_y2 - standoff_width/2 + breathing_room, 0]) square([standoff_width, standoff_width + standoff_inset + breathing_room]);
        }
}

module switchplate() {
    plate_width = pi3_width + 2*(breathing_room + wall_thickness);
    plate_height = (pi3_height + 2*(breathing_room + wall_thickness)) / cos(top_angle);
    plate_thickness = bevel*2;
    
    difference () {
        hull() {
            linear_extrude(0, 0, 0.5)
                rounded_rect(plate_width, plate_height, outer_radius);
            translate([bevel, bevel, plate_thickness])
                linear_extrude(0, 0, 0.1)
                    rounded_rect(plate_width - 2*bevel, plate_height - 2*bevel, outer_radius);
        }
        translate([
                (plate_width -(cols * switch_footprint_width))/2,
                (plate_height-(rows * switch_footprint_width))/2,
            0]) union() {
            for (x = [0:1:cols-1]) {
                for (y = [0:1:rows-1]) {
                    linear_extrude(0, 0, plate_thickness + 1)
                        translate([
                                x*switch_footprint_width + (switch_footprint_width - switch_well_width)/2,
                                y*switch_footprint_width + (switch_footprint_width - switch_well_width)/2,
                            0])
                            square(switch_well_width);
                }
            }
            translate([0,0,plate_thickness - switch_footprint_depth])
                linear_extrude(0, 0, switch_footprint_depth+1)
                    square([cols * switch_footprint_width, rows * switch_footprint_width]);
        }
    }
}
























