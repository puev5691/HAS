// Helical Antenna Parametric Generator
// Проект: промышленный параметрический генератор осевой геликальной антенны
// Автор идеи: Сержант Свистофлягов
// Соавтор архитектуры: ChatGPT (OpenAI GPT-5.2)

////////////////////////////
// ПАРАМЕТРЫ ПРОЕКТА
////////////////////////////

/* [Режим вывода] */
mode = "assembly"; // [assembly, section, hub, reflector, bracket]
section_index = 0;  // Индекс секции для mode="section"

/* [Радиопараметры] */
f_mhz = 5800;
gain_dbi = 12;

/* [Параметры шага] */
pitch_mode = "standard"; // [compact, standard, quarter, manual]
pitch_factor_manual = 0.23;

/* [Параметры проводника] */
wire_mode = "medium"; // [thin, medium, thick, manual]
wire_k_manual = 0.02;

/* [Механика/печать] */
groove_depth = 1.2;
structure_factor = 1.0;
max_section_height = 180;
ring_min_length = 10;
ring_ratio = 0.10;

/* [Рефлектор и узел SMA] */
reflector_thickness = 2.4;
sma_center_hole_d = 6.5;
sma_mount_hole_d = 3.2;
sma_mount_spacing = 14;
sma_offset_extra = 8;

/* [Кронштейн] */
bracket_size_factor = 0.50;
bracket_thickness_factor = 2.0;
bracket_mount_hole_d = 4.2;
bracket_mount_offset = 16;

/* [Качество аппроксимации] */
segments_per_turn = 42;
$fn = 96;

////////////////////////////
// РАСЧЁТНЫЕ ВЕЛИЧИНЫ
////////////////////////////

pitch_factor =
    pitch_mode == "compact" ? 0.18 :
    pitch_mode == "standard" ? 0.23 :
    pitch_mode == "quarter" ? 0.25 :
    pitch_factor_manual;

wire_k =
    wire_mode == "thin" ? 0.01 :
    wire_mode == "medium" ? 0.02 :
    wire_mode == "thick" ? 0.03 :
    wire_k_manual;

lambda_mm = 300000 / f_mhz;
helix_d = lambda_mm / PI;
helix_r = helix_d / 2;
spacing = lambda_mm * pitch_factor;
turns = max(5.5, pow(10, (gain_dbi - 5.4) / 10));
helix_h = turns * spacing;

wire_d = lambda_mm * wire_k;
rod_length = sqrt(pow(PI * helix_d, 2) + pow(spacing, 2)) * turns;

wall_base = max(groove_depth + 1.5, 0.015 * lambda_mm);
wall = wall_base * structure_factor;

body_inner_r = helix_r;
body_outer_r = body_inner_r + wall;
body_h = helix_h + wall;

section_count = max(1, ceil(body_h / max_section_height));
section_h = body_h / section_count;
ring_length = max(ring_min_length, section_h * ring_ratio);

hub_h = 4 * wall;
hub_ring_length = ring_length;

reflector_d = 0.75 * lambda_mm;
sma_offset = body_outer_r + sma_offset_extra;

triangle_base = 0.25 * lambda_mm;
triangle_height = 0.17 * lambda_mm;

bracket_size = reflector_d * bracket_size_factor;
bracket_t = reflector_thickness * bracket_thickness_factor;

assert(f_mhz > 0, "f_mhz должно быть > 0");
assert(max_section_height > 0, "max_section_height должно быть > 0");
assert(wall > groove_depth, "wall должен быть больше groove_depth");
assert(section_index >= 0 && section_index < section_count, "section_index вне диапазона");

// Вывод ключевых размеров (по ТЗ)
echo("lambda_mm", lambda_mm);
echo("helix_diameter_mm", helix_d);
echo("turns", turns);
echo("rod_length_mm", rod_length);
echo("rod_diameter_mm", wire_d);
echo("triangle_base_mm", triangle_base);
echo("triangle_height_mm", triangle_height);
echo("reflector_diameter_mm", reflector_d);

////////////////////////////
// СЛУЖЕБНЫЕ МОДУЛИ
////////////////////////////

module ring_shell(outer_r, inner_r, h) {
    difference() {
        cylinder(h = h, r = outer_r);
        translate([0, 0, -0.1]) cylinder(h = h + 0.2, r = inner_r);
    }
}

module full_helix() {
    // Спираль как непрерывная аппроксимация через hull() сфер.
    // Для производственной версии можно заменить на linear_extrude(twist).
    steps = max(1, ceil(turns * segments_per_turn));
    for (k = [0 : steps - 1]) {
        t1 = k / steps;
        t2 = (k + 1) / steps;

        a1 = 360 * turns * t1;
        a2 = 360 * turns * t2;

        z1 = helix_h * t1;
        z2 = helix_h * t2;

        p1 = [(body_outer_r - groove_depth) * cos(a1), (body_outer_r - groove_depth) * sin(a1), z1];
        p2 = [(body_outer_r - groove_depth) * cos(a2), (body_outer_r - groove_depth) * sin(a2), z2];

        hull() {
            translate(p1) sphere(d = wire_d);
            translate(p2) sphere(d = wire_d);
        }
    }
}

module body_section(i) {
    z0 = i * section_h;

    difference() {
        union() {
            // Основная труба секции
            translate([0, 0, z0]) ring_shell(body_outer_r, body_inner_r, section_h);

            // Внутреннее соединительное кольцо: половина в текущей секции,
            // половина выступает вверх в следующую (кроме последней секции).
            if (i < section_count - 1) {
                translate([0, 0, z0 + section_h - ring_length / 2])
                    ring_shell(body_inner_r, max(0.1, body_inner_r - wall), ring_length);
            }
        }

        // Вырезаем винтовую канавку только в пределах секции
        intersection() {
            full_helix();
            translate([0, 0, z0]) cylinder(h = section_h, r = body_outer_r + wire_d + 2);
        }
    }
}

module hub() {
    // Центральная втулка как отдельная деталь.
    // Кольцевой выступ выходит из основания втулки вверх в первую секцию.
    union() {
        ring_shell(body_outer_r, body_inner_r, hub_h);
        translate([0, 0, hub_h])
            ring_shell(body_inner_r, max(0.1, body_inner_r - wall), hub_ring_length);
    }
}

module reflector() {
    difference() {
        cylinder(h = reflector_thickness, d = reflector_d);

        // Центральное отверстие под трубу
        translate([0, 0, -0.1]) cylinder(h = reflector_thickness + 0.2, d = 2 * body_outer_r);

        // SMA: центральное отверстие
        translate([sma_offset, 0, -0.1])
            cylinder(h = reflector_thickness + 0.2, d = sma_center_hole_d);

        // SMA: 4 монтажных отверстия
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sma_offset + sx * (sma_mount_spacing / 2),
                sy * (sma_mount_spacing / 2),
                -0.1
            ])
                cylinder(h = reflector_thickness + 0.2, d = sma_mount_hole_d);
        }

        // 4 отверстия крепления рефлектора к втулке
        for (a = [45, 135, 225, 315]) {
            translate([
                (body_outer_r + wall * 0.6) * cos(a),
                (body_outer_r + wall * 0.6) * sin(a),
                -0.1
            ])
                cylinder(h = reflector_thickness + 0.2, d = 3.2);
        }
    }
}

module bracket() {
    difference() {
        translate([-bracket_size / 2, -bracket_size / 2, 0])
            cube([bracket_size, bracket_size, bracket_t]);

        // Центральное отверстие под ось/трубу
        translate([0, 0, -0.1]) cylinder(h = bracket_t + 0.2, d = 2 * body_outer_r);

        // 4 отверстия под крепёж к монтажной плоскости
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx * bracket_mount_offset,
                sy * bracket_mount_offset,
                -0.1
            ])
                cylinder(h = bracket_t + 0.2, d = bracket_mount_hole_d);
        }
    }
}

module assembly() {
    // Рефлектор
    reflector();

    // Втулка над рефлектором
    translate([0, 0, reflector_thickness]) hub();

    // Секции корпуса над втулкой
    for (i = [0 : section_count - 1]) {
        translate([0, 0, reflector_thickness + hub_h]) body_section(i);
    }

    // Кронштейн с обратной стороны рефлектора
    translate([0, 0, -bracket_t]) bracket();
}

////////////////////////////
// ТОЧКА ВХОДА
////////////////////////////

if (mode == "assembly") {
    assembly();
} else if (mode == "section") {
    body_section(section_index);
} else if (mode == "hub") {
    hub();
} else if (mode == "reflector") {
    reflector();
} else if (mode == "bracket") {
    bracket();
} else {
    echo("Неизвестный mode");
}
