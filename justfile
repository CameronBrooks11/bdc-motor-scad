# bdc-motor-scad task runner

set dotenv-load := false

# Default: show available recipes
default:
    @just --list

# Render the library and every example, failing on any OpenSCAD warning
test:
    @for f in bdc_motor.scad examples/*.scad; do echo "render $f"; log=$(openscad --hardwarnings --export-format binstl -o - "$f" 2>&1 >/dev/null) || { echo "$log"; exit 1; }; done
