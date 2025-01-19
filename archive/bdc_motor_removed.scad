// Part that were removed

// Width of flattened part of motor body. Not strictly required since it's determined by motor_body_z; could be used for
// measurement check later.
motor_body_y_flat_top = 13;

$fs = 0.1;
$fa = 4;

/* Expose motor length to "use" includes */
function motor_axle_length() = motor_axle_total_length;
function motor_length() = motor_axle_total_length - motor_back_axle_outset_length - motor_axle_outset_length_front;
function motor_body_height() = motor_body_z;
function motor_back_height() = motor_back_z;
function motor_axle_outset_back() = motor_back_axle_outset_length;
function motor_axle_outset_front() = motor_axle_outset_length_front;
function motor_back_start_x() = motor_back_axle_outset_length + motor_back_protrusion_x;
function motor_side_notch_length() = motor_back_side_notch_length_x;

measurement_tol = 0.2;
motor_axle_cut_diameter = motor_axle_diameter + measurement_tol;

module measurement_check(measure1, description1, measure2, description2, tolerance = measurement_tol)
{
    diff = abs(measure1 - measure2);

    echo(str("measurement_check with tolerance=", tolerance, " ", (diff <= tolerance ? "OK" : "FAILED"),
             " m1=", measure1, ", m2=", measure2, " d=", diff, " (m1: ", description1, ", m2: ", description2, ")"));

    if (diff > tolerance)
    {
    };
    assert(diff <= tolerance);
};

// Slot measurements make sense vs back housing
if (!is_undef(motor_back_slot_zoff_from_top))
{
    measurement_check(motor_back_slot_zoff_from_top + motor_back_slot_zoff_from_bottom + motor_back_slot_height_z,
                      "back slot measurements", motor_back_z, "back total height");
}

// Axle length adds up with protrusions and lengths of parts. Measurement addition order is order of parts in motor
// along x axis.
measurement_check(motor_axle_outset_length_front + motor_front_protrusion_x + motor_body_x + motor_back_x +
                      motor_back_protrusion_x + motor_back_axle_outset_length,
                  "sum of measurements along x axis", motor_axle_total_length, "total axle length");

// Does flat bottom region make sense given zoff?
if (!is_undef(motor_back_protrusion_flat_bottom_width))
{
    measurement_check(
        // Compute length of bottom flat area by deriving from
        // protrusion radius (tangent) and distance of flat bottom
        // from origin along y axis
        sqrt(pow(motor_back_protrusion_diameter / 2, 2) -
             pow(motor_body_z / 2 - motor_back_protrusion_flat_bottom_zoff_from_bottom, 2)) *
            2,
        "bottom flat area width computed from back projection bottom back area height above motor base",
        motor_back_protrusion_flat_bottom_width, "back projection bottom flat area width");
}

module main_body()
{
    difference()
    {
        //...

        // Small side front notch
        translate([
            -zFite + motor_body_x + motor_back_x - motor_front_side_notch_x_offset,
            side * (-motor_body_y / 2 + motor_front_side_notch_y / 4),
            -motor_front_side_notch_z / 2 + motor_back_side_notch_height_z / 2
        ]) cube([ motor_front_side_notch_x + zFite, motor_front_side_notch_y / 2, motor_front_side_notch_z ],
                center = true);
    }
}