"""Render the motor and the examples, and check sizes, refusals and the mount's fit.

usage: python3 tests/test_bdc_motor.py [OPENSCAD]

- The 130 size motor is 38 x 20 x 16.5 mm: the axle's length, the body's
  width, and the body's 15 mm height plus the 1.5 mm wiring tabs.
- With render_axle_separately the axle is a solid of its own; without it the
  motor is one solid.
- Dimensions that don't fit together are refused with their message.
- Every example renders.
- The mount's base and strap (tests/probe.scad) clear the motor with it moved
  0.1 mm each way across the axle, and hold it: moved 0.3 mm, more than the
  0.2 mm fit, it runs into the base below and the strap above.

No render may print a WARNING or ERROR line, bar the refusals: OpenSCAD exits
0 on a failed assert when something is left to export.
"""

import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOTOR = os.path.join(ROOT, "bdc_motor.scad")
PROBE = os.path.join(ROOT, "tests", "probe.scad")

REFUSED = {
    "an axle shorter than the motor": ("motor_axle_length=20", "is shorter than the motor"),
    "a back slot outside the rear protrusion": ("motor_back_slot_zoff=5", "outside a rear protrusion"),
    "a flat that disagrees with the protrusion": ("motor_back_protrusion_flat_bottom_width=8", "disagrees with"),
}

results = []


def check(label, ok, got):
    results.append(bool(ok))
    print(f"{'ok  ' if ok else 'FAIL'} {label}: {got}")


def render(openscad, src, out, *defines, refusal=False):
    cmd = [openscad, "--hardwarnings", "--export-format", "binstl", "-o", out]
    for d in defines:
        cmd += ["-D", d]
    r = subprocess.run(cmd + [src], capture_output=True, text=True)
    bad = [l for l in r.stderr.splitlines() if l.startswith(("WARNING", "ERROR"))]
    if not refusal and bad:
        check(f"{os.path.relpath(src, ROOT)} {' '.join(defines)} prints no warning", False, bad[0])
    return r, bad


def mesh(path):
    data = open(path, "rb").read()
    (n,) = struct.unpack_from("<I", data, 80)
    return [struct.unpack_from("<9f", data, 84 + i * 50 + 12) for i in range(n)]


def volume(path):
    v = 0.0
    for t in mesh(path):
        a, b, c = t[0:3], t[3:6], t[6:9]
        v += (a[0] * (b[1] * c[2] - b[2] * c[1]) - a[1] * (b[0] * c[2] - b[2] * c[0])
              + a[2] * (b[0] * c[1] - b[1] * c[0])) / 6
    return v


def solids_and_size(path):
    parent = {}

    def find(v):
        while parent[v] != v:
            parent[v] = parent[parent[v]]
            v = parent[v]
        return v

    for t in mesh(path):
        corners = [t[0:3], t[3:6], t[6:9]]
        for c in corners:
            parent.setdefault(c, c)
        root = find(corners[0])
        for c in corners[1:]:
            parent[find(c)] = root
    size = [max(p[i] for p in parent) - min(p[i] for p in parent) for i in range(3)]
    return len({find(v) for v in parent}), size


def main():
    openscad = sys.argv[1] if len(sys.argv) > 1 else "openscad"
    with tempfile.TemporaryDirectory() as tmp:
        stl = os.path.join(tmp, "out.stl")

        r, bad = render(openscad, MOTOR, stl)
        n, size = solids_and_size(stl) if r.returncode == 0 and not bad else (0, [0, 0, 0])
        want = [38, 20, 16.5]
        check("the 130 size motor's size", all(abs(s - w) < 0.01 for s, w in zip(size, want)),
              f"{' x '.join(f'{s:.2f}' for s in size)} mm; want {' x '.join(map(str, want))}")
        check("the axle is a solid of its own", n == 2, f"{n} solids")
        r, bad = render(openscad, MOTOR, stl, "render_axle_separately=false")
        n = solids_and_size(stl)[0] if r.returncode == 0 and not bad else 0
        check("without render_axle_separately the motor is one solid", n == 1, f"{n} solids")

        for name, (define, message) in REFUSED.items():
            r, bad = render(openscad, MOTOR, stl, define, refusal=True)
            refused = any(message in l for l in bad if l.startswith("ERROR"))
            check(f"refuses {name}", refused, "refused" if refused else (bad or [f"exit {r.returncode}"])[0])

        examples = sorted(f for f in os.listdir(os.path.join(ROOT, "examples")) if f.endswith(".scad"))
        for f in examples:
            r, bad = render(openscad, os.path.join(ROOT, "examples", f), stl)
            check(f"examples/{f} renders", r.returncode == 0 and not bad, f"exit {r.returncode}")

        def overlap(part, move):
            r, bad = render(openscad, PROBE, stl, f'CHECK="{part}"', f"MOVE={move}")
            if "top level object is empty" in r.stderr.lower():
                return 0.0
            return volume(stl) if r.returncode == 0 and not bad else float("inf")

        for part in ("base", "strap"):
            moves = ["[0, 0.1, 0]", "[0, -0.1, 0]", "[0, 0, 0.1]", "[0, 0, -0.1]"]
            worst = max(overlap(part, m) for m in moves)
            check(f"the mount's {part} clears the motor moved 0.1 mm each way", worst < 0.001,
                  f"largest overlap {worst:.4f} mm3")
        held = overlap("base", "[0, 0, -0.3]") > 0.001 and overlap("strap", "[0, 0, 0.3]") > 0.001
        check("the mount holds the motor: 0.3 mm down meets the base, 0.3 mm up the strap", held,
              "held" if held else "loose")

    print(f"{sum(results)} of {len(results)} checks passed")


if __name__ == "__main__":
    main()
    sys.exit(0 if results and all(results) else 1)
