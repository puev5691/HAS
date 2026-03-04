//====================================================
// Печатная оснастка для геликальной антенны (спираль не выводится)
// DEV версия v27
// Дата выпуска: 2026-03-04
// Автор: Сержант Свистофлягов
// Соавтор: ChatGPT (OpenAI)
// Имя файла: helical_antenna_dev_v27.scad
//====================================================
// Печатные детали:
// - Труба для намотки (опционально канавка-ориентир; спираль не печатается)
// - Шаблон для сверления/резки рефлектора (опционально)
// - Крепёж из 2 деталей: (A) площадка под трубу с кольцом и стойками,
//                         (B) крепление к плоскости с 4 ушами
// - Посадка под SMA на квадратной площадке со стороны рефлектора
// - Опциональный кондуктор для гибки дельта-матча (сам дельта-матч — проволока)
//
// Единицы: миллиметры
//====================================================

/* [Быстрый экспорт] */
// Выбор детали для вывода/экспорта (STL)
export_part_sel = 3; // [0:Сборка (все вместе),1:Труба целиком,2:Труба — секция,3:Труба — все секции (разложить),4:Площадка под трубу,5:Крепление к плоскости,6:Шаблон рефлектора,7:Кондуктор дельта-матча]

/* [РЧ параметры] */
// Рабочая частота (МГц)
freq_mhz = 5800;          // [300:1:10000]
// Целевое усиление (dBi) — только для расчёта длины трубы
target_gain_dbi = 12;
// Поляризация (направление намотки проволоки)
polarization_sel = 0;     // [0:Правое (RHCP),1:Левое (LHCP)]

/* [Геометрия спирали (только для расчёта трубы)] */
// Длина окружности спирали: C = factor * λ (для расчёта трубы)
circumference_factor = 1.00;
// Шаг витка: S = factor * λ (для расчёта трубы)
pitch_factor = 0.25;
// Минимальное число витков (ограничение расчёта)
min_turns = 5.5;
// Максимальное число витков (ограничение расчёта)
max_turns = 14;

/* [Проволока и согласование (дельта-матч)] */
// Диаметр проволоки (мм)
wire_d = 1.2;
// Материал проволоки
wire_material_sel = 0;        // [0:Медь/медный сплав,1:Латунь,2:Алюминий]
// Режим согласования (дельта-матч)
delta_mode_sel = 0;           // [0:Авторасчёт,1:Вручную]
// Дельта-матч: основание треугольника (мм), 0 = игнорировать
delta_base_manual = 0;
// Дельта-матч: высота треугольника (мм), 0 = игнорировать
delta_height_manual = 0;
// Дельта-матч: точка подключения кабеля (мм от "земли"), 0 = игнорировать
delta_tap_manual = 0;

/* [Труба намотки] */
// Толщина стенки трубы (мм): режим
tube_wall_mode_sel = 0;   // [0:Авторасчёт,1:Вручную]
// Толщина стенки трубы (мм) — используется в режиме "Вручную"
tube_wall_manual = 2.0;
// Авторасчёт стенки: tube_wall ≈ λ / делитель
tube_wall_lambda_div = 120;
// Минимальная толщина стенки (мм)
tube_wall_min = 2.2;
// Максимальная толщина стенки (мм) — защита от «каменной» трубы на очень низких частотах
tube_wall_max = 25;

// Посадочный зазор на кольцо (мм)
tube_clearance = 0.25;
// Канавка-ориентир для укладки проволоки
tube_groove_enable = true;
// Качество канавки: сегментов на виток (выше = ровнее, но медленнее)
groove_segments_per_turn = 24;
// Глубина канавки: режим
tube_groove_depth_mode_sel = 0; // [Авторасчёт,Ручная]
// Глубина канавки (мм) — используется в режиме "Ручная"
tube_groove_depth_manual = 0.8;
// Ширина канавки (мм)
tube_groove_width = 1.2;

// Деление трубы по максимально допустимой длине секции.
// Правило:
// - если общая длина ≤ 180 мм — 1 секция
// - если > 180 мм — 2 секции равной длины
// - если > 360 мм — 3 секции равной длины
// - если > 540 мм — 4 секции равной длины
// Макс. длина секции трубы (мм) — для авторазреза на равные части
tube_max_section_len = 180;
// Зазор между секциями трубы (мм)
tube_section_gap = 0.25;

// Экспорт секции (актуально, если выбрана «Труба — секция»)
// Экспортируемая секция трубы (индекс)
export_section = 0;

/* [Площадка под трубу (деталь A)] */
// Толщина площадки (мм)
plate_thickness = 4.0;
// Запас радиуса площадки вокруг трубы (мм)
plate_radial_clearance = 20;  // доступ отвёрткой, чтобы не цепляться за края
// Высота кольца (посадки под трубу) (мм)
spigot_height = 6.0;
// Количество стоек под стяжные винты
standoff_count = 4;
// Диаметр стойки (мм)
standoff_d = 10.0;
// Высота стойки над площадкой (мм)
standoff_h = 6.0;
// Диаметр проходного отверстия под стяжной винт (мм)
clamp_screw_d = 3.2;
// Выборка под шляпку винта: диаметр (мм)
clamp_screw_head_d = 6.4;
// Выборка под шляпку винта: глубина (мм)
clamp_screw_head_h = 2.4;

/* [Крепление к плоскости (деталь B)] */
// Высота опорного блока крепления к плоскости (мм)
wall_block_thickness = 5.0;
// Габарит опорного блока (мм)
wall_block_xy = 28;
// Длина "уха" под крепёж (мм)
lug_length = 10;
// Ширина "уха" под крепёж (мм)
lug_width = 10;
// Отверстие крепления к плоскости (мм)
lug_hole_d = 5.0;
// Расстояние между двумя ушами на одной стороне (мм)
lug_pair_gap = 10;

/* [Шаблон рефлектора] */
// Режим рефлектора
reflector_mode_sel = 0;       // [0:Авторазмер по частоте,1:Вручную]
reflector_d_manual = 120;     // мм если «Вручную»
reflector_thickness_template = 1.0;  // мм (шаблон; реальный рефлектор обычно из металла)

/* [Разъём SMA на площадке] */
// Твой SMA: квадрат ~12.6 мм, отверстия по углам ~8 мм (центр-центр)
// Сторона квадратной площадки SMA (мм)
sma_flange_side = 12.6;
sma_hole_spacing = 8.0;       // мм (центр-центр)
// Диаметр отверстий под винты SMA (мм)
sma_flange_hole_d = 2.4;
// Отверстие под центральный контакт/тело SMA (мм)
sma_center_hole_d = 6.6;
sma_offset_r = 0;             // мм смещение от центра (0 = по центру)

/* [Качество рендера] */
// Быстрый режим превью
preview_mode = true;          // Быстрый режим для превью
// Профиль качества отображения/экспорта
render_preset_sel = 1;        // [0:Быстро,1:Нормально,2:Красиво]


//====================================================
// Internal mapping (без вывода в Настройщик)
//====================================================

export_part =
    (export_part_sel==0) ? "assembly" :
    (export_part_sel==1) ? "tube" :
    (export_part_sel==2) ? "tube_section" :
    (export_part_sel==3) ? "tube_sections_layout" :
    (export_part_sel==4) ? "plate" :
    (export_part_sel==5) ? "wall_mount" :
    (export_part_sel==6) ? "reflector_template" :
    "delta_jig";

polarization = (polarization_sel==0) ? "RHCP" : "LHCP";

wire_material = (wire_material_sel==0) ? "CuAlloy" : (wire_material_sel==1) ? "Brass" : "Al";
delta_mode = (delta_mode_sel==0) ? "auto" : "manual";
reflector_mode = (reflector_mode_sel==0) ? "auto" : "manual";
render_preset = (render_preset_sel==0) ? "fast" : (render_preset_sel==1) ? "normal" : "pretty";


//====================================================
// Quality
//====================================================
$fn = (preview_mode || render_preset=="fast") ? 24 :
      (render_preset=="pretty" ? 96 : 48);


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

// Толщина стенки трубы (авто/ручная)
tube_wall_auto_0 = clamp(lambda_mm / tube_wall_lambda_div, tube_wall_min, tube_wall_max);
// Чтобы проволока «сидела» нормально, стенка должна быть соразмерна диаметру проволоки
tube_wall_auto = max(tube_wall_auto_0, wire_d*1.6);
tube_wall = (tube_wall_mode_sel==0) ? tube_wall_auto : tube_wall_manual;

// Внутренний диаметр трубы
tube_id = max(0.1, tube_od - 2*tube_wall);

// Tube length sizing by gain rule-of-thumb
turns_raw = pow(10, (target_gain_dbi - 5.4)/10);
turns = clamp(turns_raw, min_turns, max_turns);
tube_len = turns * pitch_mm;

// Auto section count from tube_len and tube_max_section_len
// (см. правило в Настройщике)
tube_sections_auto = max(1, ceil(tube_len / tube_max_section_len));
tube_sections = tube_sections_auto;

// Reflector diameter (auto start)
reflector_d_auto = lambda_mm * 0.85;
reflector_d = (reflector_mode == "manual") ? reflector_d_manual : reflector_d_auto;

// Площадка под трубу: чуть больше трубы (доступ отвёрткой)
plate_od = tube_od + 2*plate_radial_clearance;

// Spigot geometry: труба надевается СВЕРХУ на кольцо и фиксируется клеем
spigot_od = max(0.1, tube_id - 2*tube_clearance);
// Толщина стенки кольца пропорциональна стенке трубы, но ограничена геометрией
spigot_wall = clamp(tube_wall*0.8, 2.0, max(2.0, spigot_od/2 - (clamp_screw_d/2 + 1.0)));
spigot_id = max(clamp_screw_d + 1.0, spigot_od - 2*spigot_wall);

// Standoff circle radius
standoff_radial_offset = 14; // отступ стоек от наружного диаметра трубы
standoff_r = tube_od/2 + standoff_radial_offset;


//====================================================
// Delta-match "auto" starting geometry
//====================================================
// Важно: это стартовая геометрия для настройки. В реальной сборке часто
// требуется небольшая подстройка по КСВ.
// Влияние материала/диаметра проволоки учитываем мягко: геометрия важнее потерь.
mat_k = (wire_material == "Brass") ? 0.995 : (wire_material == "Al") ? 0.990 : 1.000;
wd_k = 1.0 - clamp((wire_d - 1.0) * 0.002, -0.02, 0.02);

delta_base_auto = lambda_mm * 0.18 * mat_k * wd_k;
delta_height_auto = lambda_mm * 0.10 * mat_k * wd_k;
delta_tap_auto = delta_height_auto * 0.45;

delta_base = (delta_mode == "manual" && delta_base_manual > 0) ? delta_base_manual : delta_base_auto;
delta_height = (delta_mode == "manual" && delta_height_manual > 0) ? delta_height_manual : delta_height_auto;
delta_tap = (delta_mode == "manual" && delta_tap_manual > 0) ? delta_tap_manual : delta_tap_auto;


// Console
echo("==== Helical Antenna v27 (mechanical parts only) ====");
echo("freq_mhz=", freq_mhz, " lambda_mm=", lambda_mm);
echo("tube_od(mm)=", tube_od, " tube_len(mm)=", tube_len, " pitch(mm)=", pitch_mm, " turns=", turns);
echo("tube_max_section_len(mm)=", tube_max_section_len, " tube_sections(auto)=", tube_sections);
echo("reflector_d(mm)=", reflector_d);
echo("Delta-match (start) base(mm)=", delta_base, " height(mm)=", delta_height, " tap(mm)=", delta_tap);
echo("Polarization=", polarization);


//====================================================
// Modules
//====================================================

// Вспомогательная математика (для совместимости разных версий OpenSCAD)
function vlen(v) = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
function vcross(a,b) = [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]];

module drill_hole(d, h, cbore_d=0, cbore_h=0) {
    cylinder(d=d, h=h, center=false);
    if (cbore_d > 0 && cbore_h > 0)
        translate([0,0,h-cbore_h]) cylinder(d=cbore_d, h=cbore_h, center=false);
}

// Быстрый "стержень" между двумя точками (для канавки)
module rod_between(p0, p1, d) {
    v = [p1[0]-p0[0], p1[1]-p0[1], p1[2]-p0[2]];
    h = vlen(v);
    if (h > 0) {
        ax = vcross([0,0,1], v);
        axn = vlen(ax);
        // В OpenSCAD тригонометрия в градусах
        ang = acos(clamp(v[2] / h, -1, 1));

        translate(p0) {
            if (axn < 1e-9) {
                cylinder(d=d, h=h, center=false);
            } else {
                rotate(a=ang, v=ax) cylinder(d=d, h=h, center=false);
            }
        }
    }
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
    // Деталь A: площадка + кольцо (посадка трубы) + стойки
    difference() {
        union() {
            cylinder(d=plate_od, h=plate_thickness);

            translate([0,0,plate_thickness])
                difference() {
                    cylinder(d=spigot_od, h=spigot_height);
                    translate([0,0,-0.01]) cylinder(d=spigot_id, h=spigot_height+0.02);
                }

            for (i=[0:standoff_count-1]) {
                ang = 360*i/standoff_count;
                translate([standoff_r*cos(ang), standoff_r*sin(ang), plate_thickness])
                    cylinder(d=standoff_d, h=standoff_h);
            }
        }

        // Центральный стяжной винт
        translate([0,0,-0.01])
            cylinder(d=clamp_screw_d, h=plate_thickness+spigot_height+standoff_h+0.02);

        // Отверстия в стойках
        for (i=[0:standoff_count-1]) {
            ang = 360*i/standoff_count;
            translate([standoff_r*cos(ang), standoff_r*sin(ang), -0.01])
                drill_hole(clamp_screw_d, plate_thickness+standoff_h+0.02, clamp_screw_head_d, clamp_screw_head_h);
        }

        // Проход под внутренний диаметр трубы
        translate([0,0,plate_thickness-0.01])
            cylinder(d=tube_id + 2.0, h=spigot_height+standoff_h+0.02);
    }
}

module wall_mount_part() {
    // Деталь B: основание для крепления к плоскости + 4 уха (Ø5) + стяжные отверстия
    difference() {
        union() {
            translate([-wall_block_xy/2, -wall_block_xy/2, 0])
                cube([wall_block_xy, wall_block_xy, wall_block_thickness]);

            // 2 уха сверху (+Y)
            for (k=[-1,1]) {
                translate([k*(lug_pair_gap/2), wall_block_xy/2, 0])
                    translate([-lug_width/2, 0, 0])
                        cube([lug_width, lug_length, wall_block_thickness]);
            }
            // 2 уха снизу (-Y)
            for (k=[-1,1]) {
                translate([k*(lug_pair_gap/2), -wall_block_xy/2 - lug_length, 0])
                    translate([-lug_width/2, 0, 0])
                        cube([lug_width, lug_length, wall_block_thickness]);
            }
        }

        // 4 сквозных Ø5 в ушах
        for (side=[1,-1]) for (k=[-1,1]) {
            y0 = (side==1) ? (wall_block_xy/2 + lug_length/2) : (-wall_block_xy/2 - lug_length/2);
            translate([k*(lug_pair_gap/2), y0, -0.01])
                cylinder(d=lug_hole_d, h=wall_block_thickness+0.02);
        }

        // Стяжные отверстия по стойкам
        for (i=[0:standoff_count-1]) {
            ang = 360*i/standoff_count;
            translate([standoff_r*cos(ang), standoff_r*sin(ang), -0.01])
                cylinder(d=clamp_screw_d, h=wall_block_thickness+0.02);
        }

        // Центральный стяжной винт
        translate([0,0,-0.01])
            cylinder(d=clamp_screw_d, h=wall_block_thickness+0.02);
    }
}

module reflector_template() {
    // Печатный шаблон для сверления/резки металлического рефлектора
    difference() {
        cylinder(d=reflector_d, h=reflector_thickness_template);

        // Стяжные отверстия
        for (i=[0:standoff_count-1]) {
            ang = 360*i/standoff_count;
            translate([standoff_r*cos(ang), standoff_r*sin(ang), -0.01])
                cylinder(d=clamp_screw_d, h=reflector_thickness_template+0.02);
        }
        translate([0,0,-0.01]) cylinder(d=clamp_screw_d, h=reflector_thickness_template+0.02);

        // Отверстия под SMA
        translate([sma_offset_r,0,-0.01]) {
            sma_center_hole(reflector_thickness_template+0.02);
            sma_flange_holes(reflector_thickness_template+0.02);
        }
    }
}

module tube_single() {
    // Труба с опциональной неглубокой канавкой-ориентиром (спираль не печатается)
    difference() {
        cylinder(d=tube_od, h=tube_len);
        translate([0,0,-0.01]) cylinder(d=tube_id, h=tube_len+0.02);

        if (tube_groove_enable) {
            seg_per_turn = (preview_mode || render_preset=="fast") ? max(8, floor(groove_segments_per_turn/3)) : groove_segments_per_turn;
            steps = max( max(24, ceil(turns*seg_per_turn)), ceil(tube_len/2) );
            groove_depth_target = (tube_groove_depth_mode_sel==0) ? max(0.6*wire_d, tube_od*0.008, 0.8) : tube_groove_depth_manual;
            // Канавка должна оставаться СНАРУЖИ: ограничиваем глубину по толщине стенки
            groove_inner_margin = max(0.6, 0.4*wire_d);
            groove_depth_cap = max(0, tube_wall - groove_inner_margin);
            groove_depth_eff = min(groove_depth_target, groove_depth_cap);
            // Центр выреза привязан к внешнему радиусу
            r_cut = tube_od/2 - groove_depth_eff/2;
            
            for (i=[0:steps-1]) {
                t0 = i/steps;
                t1 = (i+1)/steps;
                z0 = t0*tube_len;
                z1 = t1*tube_len;
                a0 = 360*turns*t0 * ((polarization=="RHCP") ? 1 : -1);
                a1 = 360*turns*t1 * ((polarization=="RHCP") ? 1 : -1);

                p0 = [r_cut*cos(a0), r_cut*sin(a0), z0];
                p1 = [r_cut*cos(a1), r_cut*sin(a1), z1];
                rod_between(p0, p1, tube_groove_width);
            }
        }
    }
}

module tube_section(idx=0) {
    // Делим общую длину на N равных секций (не "180 и остаток")
    seg_len = (tube_len - (tube_sections-1)*tube_section_gap) / tube_sections;
    z0 = idx*(seg_len + tube_section_gap);

    // Секция перемещается к нулю для удобного экспорта
    translate([0,0,-z0])
        intersection() {
            tube_single();
            translate([-tube_od, -tube_od, z0])
                cube([2*tube_od, 2*tube_od, seg_len]);
        }
}

module tube_sections_layout() {
    // Раскладываем все секции рядом по X
    spacing = tube_od + 6;
    for (i=[0:tube_sections-1]) {
        translate([i*spacing, 0, 0])
            tube_section(i);
    }
}

module delta_match_jig() {
    // Кондуктор для гибки дельта-матча по расчётным размерам
    base_th = 4;
    peg_h = 8;
    peg_d = max(wire_d*2.2, 3.5);

    pA = [0, 0];
    pB = [delta_base, 0];
    pC = [0, delta_height];
    pT = [0, delta_tap];

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
    // Снизу вверх: wall_mount -> template -> plate -> tube
    wall_mount_part();

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
    idx = clamp(export_section, 0, tube_sections-1);
    tube_section(idx);
} else if (export_part == "tube_sections_layout") {
    tube_sections_layout();
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