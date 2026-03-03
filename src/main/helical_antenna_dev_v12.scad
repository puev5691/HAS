//====================================================
// PARAMETRIC HELICAL ANTENNA GENERATOR + FULL 3D-PRINT MODEL
// DEVELOPMENT VERSION v12
//====================================================
//
// Author (concept, antenna design):
// Serzhant Svistofliagov
//
// Programming and parametric logic:
// Updated with assistance of ChatGPT (OpenAI, GPT-5.2)
//
// Year: 2026
//====================================================
//
// Notes (important):
// - This is a CAD/print generator. RF performance depends on materials, winding accuracy,
//   ground plane conductivity, soldering, and connector choice.
// - The "matching triangle" here is a practical starting geometry (tunable). Expect to tweak
//   dimensions for best SWR in your real build.
//
//====================================================


/* [0. Экспорт STL] */
export_part = "assembly"; // [assembly,tube_single,tube_section,reflector_and_mount,reflector_only,mount_only,matching_triangle,debug_wire_path]
export_mode = "preview";  // [preview,single,sequence]
export_section = 0;       // used for tube_section


/* [1. Диапазон частоты] */
band = "1200"; // [350,450,550,650,750,850,950,1050,1200,1400,1600,1800,2000,2200,2400,2600,2800,3000,3200,3400,3600,3800,4000,4200,4400,4600,4800,5000,5200,5400,5600,5800,6000]
manual_frequency = 1200;  // MHz, used when band not listed


/* [2. Усиление антенны] */
target_gain = 12;         // dBi (used only as a guide for turns)


/* [3. Поляризация и направление намотки] */
polarization = "RHCP";    // [RHCP,LHCP]
/*
RHCP is the common choice for FPV/quadcopter antennas.
If your drone uses LHCP, switch to LHCP.
*/


/* [4. Шаг витков] */
pitch_mode = "Стандарт"; // [Компактный,Стандарт,Четверть волны,Ручной]
pitch_manual = 0.25;     // fraction of lambda


/* [5. Диаметр проволоки] */
wire_profile = "Стандарт"; // [Тонкий,Стандарт,Широкополосный,Ручной]
wire_manual = 2.5;         // mm, used when profile=Ручной


/* [6. Режим прочности корпуса] */
structure_mode = "Стандарт"; // [Лёгкий,Стандарт,Усиленный]


/* [7. Корпус трубы (канавка под витки)] */
wall_mode = "Авто";         // [Авто,Ручной]
wall_manual = 3;            // mm
groove_clearance = 0.6;     // mm extra for the wire to sit nicely
base_thickness = 6;         // mm (tube bottom thickness above reflector)

/* [8. Секции трубы] */
enable_sections = true;
max_section_height = 180;   // mm

/* [9. Рефлектор] */
enable_reflector = true;
reflector_mode = "Авто";    // [Авто,Ручной]
reflector_d_manual = 120;   // mm
reflector_thickness = 2.6;  // mm (printable + stiff enough)
reflector_edge_margin = 8;  // mm margin outside mount feet

/* [10. Разъём SMA (bulkhead, female)] */
enable_sma = true;
sma_hole_d = 6.6;           // mm (typical SMA bulkhead needs ~6.4-6.5; give a hair for print)
sma_flat = 0.0;             // mm (0 = round hole; set ~1.0-1.5 if you want anti-rotation flats)
sma_center_offset = 0;      // mm, move connector along X if you want (0 = centered)

/* [11. Согласующий треугольник (дельта-матч)] */
enable_matching_triangle = true;
match_mode = "Авто";        // [Авто,Ручной]
match_base_manual = 12;     // mm (base on reflector)
match_height_manual = 16;   // mm (up towards first turn)
match_strip_width_manual = 3; // mm (copper strip / printed channel width)
match_gap_to_tube = 1.2;    // mm air gap from tube surface (for solder & clearance)

/* [12. Крепление (площадка + лапы + кольцо под трубу + стеновой кронштейн)] */
enable_mount = true;
mount_plate_thickness = 5;     // mm
mount_ring_height = 10;        // mm
mount_ring_wall = 3;           // mm
mount_fit_clearance = 0.35;    // mm (tube-to-ring fit)
mount_leg_count = 4;           // number of legs that tie to reflector
mount_leg_width = 14;          // mm
mount_leg_length = 22;         // mm (radial)
mount_leg_hole_d = 3.4;        // mm (self-tapping / M3-ish)

wall_tab_count = 4;
wall_tab_width = 16;           // mm
wall_tab_length = 22;          // mm
wall_tab_hole_d = 4.2;         // mm (wood screw-ish)
wall_tab_hole_offset = 7;      // mm from tab end

/* [13. Сквозной стягивающий саморез (ось)] */
enable_center_screw = true;
center_screw_d = 3.4;          // mm (self-tapping / M3)
center_screw_head_d = 7.0;     // mm (simple counterbore)
center_screw_head_h = 2.2;     // mm

/* [14. Качество рендера] */
render_quality = "Стандарт"; // [Быстрый,Стандарт]
$fn = render_quality == "Быстрый" ? 24 : 64;


//====================================================
// ЧАСТОТА
//====================================================
frequency =
    band == "350"  ? 350  :
    band == "450"  ? 450  :
    band == "550"  ? 550  :
    band == "650"  ? 650  :
    band == "750"  ? 750  :
    band == "850"  ? 850  :
    band == "950"  ? 950  :
    band == "1050" ? 1050 :
    band == "1200" ? 1200 :
    band == "1400" ? 1400 :
    band == "1600" ? 1600 :
    band == "1800" ? 1800 :
    band == "2000" ? 2000 :
    band == "2200" ? 2200 :
    band == "2400" ? 2400 :
    band == "2600" ? 2600 :
    band == "2800" ? 2800 :
    manual_frequency;

lambda = 300000 / frequency; // mm (c in mm/us; f in MHz)


//====================================================
// ДИАМЕТР ПРОВОДА
//====================================================
wire_factor =
    wire_profile == "Тонкий" ? 0.01 :
    wire_profile == "Стандарт" ? 0.02 :
    wire_profile == "Широкополосный" ? 0.03 :
    0.02;

wire_d =
    wire_profile == "Ручной" ?
    wire_manual :
    lambda * wire_factor;


//====================================================
// ШАГ
//====================================================
pitch_factor =
    pitch_mode == "Компактный" ? 0.18 :
    pitch_mode == "Стандарт" ? 0.23 :
    pitch_mode == "Четверть волны" ? 0.25 :
    pitch_manual;

spacing = lambda * pitch_factor;


//====================================================
// ВИТКИ (приближенно)
//====================================================
turns_calc = pow(10, (target_gain - 5.4)/10);
turns = min(14, max(5.5, turns_calc));


//====================================================
// ГЕОМЕТРИЯ СПИРАЛИ И ТРУБЫ
//====================================================
// Axial-mode default: circumference ~ lambda
circumference = lambda;
radius = circumference / (2 * PI);
height = spacing * turns;

groove_depth = wire_d * 0.55;
groove_d = wire_d + groove_clearance;

min_wall = groove_depth + 1.5;
wave_wall = lambda * 0.015;

structure_factor =
    structure_mode == "Лёгкий" ? 0.8 :
    structure_mode == "Стандарт" ? 1.0 :
    structure_mode == "Усиленный" ? 1.4 :
    1.0;

auto_wall = max(min_wall, wave_wall) * structure_factor;

wall =
    wall_mode == "Ручной" ?
    wall_manual :
    auto_wall;

tube_inner_r = radius;
tube_outer_r = radius + wall;
tube_height = height + base_thickness;


//====================================================
// СЕКЦИИ
//====================================================
section_count = enable_sections ?
    ceil(tube_height / max_section_height) : 1;

section_height = tube_height / section_count;


//====================================================
// РЕФЛЕКТОР (ground plane)
//====================================================
reflector_d_auto = max((circumference / PI) * 1.1, lambda * 0.8) + 2*reflector_edge_margin;
reflector_d =
    reflector_mode == "Ручной" ? reflector_d_manual : reflector_d_auto;
reflector_r = reflector_d/2;


//====================================================
// MATCHING TRIANGLE (delta match) – стартовые значения
//====================================================
// Practical initial guesses (tunable):
match_base_auto  = max(8, lambda * 0.08);
match_height_auto = max(10, lambda * 0.11);
match_strip_w_auto = max(wire_d*1.1, 2.2);

match_base =
    match_mode == "Ручной" ? match_base_manual : match_base_auto;
match_height =
    match_mode == "Ручной" ? match_height_manual : match_height_auto;
match_strip_w =
    match_mode == "Ручной" ? match_strip_width_manual : match_strip_w_auto;


//====================================================
// ВЫВОД
//====================================================
echo("---- v12 FULL MODEL ----");
echo("Частота (МГц) =", frequency);
echo("Поляризация =", polarization);
echo("Витков =", turns);
echo("Диаметр провода (мм) =", wire_d);
echo("Шаг (мм) =", spacing);
echo("Труба: внутр.радиус =", tube_inner_r, "наруж.радиус =", tube_outer_r, "высота =", tube_height);
echo("Рефлектор D (мм) =", reflector_d, "толщина =", reflector_thickness);
echo("Дельта-матч: base =", match_base, "height =", match_height, "strip_w =", match_strip_w);


//====================================================
// УТИЛИТЫ
//====================================================
function sgn(x) = x < 0 ? -1 : (x > 0 ? 1 : 0);

module counterbore_hole(d_through, d_head, h_head, h_total) {
    // through + simple head pocket from the top face
    union() {
        cylinder(h=h_total, d=d_through);
        translate([0,0,h_total-h_head]) cylinder(h=h_head+0.01, d=d_head);
    }
}


//====================================================
// КАНАВКА СПИРАЛИ (как в v11, но с направлением)
//====================================================
module helix_groove() {

    steps = turns * (render_quality == "Быстрый" ? 10 : 24);

    // Groove path radius slightly outside tube outer radius, so subtraction makes a channel
    groove_path_r = tube_outer_r + groove_depth - 0.2;

    // RHCP/LHCP: we flip the angular direction
    dir = (polarization == "RHCP") ? -1 : 1;

    for (i = [0:steps-1]) {

        z1 = height * i/steps;
        z2 = height * (i+1)/steps;

        a1 = dir * (z1/height * turns * 360);
        a2 = dir * (z2/height * turns * 360);

        p1 = [groove_path_r*cos(a1), groove_path_r*sin(a1), z1];
        p2 = [groove_path_r*cos(a2), groove_path_r*sin(a2), z2];

        hull() {
            translate(p1) sphere(d=groove_d, $fn=10);
            translate(p2) sphere(d=groove_d, $fn=10);
        }
    }
}


//====================================================
// ТРУБА (цельная)
//====================================================
module tube_solid() {
    difference() {
        // outer shell
        cylinder(h=tube_height, r=tube_outer_r);

        // inner bore
        translate([0,0,-1]) cylinder(h=tube_height+2, r=tube_inner_r);

        // helix groove
        helix_groove();

        // socket for mount ring (so tube "sits" onto ring)
        if (enable_mount) {
            socket_r = (tube_inner_r + mount_ring_wall) + mount_fit_clearance;
            translate([0,0,-0.01])
                cylinder(h=mount_ring_height + 0.6, r=socket_r);
        }

        // center screw clearance through tube bottom
        if (enable_center_screw) {
            translate([0,0,-1])
                cylinder(h=base_thickness+2, d=center_screw_d);
        }
    }
}


//====================================================
// СЕКЦИЯ ТРУБЫ (как в v11, но с нижним сокетом)
//====================================================
module tube_section(i) {

    z0 = i * section_height;
    z1 = z0 + section_height;

    // Stitching ring for section-to-section
    ring_length = max(10, section_height * 0.10);
    ring_outer = tube_inner_r;
    ring_inner = tube_inner_r - wall;

    union() {

        // section body
        intersection() {
            tube_solid();
            translate([0,0,z0]) cylinder(h=section_height, r=tube_outer_r+2);
        }

        // internal connector ring (male) on upper side (except last)
        if (i < section_count-1) difference() {
            translate([0,0,z1 - ring_length/2])
                cylinder(h=ring_length, r=ring_outer);
            translate([0,0,z1 - ring_length/2 -1])
                cylinder(h=ring_length+2, r=ring_inner);
        }
    }
}


//====================================================
// РЕФЛЕКТОР (диск с отверстиями под лапы, SMA, центр-винт)
//====================================================
module reflector_disk() {
    difference() {
        cylinder(h=reflector_thickness, r=reflector_r);

        // center screw
        if (enable_center_screw)
            translate([0,0,-1]) cylinder(h=reflector_thickness+2, d=center_screw_d);

        // SMA hole (bulkhead)
        if (enable_sma) {
            translate([sma_center_offset,0,-1]) cylinder(h=reflector_thickness+2, d=sma_hole_d);

            // optional flats (very simple: subtract two cubes)
            if (sma_flat > 0) {
                translate([sma_center_offset,0,reflector_thickness/2])
                    rotate([0,0,0])
                        cube([sma_hole_d, sma_flat, reflector_thickness+4], center=true);
                translate([sma_center_offset,0,reflector_thickness/2])
                    rotate([0,0,90])
                        cube([sma_hole_d, sma_flat, reflector_thickness+4], center=true);
            }
        }

        // leg holes
        if (enable_mount) {
            for (k=[0:mount_leg_count-1]) {
                ang = 360*k/mount_leg_count;
                rpos = (tube_outer_r + mount_leg_length*0.65);
                x = rpos*cos(ang);
                y = rpos*sin(ang);
                translate([x,y,-1]) cylinder(h=reflector_thickness+2, d=mount_leg_hole_d);
            }
        }
    }
}


//====================================================
// КРЕПЛЕНИЕ: площадка + кольцо + лапы + стеновые выступы
//====================================================
module mount_block() {

    // Base plate radius: just enough for ring + legs + wall tabs
    base_r = max(tube_outer_r + mount_leg_length + wall_tab_length, reflector_r - 1);

    ring_inner_r = tube_inner_r + mount_fit_clearance; // tube inner slides over ring outer, but we use tube socket; ring should fit tube bore
    ring_outer_r = ring_inner_r + mount_ring_wall;

    difference() {
        union() {
            // main plate
            cylinder(h=mount_plate_thickness, r=base_r);

            // ring (spigot) upwards
            translate([0,0,mount_plate_thickness])
                difference() {
                    cylinder(h=mount_ring_height, r=ring_outer_r);
                    translate([0,0,-1]) cylinder(h=mount_ring_height+2, r=ring_inner_r);
                }

            // legs to reflector (flat tabs)
            for (k=[0:mount_leg_count-1]) {
                ang = 360*k/mount_leg_count;
                rotate([0,0,ang])
                    translate([tube_outer_r + 2, -mount_leg_width/2, 0])
                        cube([mount_leg_length, mount_leg_width, mount_plate_thickness], center=false);
            }

            // wall mounting tabs (extend out a bit)
            for (k=[0:wall_tab_count-1]) {
                ang = 360*k/wall_tab_count + 45; // offset so they don't overlap legs perfectly
                rotate([0,0,ang])
                    translate([base_r - wall_tab_length, -wall_tab_width/2, 0])
                        cube([wall_tab_length, wall_tab_width, mount_plate_thickness], center=false);
            }
        }

        // center screw counterbore (from below, so head sits flush against wall side)
        if (enable_center_screw) {
            translate([0,0,-0.01])
                counterbore_hole(center_screw_d, center_screw_head_d, center_screw_head_h, mount_plate_thickness + mount_ring_height + 0.02);
        }

        // leg holes
        for (k=[0:mount_leg_count-1]) {
            ang = 360*k/mount_leg_count;
            rpos = (tube_outer_r + mount_leg_length*0.65);
            x = rpos*cos(ang);
            y = rpos*sin(ang);
            translate([x,y,-1]) cylinder(h=mount_plate_thickness+2, d=mount_leg_hole_d);
        }

        // wall tab holes
        for (k=[0:wall_tab_count-1]) {
            ang = 360*k/wall_tab_count + 45;
            rotate([0,0,ang])
                translate([base_r - wall_tab_hole_offset, 0, -1])
                    cylinder(h=mount_plate_thickness+2, d=wall_tab_hole_d);
        }
    }
}


//====================================================
// СОГЛАСУЮЩИЙ ТРЕУГОЛЬНИК (дельта-матч) – как ПАЗ/ШАБЛОН
//====================================================
// This creates a *printable guide/channel* for placing a copper strip/triangle.
// You can also export it as a standalone "template" to cut copper.
module matching_triangle_template() {
    // We place triangle near SMA hole, with one vertex at SMA center, another toward tube.
    // Simple planar strip at reflector top face.
    z = reflector_thickness; // sits on top of reflector

    // anchor points (2D in XY)
    p0 = [sma_center_offset, 0];                       // SMA center
    p1 = [sma_center_offset + match_base, 0];          // along +X
    // "up" towards tube: aim at tube outer surface, with a small gap
    p2 = [tube_outer_r + match_gap_to_tube, match_height]; // a bit to the right of tube surface, up in +Y

    // Make a thickened triangle strip by offsetting with hulls of cylinders
    union() {
        // three edges
        edge(p0, p1, z);
        edge(p1, p2, z);
        edge(p2, p0, z);
        // small pads at vertices
        translate([p0[0],p0[1],z]) cylinder(h=match_strip_w, d=match_strip_w*1.6);
        translate([p1[0],p1[1],z]) cylinder(h=match_strip_w, d=match_strip_w*1.6);
        translate([p2[0],p2[1],z]) cylinder(h=match_strip_w, d=match_strip_w*1.6);
    }
}

module edge(a, b, z0) {
    hull() {
        translate([a[0],a[1],z0]) cylinder(h=match_strip_w, d=match_strip_w);
        translate([b[0],b[1],z0]) cylinder(h=match_strip_w, d=match_strip_w);
    }
}


//====================================================
// СБОРКА
//====================================================
module reflector_and_mount() {
    union() {
        if (enable_mount) mount_block();
        if (enable_reflector)
            // reflector sits above mount plate (mount is wall-side), so reflector is on top of it
            translate([0,0,enable_mount ? mount_plate_thickness : 0])
                reflector_disk();

        if (enable_matching_triangle && enable_reflector)
            translate([0,0,(enable_mount ? mount_plate_thickness : 0)])
                matching_triangle_template();
    }
}

module full_assembly() {
    union() {
        // base
        reflector_and_mount();

        // tube sits on top of reflector
        translate([0,0,(enable_mount ? mount_plate_thickness : 0) + (enable_reflector ? reflector_thickness : 0)])
            if (enable_sections) {
                for (i=[0:section_count-1]) tube_section(i);
            } else {
                tube_solid();
            }
    }
}


//====================================================
// РЕНДЕР / ЭКСПОРТ
//====================================================
if (export_part == "assembly") {
    full_assembly();
}
else if (export_part == "tube_single") {
    // whole tube, no section split
    tube_solid();
}
else if (export_part == "tube_section") {
    tube_section(export_section);
}
else if (export_part == "reflector_and_mount") {
    reflector_and_mount();
}
else if (export_part == "reflector_only") {
    reflector_disk();
}
else if (export_part == "mount_only") {
    mount_block();
}
else if (export_part == "matching_triangle") {
    matching_triangle_template();
}
else if (export_part == "debug_wire_path") {
    // Visual helper: show the helix path as a thick tube (NOT printable as-is)
    steps = turns * (render_quality == "Быстрый" ? 10 : 24);
    groove_path_r = tube_outer_r + groove_depth - 0.2;
    dir = (polarization == "RHCP") ? -1 : 1;
    for (i = [0:steps-1]) {
        z1 = height * i/steps;
        z2 = height * (i+1)/steps;
        a1 = dir * (z1/height * turns * 360);
        a2 = dir * (z2/height * turns * 360);
        p1 = [groove_path_r*cos(a1), groove_path_r*sin(a1), z1];
        p2 = [groove_path_r*cos(a2), groove_path_r*sin(a2), z2];
        hull() {
            translate(p1) sphere(d=wire_d, $fn=16);
            translate(p2) sphere(d=wire_d, $fn=16);
        }
    }
}
