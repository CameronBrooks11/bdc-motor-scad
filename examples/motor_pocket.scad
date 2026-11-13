use <../bdc_motor.scad>

// A block with a pocket for the motor: the motor is drawn as one solid, with
// the wiring clearance blocks, and subtracted. The pocket is open at the top.
length = motor_length();
back = motor_back_start_x();
wall = 3;

difference()
{
    translate([ -back - wall, -10 - wall, -motor_body_height() / 2 - wall ])
        cube([ length + back + 2 * wall, 20 + 2 * wall, motor_body_height() / 2 + wall ]);
    hobby_dc_motor(render_axle_separately = false, render_wiring_clearance_blocks = true);
}
