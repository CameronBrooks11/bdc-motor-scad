# bdc-motor-scad task runner

set dotenv-load := false

# Default: show available recipes
default:
    @just --list

# Everything CI runs, bar the tests
check: fmt-check

# Format the .scad sources with topiary (.topiary/languages.ncl)
fmt:
    git ls-files -z '*.scad' | xargs -0 -r topiary format

# Check the .scad sources are formatted, without changing them
fmt-check:
    git ls-files -z '*.scad' | xargs -0 -r -n1 topiary format --check

# Render the motor and every example, and check its size, its refusals and the mount's fit
test:
    python3 tests/test_bdc_motor.py
