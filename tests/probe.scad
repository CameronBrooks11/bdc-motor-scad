// Fit checks for examples/motor_mount.scad, chosen by CHECK: the mount's base or strap against
// the motor moved by MOVE from where it sits. Each renders an intersection that is empty while the
// motor is clear of the part.
use <../bdc_motor.scad>
use <../examples/motor_mount.scad>

CHECK = "base";
MOVE = [0, 0, 0];

intersection() {
    if (CHECK == "base") base(); else strap();
    translate(MOVE) hobby_dc_motor();
}
