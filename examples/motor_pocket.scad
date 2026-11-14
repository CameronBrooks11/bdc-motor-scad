// A block with a pocket for the motor, open at the top.
// The motor is drawn as one solid, with the wiring clearance blocks, and subtracted.
use <../bdc_motor.scad>

// Wall around the pocket (mm)
wall = 3; // [1:0.5:10]

length = motor_length();
back = motor_back_start_x();
width = motor_body_width();

difference()
{
    translate([ -back - wall, -width / 2 - wall, -motor_body_height() / 2 - wall ])
        cube([ length + back + 2 * wall, width + 2 * wall, motor_body_height() / 2 + wall ]);
    hobby_dc_motor(render_axle_separately = false, render_wiring_clearance_blocks = true);
}
