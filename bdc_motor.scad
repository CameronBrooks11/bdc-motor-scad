/*
 * Copyright 2019 Craig Ringer <ringerc@ringerc.id.au>
 * Copyright 2025 Cameron K. Brooks <cbrook49@uwo.ca; cambrooks3393@gmail.com>
 *
 * BSD Licensed
 *
 * A brushed DC hobby motor. The dimensions below are a "130 size" motor and are the defaults of hobby_dc_motor(),
 * which takes any of them as an argument of the same name:
 *
 *   use <bdc_motor.scad>
 *   hobby_dc_motor(motor_body_x = 25, motor_axle_length = 43);
 *
 * Features:
 * - Optionally generates the axle as a separate part, isolated by a tiny sleeve hollow.
 * - Optionally generates masking-out blocks for wiring, useful if subtracting this model from another design.
 *
 * Axle along x axis, protruding driven part of axle is "front", so power connectors etc are "back". The back face
 * of the motor body is at x = 0 and the body proceeds along +X; the rear protrusion and the back of the axle are at
 * negative x.
 */

zFite = $preview ? 0.1 : 0; // z-fighting avoidance for preview

/* [Render Control] */

// Render axle separately from motor body, isolated by a tiny sleeve hollow.
render_axle_separately = true;
// Clearance above body back area for wiring to mark out as a solid for subtractive use.
render_wiring_clearance_blocks = false;
// Opacity of motor body, in percent
body_alpha = 40; // [0:100]
// Opacity of trimmed areas, in percent
trim_alpha = 20; // [0:100]

/* [Body Parameters] */

// Length of motor excluding nylon back housing, the front protrusion and the protrusion from the back housing
motor_body_x = 20;
// Width of motor body (side to side)
motor_body_y = 20;
// Height of motor body before the flats are cut from the top and bottom
motor_body_z = 15;

/* [Front Protrusion] */

// Size of axle bearing/protrusion from front of body
motor_front_protrusion_x = 2;
// Diameter of front protrusion
motor_front_protrusion_diameter = 4.95;

/* [Axle] */

// Diameter of motor axle
motor_axle_diameter = 2;
// Length of axle protruding from back of motor
motor_axle_outset_length_back = 1;
// Length of motor axle
motor_axle_length = 38;

/* [Back Cover] */

// Nylon motor back part
motor_back_x = 5;
motor_back_tabs_z = 1.5;

// Width of flat top area projecting above motor back where wiring connects
motor_back_top_flat_y = 8.5;

// Nylon protrusion from nylon motor back
motor_back_protrusion_x = 2;
motor_back_protrusion_diameter = 10;
motor_back_protrusion_flat_bottom_zoff = 3.5;

// Length of flat area on bottom back protrusion. Checked against the diameter and offset above.
motor_back_protrusion_flat_bottom_width = 6;

// Back side notches
motor_back_side_notch_length_x = 6;
motor_back_side_notch_depth_y = 3;
motor_back_side_notch_height_z = 3;

/* [Back Slot] */

// Z offset to the bottom edge of the slot
motor_back_slot_zoff = 2;
// Height of slot
motor_back_slot_height_z = 1;
// Width of slot
motor_back_slot_width_y = 5.5;
// Depth of slot
motor_back_slot_depth_x = 1;

/* [Wiring Tabs] */

// Width of the clearance cubes
wiring_clearance_y = 4;
// Length of the clearance cubes
wiring_clearance_z = 4;

/* [Hidden] */

// Largest disagreement allowed between a measured dimension and the one derived from the others
measurement_tol = 0.2;

/* Dimensions derived from the others, for files that "use" this one. Each defaults to the 130 size motor. */

// Length of the motor without the axle: rear protrusion, back cover, body and front protrusion
function motor_length(motor_body_x = motor_body_x, motor_back_x = motor_back_x,
                      motor_front_protrusion_x = motor_front_protrusion_x,
                      motor_back_protrusion_x = motor_back_protrusion_x) =
    motor_back_protrusion_x + motor_back_x + motor_body_x + motor_front_protrusion_x;

function motor_axle_length(motor_axle_length = motor_axle_length) = motor_axle_length;
function motor_body_height(motor_body_z = motor_body_z) = motor_body_z;
// The back cover is cut to the same height as the body
function motor_back_height(motor_body_z = motor_body_z) = motor_body_z;
function motor_axle_outset_back(motor_axle_outset_length_back = motor_axle_outset_length_back) =
    motor_axle_outset_length_back;

// Length of axle protruding from the front protrusion
function motor_axle_outset_front(motor_axle_length = motor_axle_length,
                                 motor_axle_outset_length_back = motor_axle_outset_length_back,
                                 motor_body_x = motor_body_x, motor_back_x = motor_back_x,
                                 motor_front_protrusion_x = motor_front_protrusion_x,
                                 motor_back_protrusion_x = motor_back_protrusion_x) =
    motor_axle_length - motor_axle_outset_length_back -
    motor_length(motor_body_x, motor_back_x, motor_front_protrusion_x, motor_back_protrusion_x);

// Distance from the back end of the axle to the back face of the motor body
function motor_back_start_x(motor_axle_outset_length_back = motor_axle_outset_length_back,
                            motor_back_protrusion_x = motor_back_protrusion_x) =
    motor_axle_outset_length_back + motor_back_protrusion_x;

function motor_side_notch_length(motor_back_side_notch_length_x = motor_back_side_notch_length_x) =
    motor_back_side_notch_length_x;

module hobby_dc_motor(
    render_axle_separately = render_axle_separately, render_wiring_clearance_blocks = render_wiring_clearance_blocks,
    body_alpha = body_alpha, trim_alpha = trim_alpha, motor_body_x = motor_body_x, motor_body_y = motor_body_y,
    motor_body_z = motor_body_z, motor_front_protrusion_x = motor_front_protrusion_x,
    motor_front_protrusion_diameter = motor_front_protrusion_diameter, motor_axle_diameter = motor_axle_diameter,
    motor_axle_outset_length_back = motor_axle_outset_length_back, motor_axle_length = motor_axle_length,
    motor_back_x = motor_back_x, motor_back_tabs_z = motor_back_tabs_z, motor_back_top_flat_y = motor_back_top_flat_y,
    motor_back_protrusion_x = motor_back_protrusion_x, motor_back_protrusion_diameter = motor_back_protrusion_diameter,
    motor_back_protrusion_flat_bottom_zoff = motor_back_protrusion_flat_bottom_zoff,
    motor_back_protrusion_flat_bottom_width = motor_back_protrusion_flat_bottom_width,
    motor_back_side_notch_length_x = motor_back_side_notch_length_x,
    motor_back_side_notch_depth_y = motor_back_side_notch_depth_y,
    motor_back_side_notch_height_z = motor_back_side_notch_height_z, motor_back_slot_zoff = motor_back_slot_zoff,
    motor_back_slot_height_z = motor_back_slot_height_z, motor_back_slot_width_y = motor_back_slot_width_y,
    motor_back_slot_depth_x = motor_back_slot_depth_x, wiring_clearance_y = wiring_clearance_y,
    wiring_clearance_z = wiring_clearance_z, measurement_tol = measurement_tol)
{
    // number of fragments for circles, unless the caller has set one
    $fn = $fn > 0 ? $fn : ($preview ? 64 : 128);

    // Height of the clearance cubes, from the front edge of the tabs to the back of the motor
    wiring_clearance_x = motor_back_protrusion_x + motor_back_x;

    clipping_color = "#FF0000";
    motor_axle_color = "#EEEEEE";
    motor_body_color = "#CCCCCC";
    clearance_area_color = "#CC00CC";
    body_opacity = body_alpha / 100;
    trim_opacity = trim_alpha / 100;

    // The axle reaches at least to the end of the front protrusion
    axle_outset_front = motor_axle_outset_front(motor_axle_length, motor_axle_outset_length_back, motor_body_x,
                                                motor_back_x, motor_front_protrusion_x, motor_back_protrusion_x);
    assert(axle_outset_front >= 0,
           str("motor_axle_length ", motor_axle_length, " is shorter than the motor and the back outset: ",
               motor_axle_length - axle_outset_front));

    // The slot lies inside the rear protrusion
    assert(motor_back_slot_zoff + motor_back_slot_height_z <= motor_back_protrusion_diameter / 2,
           str("the back slot ends ", motor_back_slot_zoff + motor_back_slot_height_z,
               " above the axis, outside a rear protrusion of radius ", motor_back_protrusion_diameter / 2));

    // The flat on the bottom of the rear protrusion is as wide as its diameter and offset make it
    flat_bottom_width = 2 * sqrt(pow(motor_back_protrusion_diameter / 2, 2) -
                                 pow(motor_body_z / 2 - motor_back_protrusion_flat_bottom_zoff, 2));
    assert(abs(flat_bottom_width - motor_back_protrusion_flat_bottom_width) <= measurement_tol,
           str("motor_back_protrusion_flat_bottom_width ", motor_back_protrusion_flat_bottom_width,
               " disagrees with the ", flat_bottom_width, " that the protrusion diameter and offset give"));

    module main_body()
    {
        trim_cube_thickness_main = (motor_body_y - motor_body_z) / 2;

        difference()
        {
            // Base motor body (main and back)
            color(motor_body_color, body_opacity) rotate([ 0, 90, 0 ])
                cylinder(d1 = motor_body_y, d2 = motor_body_y, h = motor_body_x + motor_back_x);

            color(clipping_color, trim_opacity) translate([ 0, -motor_body_y / 2, -motor_body_y / 2 ])
            {
                // Clip bottom, whole motor
                translate([ -zFite / 2, 0, 0 ])
                    cube([ motor_body_x + motor_back_x + zFite, motor_body_y, trim_cube_thickness_main ]);

                // Clip top, whole motor. Top back protrusion will be added in later.
                translate([ -zFite / 2, 0, motor_body_z + trim_cube_thickness_main ])
                    cube([ motor_body_x + motor_back_x + zFite, motor_body_y, trim_cube_thickness_main ]);
            };

            // Side back alignment slots/notches
            color(clipping_color, trim_opacity) for (side = [ -1, 1 ])
            {
                // Side notch: rectangular cut
                translate([
                    motor_back_side_notch_length_x / 2 - zFite / 2,
                    side * (-motor_body_y / 2 + motor_back_side_notch_depth_y / 4), 0
                ])
                    cube(
                        [
                            motor_back_side_notch_length_x + zFite, motor_back_side_notch_depth_y / 2,
                            motor_back_side_notch_height_z
                        ],
                        center = true);

                // Side notch: rounded bottom
                translate([
                    -zFite / 2,
                    side * (-motor_body_y / 2 + motor_back_side_notch_height_z - motor_back_side_notch_depth_y / 2), 0
                ]) rotate([ 0, 90, 0 ])
                    cylinder(d1 = motor_back_side_notch_height_z, d2 = motor_back_side_notch_height_z,
                             h = motor_back_side_notch_length_x + zFite);
            }
        }
    }

    module rear_cover()
    {
        difference()
        {
            mask_zoff = motor_body_z / 2 - motor_back_protrusion_flat_bottom_zoff;

            mask_height = motor_body_z / 2 - mask_zoff;
            // Rear protrusion base cylinder
            color(motor_body_color, body_opacity) rotate([ 0, 90, 0 ])
                cylinder(d1 = motor_back_protrusion_diameter, d2 = motor_back_protrusion_diameter,
                         h = motor_back_protrusion_x + zFite);

            // Rear protrusion bottom flat clipping
            color(clipping_color, trim_opacity)
                translate([ -zFite, -motor_back_protrusion_diameter / 2, -mask_zoff - mask_height ])
                    cube([ motor_back_protrusion_x, motor_back_protrusion_diameter, mask_height ], center = false);

            // Rear protrusion mid-top flat slot
            color(clipping_color, trim_opacity) translate([ -zFite, -motor_back_slot_width_y / 2, motor_back_slot_zoff ])
                cube([ motor_back_slot_depth_x + zFite, motor_back_slot_width_y, motor_back_slot_height_z ]);
        };
    }

    module front_protrusion()
    {
        rotate([ 0, 90, 0 ]) cylinder(d1 = motor_front_protrusion_diameter, d2 = motor_front_protrusion_diameter,
                                      h = motor_front_protrusion_x + zFite);
    }

    module axle(cut = false)
    {
        axle_cut_tol = cut ? 0.1 : 0;
        rotate([ 0, 90, 0 ]) cylinder(d = motor_axle_diameter + axle_cut_tol, h = motor_axle_length);
    }

    module wiring_tabs()
    {
        cube([ motor_back_x, motor_back_top_flat_y, motor_back_tabs_z ], center = false);
    }

    module wiring_clearance()
    {
        for (side = [ -1, 1 ])
        {
            translate([
                // Leave extra room behind motor for wires
                motor_axle_outset_length_back,
                //
                -wiring_clearance_y / 2 + side * (motor_back_top_flat_y / 2 + wiring_clearance_y / 2),
                motor_body_z / 2
            ]) cube([ wiring_clearance_x, wiring_clearance_y, wiring_clearance_z ]);
        }
    }

    // Motor body (main and back housing)
    difference()
    {
        union()
        {
            // Rear protrusion
            translate([ -motor_back_protrusion_x, 0, 0 ]) rear_cover();

            // Main motor body
            main_body();

            // Front protrusion/axle bearing
            translate([ motor_body_x + motor_back_x - zFite, 0, 0 ]) color(motor_body_color, body_opacity)
                front_protrusion();

            // Back top protrusion for wiring
            translate([ 0, -motor_back_top_flat_y / 2, motor_body_z / 2 ]) color(motor_body_color, body_opacity)
                wiring_tabs();
        };

        // Subtract axle shaft from whole motor
        if (render_axle_separately)
        {
            translate([ -motor_back_protrusion_x - zFite, 0, 0 ]) color(clipping_color, trim_opacity) axle(cut = true);
        }
    }; // end motor body difference

    // Axle
    color(motor_axle_color, body_opacity) translate([ -motor_axle_outset_length_back - motor_back_protrusion_x, 0, 0 ])
        axle();

    // Clearance area for motor wiring, if requested
    if (render_wiring_clearance_blocks)
    {
        translate([ -motor_axle_outset_length_back - motor_back_protrusion_x, 0, 0 ])
            color(clearance_area_color, body_opacity) wiring_clearance();
    }
};

hobby_dc_motor();
