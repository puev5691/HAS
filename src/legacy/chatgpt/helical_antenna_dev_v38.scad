//====================================================
// Печатная оснастка для геликальной антенны (спираль не выводится)
// DEV версия v33
// Дата выпуска: 2026-03-04
// Автор: Сержант Свистофлягов
// Соавтор: ChatGPT (OpenAI)
// Имя файла: helical_antenna_dev_v33.scad
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
export_part_sel = 2; // [0:Сборка (все вместе),1:Труба — секция,2:Труба — все секции (разложить),3:Площадка под трубу,4:Крепление к плоскости,5:Шаблон рефлектора,6:Треугольник согласования (просмотр),7:Кондуктор дельта-матча]

/* [РЧ параметры] */
// Рабочая частота (МГц)
freq_mhz = 5800;          // [100:1:10000]
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


// Соединительные кольца (шипы) между секциями трубы
tube_joint_enable = true;          // Включить соединительные кольца между секциями
tube_joint_len = 12;               // Длина соединительного кольца (мм)
tube_joint_clearance = 0.25;       // Зазор посадки (мм)
tube_joint_wall_factor = 1.0;      // Толщина стенки кольца = tube_wall * factor
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
// Отступ по периметру от площадки под трубу (мм) — влияет на габарит детали B
wall_block_margin = 8.0;
// Диаметр отверстий крепления к плоскости (мм)
lug_hole_d = 5.0;
// Размеры "уха" под крепёж к плоскости (мм)
lug_length = 12;
lug_width = 12;

// Форма детали B: false=квадрат, true=круг
wall_mount_round = true; // деталь Б теперь круглая (экономия пластика)


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


// N фланцевый
module n_center_hole(th) {
    cylinder(d=n_center_hole_d, h=th, center=false);
}
module n_flange_holes(th) {
    for (sx=[-1,1], sy=[-1,1]) {
        translate([sx*n_hole_spacing/2, sy*n_hole_spacing/2, 0])
            cylinder(d=n_flange_hole_d, h=th, center=false);
    }
}

// Универсальные отверстия под активный разъём
module connector_center_hole(th) {
    if (connector_type==1) sma_center_hole(th);
    else if (connector_type==2) n_center_hole(th);
}
module connector_flange_holes(th) {
    if (connector_type==1) sma_flange_holes(th);
    else if (connector_type==2) n_flange_holes(th);
}
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
    (export_part_sel==1) ? "tube_section" :
    (export_part_sel==2) ? "tube_sections_layout" :
    (export_part_sel==3) ? "plate" :
    (export_part_sel==4) ? "wall_mount" :
    (export_part_sel==5) ? "reflector_template" :
    (export_part_sel==6) ? "delta_preview" :
    "delta_jig";

/* [Разъём и точка питания] */
// Тип разъёма (авто: >=1000 МГц -> SMA, ниже -> N)
connector_type_sel = 0;       // [0:Авто (по частоте),1:SMA фланцевый,2:N фланцевый]
// Порог частоты для авто-выбора SMA (МГц)
connector_auto_threshold_mhz = 1000;
// Смещение разъёма от центра рефлектора по оси X (мм)
conn_offset_r = sma_offset_r;

/* [N фланцевый (N1) - размеры] */
// Площадка N (мм) (квадрат)
n_flange_side = 28.0;
// Расстояние между отверстиями N (центр-центр, мм)
n_hole_spacing = 18.0;
// Диаметр отверстий под болты N (мм)
n_flange_hole_d = 3.2;
// Центральное отверстие под N (мм) (подправишь по фото/замеру)
n_center_hole_d = 16.5;

// Толщина медной пластины для дельта-матча (мм)
delta_strip_t = 0.5;
// Ширина медной пластины (мм) (для кондуктора гибки; не печатается как металл)
delta_strip_w = 4.0;

// Угол расположения точки питания (градусы) вокруг трубы (0 = вправо по X)
feed_angle_deg = 0;
// Отверстие/паз для фиксации начала спирали (мм)
helix_start_hole_d = 0;       // 0 = выкл, иначе (wire_d+зазор)

/* [Визуализация (не печатается)] */
// Показывать в режиме "Сборка" непечатаемые элементы (разъём, спираль, дельта-матч)
show_nonprintable = true;
// Показывать алюминиевый рефлектор (толщина задаётся ниже)
show_real_reflector = true;
// Толщина реального металлического рефлектора (мм)
real_reflector_thickness = 3.0;
// Показывать модель разъёма (упрощённая)
show_connector_model = true;
// Показывать непечатаемую спираль (эскиз для ориентира)
show_helix_preview = true;
// Сколько витков рисовать в превью (0 = авто, но не больше 6)
helix_preview_turns = 0;      // [0:1:6]
// Показывать непечатаемый треугольник согласования (эскиз)
show_delta_preview = true;

polarization = (polarization_sel==0) ? "RHCP" : "LHCP";
helix_handed = (polarization=="RHCP") ? 1 : -1; // +1 => правое вращение при взгляде со стороны +Z

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

// Выбор активного разъёма
connector_type = (connector_type_sel==0) ? ((freq_mhz >= connector_auto_threshold_mhz) ? 1 : 2) : connector_type_sel; // 1=SMA, 2=N

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
// Габарит опорного блока детали B — масштабируется вместе с площадкой
wall_block_xy = plate_od + 2*wall_block_margin;

// Spigot geometry: труба надевается СВЕРХУ на кольцо и фиксируется клеем
spigot_od = max(0.1, tube_id - 2*tube_clearance);
// Толщина стенки кольца пропорциональна стенке трубы, но ограничена геометрией
spigot_wall = clamp(tube_wall*0.8, 2.0, max(2.0, spigot_od/2 - (clamp_screw_d/2 + 1.0)));
spigot_id = max(clamp_screw_d + 1.0, spigot_od - 2*spigot_wall);

// Standoff circle radius
standoff_radial_offset = 14; // отступ стоек от наружного диаметра трубы
standoff_r = tube_od/2 + standoff_radial_offset;

// Connector radial position: 0 => automatically near tube perimeter (tangent feed)
conn_offset_r_eff = (conn_offset_r <= 0) ? (tube_od/2 + 2.5) : conn_offset_r;


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
echo("==== Helical Antenna v31 (mechanical parts only) ====");
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
    }
}

module wall_mount_part() {
    // Деталь B: основание для крепления к плоскости + 4 уха (Ø5) + отверстия под стяжные винты (совпадают со стойками детали A)
    difference() {
        union() {
            // Основной опорный блок (масштабируется от plate_od)
            // основание: круглая площадка
            cylinder(d=wall_block_xy, h=wall_block_thickness);

            // 4 уха по сторонам (N/E/S/W), по одному отверстию в каждом
            // +Y
            translate([-lug_width/2, wall_block_xy/2, 0])
                cube([lug_width, lug_length, wall_block_thickness]);
            // -Y
            translate([-lug_width/2, -wall_block_xy/2 - lug_length, 0])
                cube([lug_width, lug_length, wall_block_thickness]);
            // +X
            translate([wall_block_xy/2, -lug_width/2, 0])
                cube([lug_length, lug_width, wall_block_thickness]);
            // -X
            translate([-wall_block_xy/2 - lug_length, -lug_width/2, 0])
                cube([lug_length, lug_width, wall_block_thickness]);
        }

        // Отверстия Ø5 в ушах (крепление к плоскости)
        // +Y / -Y
        translate([0, wall_block_xy/2 + lug_length/2, -0.01])
            cylinder(d=lug_hole_d, h=wall_block_thickness+0.02);
        translate([0, -wall_block_xy/2 - lug_length/2, -0.01])
            cylinder(d=lug_hole_d, h=wall_block_thickness+0.02);
        // +X / -X
        translate([wall_block_xy/2 + lug_length/2, 0, -0.01])
            cylinder(d=lug_hole_d, h=wall_block_thickness+0.02);
        translate([-wall_block_xy/2 - lug_length/2, 0, -0.01])
            cylinder(d=lug_hole_d, h=wall_block_thickness+0.02);

        // Отверстия под стяжные винты: совпадают с положением стоек детали A
        for (i=[0:standoff_count-1]) {
            ang = 360*i/standoff_count;
            translate([standoff_r*cos(ang), standoff_r*sin(ang), -0.01])
                cylinder(d=clamp_screw_d + 0.4, h=wall_block_thickness+0.02);
        }

        // Центральный стяжной винт (если используется как центральная стяжка)
        translate([0,0,-0.01])
            cylinder(d=clamp_screw_d + 0.4, h=wall_block_thickness+0.02);
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
        translate([conn_offset_r,0,-0.01]) {
            connector_center_hole(reflector_thickness_template+0.02);
            connector_flange_holes(reflector_thickness_template+0.02);
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
                a0 = 360*turns*t0 * helix_handed;
                a1 = 360*turns*t1 * helix_handed;

                p0 = [r_cut*cos(a0), r_cut*sin(a0), z0];
                p1 = [r_cut*cos(a1), r_cut*sin(a1), z1];
                rod_between(p0, p1, tube_groove_width);
            }
        }
    }
}

module tube_section(idx=0) {
    // ФИЗИЧЕСКАЯ длина секции (без "зазоров", зазоры нужны только для раскладки на столе)
    seg_len = tube_len / tube_sections;
    z0 = idx*seg_len;

    // Тело секции: вырезаем кусок из целой трубы

    // Соединительное кольцо (шип) на верхнем торце — у всех секций, кроме последней
    // Оно вставляется ВНУТРЬ следующей секции, поэтому наружный диаметр делаем меньше внутреннего диаметра трубы.
    joint_wall = max(0.8, tube_wall * tube_joint_wall_factor);
    spigot_od = max(0.1, tube_id - 2*tube_joint_clearance);
    spigot_id = max(0.1, spigot_od - 2*joint_wall);
    spigot_len = min(tube_joint_len, seg_len*0.45);

    union() {
        // Тело секции: вырезаем кусок из целой трубы и переносим в Z=0..seg_len
        translate([0,0,-z0])
            intersection() {
                tube_single();
                translate([-tube_od, -tube_od, z0])
                    cube([2*tube_od, 2*tube_od, seg_len]);
            }

        if (tube_joint_enable && tube_sections > 1 && idx < tube_sections-1) {
            // Шип выступает наружу вверх, но на сборке утапливается внутрь следующей секции, поэтому общая длина не растёт
            translate([0,0,seg_len])
                difference() {
                    cylinder(h=spigot_len, r=spigot_od/2, $fn=48);
                    translate([0,0,-0.1])
                        cylinder(h=spigot_len+0.2, r=spigot_id/2, $fn=48);
                }
        }
    }
}

module tube_sections_layout() {
    // Раскладываем все секции рядом по X для экспорта/печати
    seg_len = tube_len / tube_sections;
    for (i=[0:tube_sections-1]) {
        translate([ i*(tube_od*2 + 10), 0, 0 ])
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


//====================================================
// Helpers: простая векторная математика (совместимо со старыми сборками OpenSCAD)
//====================================================
function vlen(v) = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
function vsub(a,b) = [a[0]-b[0], a[1]-b[1], a[2]-b[2]];
function vadd(a,b) = [a[0]+b[0], a[1]+b[1], a[2]+b[2]];
function vmul(v,s) = [v[0]*s, v[1]*s, v[2]*s];
function vcross(a,b) = [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]];

//====================================================
// Непечатаемые элементы (только для ориентира сборки/пайки)
//====================================================

// Упрощённая модель разъёма: фланец + цилиндр корпуса + центральный пин
module connector_preview() {
    // Геометрия задаётся "примерно", чтобы было понятно "где что".
    // Позиция задаётся снаружи: translate([conn_offset_r,0,z]) connector_preview();
    flange_side = (connector_type==2) ? n_flange_side : sma_flange_side;
    hole_spacing = (connector_type==2) ? n_hole_spacing : sma_hole_spacing;
    body_d = (connector_type==2) ? 19.0 : 10.0;          // грубо: N толще SMA
    body_len = (connector_type==2) ? 26.0 : 12.0;        // грубо
    pin_d  = (connector_type==2) ? 2.0 : 1.2;
    pin_len = 10.0;

    // Фланец
    color([0.85,0.8,0.35,1.0])
    translate([-flange_side/2,-flange_side/2,0])
        cube([flange_side, flange_side, 2.0], center=false);

    // Корпус "назад" (вниз по Z)
    color([0.7,0.7,0.75,1.0])
    translate([0,0,-body_len])
        cylinder(d=body_d, h=body_len, $fn=48);

    // Пин "вперёд" (вверх по Z)
    color([0.9,0.9,0.95,1.0])
    translate([0,0,2.0])
        cylinder(d=pin_d, h=pin_len, $fn=24);
}

// Рисуем кусок спирали (проволока) как набор цилиндров между точками
module helix_preview(turns_draw) {
    // turns_draw: сколько витков рисовать
    // Радиус по центру проволоки:
    r = tube_od/2 + wire_d*0.6;
    // Направление намотки: RHCP/LHCP (для вида со стороны излучения, +Z)
    handed = helix_handed;

    // Ограничение, чтобы не зависнуть на низких частотах
    steps_per_turn = preview_mode ? 18 : 36;
    tmax = turns_draw;
    total_steps = max(4, floor(steps_per_turn * tmax));

    // Начальная фаза по углу питания
    phase0 = feed_angle_deg;

    for (k=[0:total_steps-1]) {
        t1 = (k     )/steps_per_turn;
        t2 = (k + 1 )/steps_per_turn;
        a1 = handed*(360*t1) + phase0;
        a2 = handed*(360*t2) + phase0;
        p1 = [r*cos(a1), r*sin(a1), t1*pitch_mm];
        p2 = [r*cos(a2), r*sin(a2), t2*pitch_mm];
        seg = vsub(p2,p1);
        seg_len = vlen(seg);

        // цилиндр между p1 и p2
        if (seg_len > 0.0001) {
            axis = vcross([0,0,1], seg);
            axis_len = vlen(axis);
            ang = (axis_len<0.0001) ? 0 : acos(seg[2]/seg_len);

            color([0.9,0.4,0.2,1.0])
            translate(p1)
                rotate(a=ang, v=(axis_len<0.0001 ? [1,0,0] : axis))
                    cylinder(d=wire_d, h=seg_len, $fn=18);
        }
    }
}

// Эскиз дельта-матча (медная пластина 0.5 мм): треугольник в плоскости питания
module delta_match_preview() {
    // Непечатная визуализация согласующего "треугольника" (медная пластина).
    // Ориентация как в "классике": прямой угол у центральной жилы, самый острый — к началу спирали,
    // третий угол свободный и торчит вверх. Пластина в плоскости первой витка (касательная к трубе).

    z0 = tube_z0_mm;                 // уровень рефлектора / базы
    r0 = tube_od_mm/2 + 0.2;         // чуть над стенкой (чтобы не мерцало)
    a0 = 0;                          // стартовый азимут = старт канавки/витка (0° на +X)

    // Единичные оси в точке старта
    ur = [cos(a0), sin(a0), 0];                  // радиально наружу
    ut = helix_handed * [-sin(a0), cos(a0), 0];  // касательная по направлению намотки
    uz = [0,0,1];

    // Локальная система координат треугольника (2D в плоскости ut-uz)
    // A = right angle = центральная жила
    // B = острый угол = к началу спирали
    // C = свободный угол = вверх
    A = [0, 0];
    B = [delta_base_mm, 0];
    C = [0, delta_height_mm];

    // "Подгиб" по трубе: делаем лёгкий изгиб по радиусу (условно)
    bend_k = 0.35; // 0..1 — насколько сильно "обнимаем" трубу

    function lift(p2) =
        // p2=[u,v] -> 3D: u вдоль ut, v вдоль uz, плюс небольшой уход по ur, чтобы повторить трубу
        (r0 + bend_k * (p2[0]/max(1,delta_base_mm)) * 1.2) * ur + p2[0]*ut + p2[1]*uz + [0,0,z0];

    color([1,0.55,0,0.65]) {
        // Полоска‑контур вместо solid (чтобы не мешать печатным деталям)
        for (seg = [[A,B],[A,C],[B,C]]) {
            p0 = lift(seg[0]);
            p1 = lift(seg[1]);
            rod_between(p0, p1, 0.6); // условная "толщина" визуализации
        }
    }

    // Маркеры пайки
    color([1,0,0,0.9]) translate(lift(A)) sphere(d=1.6);  // центральная жила
    color([0,1,0,0.9]) translate(lift(B)) sphere(d=1.6);  // начало спирали
    color([0,0,1,0.9]) translate(lift(C)) sphere(d=1.6);  // свободный угол
}


// Пакет непечатаемых элементов вокруг трубы/рефлектора
module nonprintable_preview() {
    // Реальный рефлектор (алюминий)
    if (show_real_reflector) {
        color([0.7,0.7,0.72,0.35])
            translate([0,0,-real_reflector_thickness])
                cylinder(d=reflector_d, h=real_reflector_thickness, $fn=96);
    }

    // Разъём
    if (show_connector_model) {
        translate([conn_offset_r,0,0])
            connector_preview();
    }

    // Спираль (не печатается)
    if (show_helix_preview) {
        tdraw = (helix_preview_turns==0) ? min(6, turns) : helix_preview_turns;
        helix_preview(tdraw);
    }

    // Дельта-матч (не печатается)
    if (show_delta_preview) {
        delta_match_preview();
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
    // Непечатаемые элементы (разъём, спираль, дельта-матч) — только для ориентира сборки
    if (show_nonprintable) {
        translate([0,0,wall_block_thickness + 0.2 + reflector_thickness_template + 0.2])
            nonprintable_preview();
    }

}



//====================================================
// Main switch
//====================================================
if (export_part == "assembly") {
    assembly();
} else if (export_part == "tube_section") {
    tube_section(0);
} else if (export_part == "tube_sections_layout") {
    tube_sections_layout();
} else if (export_part == "plate") {
    plate_part();
} else if (export_part == "wall_mount") {
    wall_mount_part();
} else if (export_part == "reflector_template") {
    reflector_template();
} else if (export_part == "delta_preview") {
    // Только для просмотра: разъём + треугольник согласования + начало спирали
    nonprintable_preview();
} else if (export_part == "delta_jig") {
    delta_match_jig();
} else {
    assembly();
}