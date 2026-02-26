//====================================================
// PARAMETRIC HELICAL ANTENNA GENERATOR
// DEVELOPMENT VERSION v11
//====================================================
//
// Author (concept, antenna design):
// Serzhant Svistofliagov
// Email: kuhnyaexklyuziv@yandex.ru
//
// Programming and parametric logic:
// Generated with assistance of ChatGPT (OpenAI, GPT-5.2)
//
// Year: 2026
// Release date: 2026-02-16
// Version: v11
//
//====================================================


/* [0. Экспорт STL] */
export_mode = "preview"; // [preview,single,sequence]
export_section = 0;


/* [1. Диапазон частоты] */
band = "1200"; // [350,450,550,650,750,850,950,1050,1200,1400,1600,1800,2000,2200,2400,2600,2800]
manual_frequency = 1200;


/* [2. Усиление антенны] */
target_gain = 12;


/* [3. Шаг витков] */
pitch_mode = "Стандарт"; // [Компактный,Стандарт,Четверть волны,Ручной]
pitch_manual = 0.25;


/* [4. Диаметр провода] */
wire_profile = "Стандарт"; // [Тонкий,Стандарт,Широкополосный,Ручной]
wire_manual = 2.5;


/* [5. Режим прочности корпуса] */
structure_mode = "Стандарт"; // [Лёгкий,Стандарт,Усиленный]


/* [6. Корпус] */
wall_mode = "Авто"; // [Авто,Ручной]
wall_manual = 3;
groove_clearance = 0.6;
base_thickness = 5;


/* [7. Секции] */
enable_sections = true;
max_section_height = 180;


/* [8. Качество рендера] */
render_quality = "Стандарт"; // [Быстрый,Стандарт]
$fn = render_quality == "Быстрый" ? 24 : 48;


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

lambda = 300000 / frequency;


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
// ВИТКИ
//====================================================
turns_calc = pow(10, (target_gain - 5.4)/10);
turns = min(14, max(5.5, turns_calc));


//====================================================
// ГЕОМЕТРИЯ
//====================================================
circumference = lambda;
radius = circumference / (2 * PI);
height = spacing * turns;

groove_depth = wire_d * 0.55;
groove_d = wire_d + groove_clearance;


//====================================================
// ПРОВОД
//====================================================
wire_length =
    sqrt(
        pow(circumference * turns,2) +
        pow(spacing * turns,2)
    );


//====================================================
// СТЕНКА
//====================================================
min_wall = groove_depth + 1.5;
wave_wall = lambda * 0.015;

structure_factor =
    structure_mode == "Лёгкий" ? 0.8 :
    structure_mode == "Стандарт" ? 1.0 :
    structure_mode == "Усиленный" ? 1.4 :
    1.0;

auto_wall = max(min_wall, wave_wall) * structure_factor;

wall =
    wall_mode == "Ручной" ? wall_manual :
    auto_wall;

body_radius = radius + wall;
body_height = height + base_thickness;


//====================================================
// СЕКЦИИ
//====================================================
section_count = enable_sections ?
    ceil(body_height / max_section_height) : 1;

section_height = body_height / section_count;


//====================================================
// ВНУТРЕННЕЕ СТЫКОВОЧНОЕ КОЛЬЦО
//====================================================
inner_radius = radius;

ring_length = max(10, section_height * 0.10);

ring_outer = inner_radius;
ring_inner = inner_radius - wall;


//====================================================
// ВЫВОД
//====================================================
echo("Частота (МГц) =", frequency);
echo("Усиление (dBi) =", target_gain);
echo("Витков =", turns);
echo("Диаметр провода (мм) =", wire_d);
echo("Длина прутка (мм) =", wire_length);
echo("Толщина стенки =", wall);
echo("Длина кольца =", ring_length);


//====================================================
// СПИРАЛЬ
//====================================================
module full_helix() {

    steps = turns * (render_quality == "Быстрый" ? 10 : 20);
    groove_radius = body_radius + groove_depth - 0.2;

    for (i = [0:steps-1]) {

        z1 = height * i/steps;
        z2 = height * (i+1)/steps;

        a1 = z1/height * turns * 360;
        a2 = z2/height * turns * 360;

        p1 = [groove_radius*cos(a1), groove_radius*sin(a1), z1];
        p2 = [groove_radius*cos(a2), groove_radius*sin(a2), z2];

        hull() {
            translate(p1) sphere(d=groove_d, $fn=8);
            translate(p2) sphere(d=groove_d, $fn=8);
        }
    }
}


//====================================================
// СЕКЦИЯ
//====================================================
module body_section(i) {

    z0 = i * section_height;
    z1 = z0 + section_height;

    union() {

        // корпус секции
        intersection() {
            difference() {
                cylinder(h = body_height, r = body_radius);
                translate([0,0,-1])
                    cylinder(h = body_height+2, r = radius);
                full_helix();
            }

            translate([0,0,z0])
                cylinder(h = section_height, r = body_radius+2);
        }

        // внутреннее кольцо
        if (i < section_count-1)
        difference() {
            translate([0,0,z1 - ring_length/2])
                cylinder(h = ring_length, r = ring_outer);
            translate([0,0,z1 - ring_length/2 -1])
                cylinder(h = ring_length+2, r = ring_inner);
        }
    }
}


//====================================================
// РЕНДЕР
//====================================================
if (export_mode == "preview") {
    for (i = [0:section_count-1])
        body_section(i);
}
else if (export_mode == "single") {
    body_section(export_section);
}
else if (export_mode == "sequence") {
    body_section(export_section);
}
