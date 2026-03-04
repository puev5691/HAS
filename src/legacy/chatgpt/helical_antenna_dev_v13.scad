//====================================================
// Parametric Helical Antenna PRINTABLE HARDWARE (NO HELIX GEOMETRY)
// DEVELOPMENT VERSION v13
//====================================================
// Goal: 3D-printable mechanical parts for building an axial-mode helical antenna:
// - Winding tube (with optional shallow guide groove only; NO printed helix)
// - Reflector drilling / cutting template (optional)
// - Two-part mount: (A) tube plate with spigot ring + standoffs, (B) wall/plane mount block with 4 lugs
// - SMA flange-mount footprint (square flange) on reflector side
// - Optional delta-match bending jig (prints a simple jig; the delta match itself is copper wire)
//
// Units: millimeters
//====================================================

/* [Quick Export] */
export_part = "assembly"; // [assembly,tube,tube_section,plate,wall_mount,reflector_template,delta_jig]

/* [RF Inputs] */
freq_mhz = 5800;          // Operating frequency (MHz)
target_gain_dbi = 12;     // Used only to size the tube length (no helix rendered)
polarization = "RHCP";    // [RHCP,LHCP] (winding direction reference)

/* [Helix Geometry (for tube sizing only)] */
circumference_factor = 1.00;  // C ≈ 1.0*λ (axial-mode start)
pitch_factor = 0.25;          // S ≈ 0.25*λ (axial-mode start)
min_turns = 5.5;
max_turns = 14;

/* [Wire + Delta Match] */
wire_d = 1.2;                 // Copper-alloy wire diameter (mm)
wire_material = "CuAlloy";    // [CuAlloy,Brass,Al] (loss differences; geometry dominates match)
delta_mode = "auto";          // [auto,manual]
delta_base_manual = 0;        // mm (0 = ignore)
delta_height_manual = 0;      // mm (0 = ignore)
delta_tap_manual = 0;         // mm from grounded end along one side (0 = ignore)

/* [Tube] */
tube_wall = 2.0;              // mm
tube_clearance = 0.25;        // mm (fit onto spigot ring)
tube_groove_enable = true;    // shallow guide groove only
tube_groove_depth = 0.5;      // mm (indent depth into the tube)
tube_groove_width = 1.2;      // mm
tube_sections = 3;            // number of printable tube segments
tube_section_gap = 0.25;      // mm gap between segments (assembly tolerance)
export_section = 0;           // which tube section to export when export_part="tube_section"

/* [Plate (Part A)] */
plate_thickness = 4.0;        // mm
plate_od_extra = 14;          // mm extra beyond reflector for strength
spigot_height = 6.0;          // mm
standoff_count = 4;
standoff_d = 10.0;            // mm (outer)
standoff_h = 6.0;             // mm (above plate)
clamp_screw_d = 3.2;          // mm clearance for M3 (change if you use another size)
clamp_screw_head_d = 6.4;     // optional counterbore
clamp_screw_head_h = 2.4;

/* [Wall Mount (Part B)] */
wall_block_thickness = 5.0;   // mm (your request)
wall_block_xy = 28;           // mm square-ish base size
lug_length = 10;              // mm
lug_width = 10;               // mm
lug_hole_d = 5.0;             // mm (your request)
lug_pair_gap = 10;            // mm gap between the two lugs on the same side

/* [Reflector Template] */
reflector_mode = "auto";      // [auto,manual]
reflector_d_manual = 120;     // mm if manual
reflector_thickness_template = 1.0;  // mm (template only; real reflector can be metal sheet)

/* [SMA Flange-Mount Footprint] */
// Your SMA: square flange ~12.6mm, corner holes spacing ~8mm (center-to-center)
sma_flange_side = 12.6;       // mm
sma_hole_spacing = 8.0;       // mm (center-to-center)
sma_flange_hole_d = 2.4;      // mm (adjust to your screws)
sma_center_hole_d = 6.6;      // mm (body clearance)
sma_offset_r = 0;             // mm radial offset from center (0 = centered)

/* [Render Quality] */
$fn = 96;

//====================================================
// Derived values
//====================================================
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Speed of light (mm/s)
c_mm_s = 299792458000;
freq_hz = freq_mhz * 1e6;
lambda_mm = c_mm_s / freq_hz;

// Axial-mode starting values (tube sizing only)
circ_mm = lambda_mm * circumference_factor;
tube_od = circ_mm / PI;
pitch_mm = lambda_mm * pitch_factor;

// Tube length sizing by gain rule-of-thumb
turns_raw = pow(10, (target_gain_dbi - 5.4)/10);
turns = clamp(turns_raw, min_turns, max_turns);
tube_len = turns * pitch_mm;

// Reflector diameter (auto start)
reflector_d_auto = lambda_mm * 0.85;
reflector_d = (reflector_mode == "manual") ? reflector_d_manual : reflector_d_auto;

// Plate OD: slightly larger than reflector
plate_od = reflector_d + plate_od_extra;

// Spigot geometry: tube slips OVER spigot
tube_id = tube_od - 2*tube_wall;
spigot_od = tube_id - 2*tube_clearance;
spigot_id = max(0.1, spigot_od - 2.4);

// Standoff circle radius
standoff_r = (reflector_d/2) * 0.72;

//====================================================
// Delta-match "auto" starting geometry
//====================================================
// Starting point (empirical): base ~0.18λ, height ~0.10λ, tap ~45% of height.
// Material mostly affects loss (Q); geometry dominates match.
// Expect tuning in the real build.
mat_k = (wire_material == "Brass") ? 0.995 : (wire_material == "Al") ? 0.990 : 1.000;
wd_k = 1.0 - clamp((wire_d - 1.0) * 0.002, -0.02, 0.02);

delta_base_auto = lambda_mm * 0.18 * mat_k * wd_k;
delta_height_auto = lambda_mm * 0.10 * mat_k * wd_k;
delta_tap_auto = delta_height_auto * 0.45;

delta_base = (delta_mode == "manual" && delta_base_manual > 0) ? delta_base_manual : delta_base_auto;
delta_height = (delta_mode == "manual" && delta_height_manual > 0) ? delta_height_manual : delta_height_auto;
delta_tap = (delta_mode == "manual" && delta_tap_manual > 0) ? delta_tap_manual : delta_tap_auto;

// Print computed values in OpenSCAD console
echo("==== Helical Antenna v13 (mechanical parts only) ====");
echo("freq_mhz=", freq_mhz, " lambda_mm=", lambda_mm);
echo("tube_od(mm)=", tube_od, " tube_len(mm)=", tube_len, " pitch(mm)=", pitch_mm, " turns=", turns);
echo("reflector_d(mm)=", reflector_d);
echo("Delta-match (start) base(mm)=", delta_base, " height(mm)=", delta_height, " tap(mm)=", delta_tap);
echo("Polarization=", polarization);

//====================================================
// Modules
//====================================================

module drill_hole(d, h, cbore_d=0, cbore_h=0) {
    cylinder(d=d, h=h, center=false);
    if (cbore_d > 0 && cbore_h > 0)
        translate([0,0,h-cbore_h]) cylinder(d=cbore_d, h=cbore_h, center=false);
}

module sma_flange_holes(th) {
    for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*sma_hole_spacing/2, sy*sma_hole_spacing/2, 0])
            cylinder(d=sma_flange_hole_d, h=th, center=false);
    }
}

module sma_center_hole(th) {
    cylinder(d=sma_center_hole_d, h=th, center=false);
}

module plate_part() {
    // Part A: plate + spigot + standoffs
    difference() {
        union() {
            cylinder(d=plate_od, h=plate_thickness);

            translate([0,0,plate_thickness])
                difference() {
                    cylinder(d=spigot_od + 4.0, h=spigot_height);
                    translate([0,0,-0.01]) cylinder(d=spigot_od, h=spigot_height+0.02);
                }

            for (i=[0:standoff_count-1]) {
                ang = 360*i/standoff_count;
                translate([standoff_r*cos(ang), standoff_r*sin(ang), plate_thickness])
                    cylinder(d=standoff_d, h=standoff_h);
            }
        }

        // Central clamp screw
        translate([0,0,-0.01])
            cylinder(d=clamp_screw_d, h=plate_thickness+spigot_height+standoff_h+0.02);

        // Clamp holes in standoffs
        for (i=[0:standoff_count-1]) {
            ang = 360*i/standoff_count;
            translate([standoff_r*cos(ang), standoff_r*sin(ang), -0.01])
                drill_hole(clamp_screw_d, plate_thickness+standoff_h+0.02, clamp_screw_head_d, clamp_screw_head_h);
        }

        // Tube inner clearance
        translate([0,0,plate_thickness-0.01])
            cylinder(d=tube_id + 2.0, h=spigot_height+standoff_h+0.02);
    }
}

module wall_mount_part() {
    // Part B: wall/plane mount block with 4 lugs (Ø5 holes) + clamp holes aligned to standoffs
    difference() {
        union() {
            translate([-wall_block_xy/2, -wall_block_xy/2, 0])
                cube([wall_block_xy, wall_block_xy, wall_block_thickness]);

            // Two lugs on +Y side
            for (k=[-1,1]) {
                translate([k*(lug_pair_gap/2), wall_block_xy/2, 0])
                    translate([-lug_width/2, 0, 0])
                        cube([lug_width, lug_length, wall_block_thickness]);
            }
            // Two lugs on -Y side
            for (k=[-1,1]) {
                translate([k*(lug_pair_gap/2), -wall_block_xy/2 - lug_length, 0])
                    translate([-lug_width/2, 0, 0])
                        cube([lug_width, lug_length, wall_block_thickness]);
            }
        }

        // Four Ø5 through-holes in lugs
        for (side=[1,-1]) for (k=[-1,1]) {
            y0 = (side==1) ? (wall_block_xy/2 + lug_length/2) : (-wall_block_xy/2 - lug_length/2);
            translate([k*(lug_pair_gap/2), y0, -0.01])
                cylinder(d=lug_hole_d, h=wall_block_thickness+0.02);
        }

        // Clamp-screw clearance holes aligned with plate standoffs
        for (i=[0:standoff_count-1]) {
            ang = 360*i/standoff_count;
            translate([standoff_r*cos(ang), standoff_r*sin(ang), -0.01])
                cylinder(d=clamp_screw_d, h=wall_block_thickness+0.02);
        }

        // Central clamp screw
        translate([0,0,-0.01])
            cylinder(d=clamp_screw_d, h=wall_block_thickness+0.02);
    }
}

module reflector_template() {
    // Optional: printable drilling/cutting template for your metal reflector.
    difference() {
        cylinder(d=reflector_d, h=reflector_thickness_template);

        // Clamp holes
        for (i=[0:standoff_count-1]) {
            ang = 360*i/standoff_count;
            translate([standoff_r*cos(ang), standoff_r*sin(ang), -0.01])
                cylinder(d=clamp_screw_d, h=reflector_thickness_template+0.02);
        }

        // Central clamp hole
        translate([0,0,-0.01]) cylinder(d=clamp_screw_d, h=reflector_thickness_template+0.02);

        // SMA footprint
        translate([sma_offset_r,0,-0.01]) {
            sma_center_hole(reflector_thickness_template+0.02);
            sma_flange_holes(reflector_thickness_template+0.02);
        }
    }
}

module tube_single() {
    // Tube with optional shallow helical guide groove (NO printed helix solid)
    difference() {
        // Outer tube
        cylinder(d=tube_od, h=tube_len);

        // Inner bore
        translate([0,0,-0.01]) cylinder(d=tube_id, h=tube_len+0.02);

        // Shallow guide groove cutter (biting only tube_groove_depth)
        if (tube_groove_enable) {
            steps = max(240, ceil(tube_len/1.0));
            r_cut = tube_od/2 - tube_groove_depth/2;
            for (i=[0:steps-1]) {
                t0 = i/steps;
                t1 = (i+1)/steps;
                z0 = t0*tube_len;
                z1 = t1*tube_len;
                a0 = 360*turns*t0 * ((polarization=="RHCP") ? 1 : -1);
                a1 = 360*turns*t1 * ((polarization=="RHCP") ? 1 : -1);

                hull() {
                    translate([r_cut*cos(a0), r_cut*sin(a0), z0])
                        sphere(d=tube_groove_width);
                    translate([r_cut*cos(a1), r_cut*sin(a1), z1])
                        sphere(d=tube_groove_width);
                }
            }
        }
    }
}

module tube_section(idx=0) {
    seg_len = (tube_len - (tube_sections-1)*tube_section_gap) / tube_sections;
    z0 = idx*(seg_len + tube_section_gap);

    // Move section to origin for export convenience
    translate([0,0,-z0])
        intersection() {
            tube_single();
            translate([-tube_od, -tube_od, z0])
                cube([2*tube_od, 2*tube_od, seg_len]);
        }
}

module delta_match_jig() {
    // A flat jig to bend the delta-match wire to the computed triangle.
    base_th = 4;
    peg_h = 8;
    peg_d = max(wire_d*2.2, 3.5);

    pA = [0, 0];                 // grounded end
    pB = [delta_base, 0];        // helix end (on first turn)
    pC = [0, delta_height];      // apex
    pT = [0, delta_tap];         // tap point on A->C

    pad = 10;
    w = delta_base + pad*2;
    h = delta_height + pad*2;

    translate([-pad, -pad, 0]) cube([w, h, base_th]);

    for (p=[pA,pB,pC,pT]) {
        translate([p[0], p[1], base_th])
            cylinder(d=peg_d, h=peg_h);
    }
}

module assembly() {
    // Stack view (bottom -> top): wall_mount -> reflector template (hover) -> plate -> tube
    wall_mount_part();

    // template hovering for reference
    translate([0,0,wall_block_thickness + 0.2])
        reflector_template();

    translate([0,0,wall_block_thickness + 0.2 + reflector_thickness_template + 0.2])
        plate_part();

    translate([0,0,wall_block_thickness + 0.2 + reflector_thickness_template + 0.2 + plate_thickness])
        tube_single();
}

//====================================================
// Main switch
//====================================================
if (export_part == "assembly") {
    assembly();
} else if (export_part == "tube") {
    tube_single();
} else if (export_part == "tube_section") {
    tube_section(export_section);
} else if (export_part == "plate") {
    plate_part();
} else if (export_part == "wall_mount") {
    wall_mount_part();
} else if (export_part == "reflector_template") {
    reflector_template();
} else if (export_part == "delta_jig") {
    delta_match_jig();
} else {
    assembly();
}
