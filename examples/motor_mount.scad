// A printable mount: a base with a cradle, and a strap over the can.
// Four holes through the base screw it to whatever the motor drives; the strap's two screws go into
// pilot holes in the base. Sizes come from the library's functions, so another motor needs no new
// numbers.
use <../bdc_motor.scad>

/* [Mount] */
// Floor and end walls of the base (mm)
wall = 3; // [1.5:0.5:8]
// Gap between the motor and the cradle and strap, per side (mm)
fit = 0.2; // [0:0.05:0.6]
// Width of the strap along the motor (mm)
strap_width = 6; // [3:0.5:15]
// Thickness of the strap (mm)
strap_thickness = 2.5; // [1.2:0.1:5]
// Screw diameter, for the strap and the base's mounting holes (mm)
screw = 3; // [2:0.5:5]

/* [View] */
// The parts laid out for printing, or put together on the motor
view = "print"; // [print, assembled]

/* [Hidden] */
$fn = 48;
back = motor_back_start_x();
half_w = motor_body_width() / 2 + fit;
half_h = motor_body_height() / 2 + fit;
can = motor_can_x();
strap_x = (can[0] + can[1]) / 2;
// The strap's screws, either side of the motor
screw_y = half_w + strap_thickness + screw;
base_half_y = screw_y + screw + 1;
base_x = [ -back - wall, motor_length() + wall ];
// The base's mounting holes, near its ends
mount_xs = [ base_x[0] + screw + 1, base_x[1] - screw - 1 ];

assert(can[0] + strap_width / 2 < strap_x && strap_x + strap_width / 2 < can[1], "the strap is wider than the can");

// The motor as a cutter, with the wiring clearance, grown by `fit` in y and z. render() makes it one
// mesh: as nine CSG copies it grows OpenSCAD's preview tree past its limit, and preview draws nothing.
module envelope() render() {
  for (dy = [ -fit, 0, fit ], dz = [ -fit, 0, fit ])
    translate([ 0, dy, dz ]) hobby_dc_motor(render_axle_separately = false, render_wiring_clearance_blocks = true);
}

// The base: the lower half of a block around the motor, open at the axis.
module base() {
  difference() {
    translate([ base_x[0], -base_half_y, -half_h - wall ])
      cube([ base_x[1] - base_x[0], 2 * base_half_y, half_h + wall ]);
    envelope();
    // Pilot holes for the strap's screws
    for (s = [ -1, 1 ]) translate([ strap_x, s * screw_y, -half_h ]) cylinder(d = 0.8 * screw, h = half_h + 1);
    // Mounting holes, through
    for (x = mount_xs, s = [ -1, 1 ])
      translate([ x, s * screw_y, -half_h - wall - 1 ]) cylinder(d = screw + 0.4, h = half_h + wall + 2);
  }
}

// The strap: an arch over the can, with a flange each side for its screw. It stands on the base at z = 0.
module strap() {
  difference() {
    translate([ strap_x - strap_width / 2, 0, 0 ]) rotate([ 90, 0, 90 ]) linear_extrude(strap_width) difference() {
      union() {
        translate([ -half_w - strap_thickness, 0 ]) square([ 2 * (half_w + strap_thickness), half_h + strap_thickness ]);
        translate([ -base_half_y, 0 ]) square([ 2 * base_half_y, strap_thickness ]);
      }
      translate([ -half_w, -1 ]) square([ 2 * half_w, half_h + 1 ]);
    }
    envelope();
    for (s = [ -1, 1 ]) translate([ strap_x, s * screw_y, -1 ]) cylinder(d = screw + 0.4, h = strap_thickness + 2);
  }
}

if (view == "print") {
  translate([ 0, 0, half_h + wall ]) base();
  translate([ 0, 2 * base_half_y + 5, 0 ]) strap();
} else if (view == "assembled") {
  base();
  strap();
  hobby_dc_motor();
}
