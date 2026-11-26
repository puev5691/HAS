// Экспериментальная несущая труба для спиральной антенны, размеры в мм.
// Только механическая заготовка: РЧ-геометрия, крепеж и материал требуют проверки.
/* [Антенна] */
antenna = 0; // [0:550-720 МГц,1:720-1000 МГц]
wire_d = 4; // [3:0.5:5]
wire_clearance = 0.35;
/* [Печать и крепление] */
part = 0; // [0:Сборка,1:Нижняя секция с дном,2:Средняя секция,3:Верхняя секция]
section_count = 3; // три секции, экспортируются по отдельности
wall = 3;
bottom_thickness = 5;
bolt_hole = 6.5;
joint_length = 12;
fit_clearance = 0.25; // радиальный зазор
/* [Качество] */
segments_per_turn = 48; // [16:1:96]
$fn = $preview ? 16 : 32;
c=299792.458;
freq=antenna==0 ? 635 : 860;
turns=antenna==0 ? 4.20 : 5.65;
lambda=c/freq;
wire_center_radius=lambda/(2*PI);
pitch=lambda/4;
helix_length=turns*pitch;
// В предыдущей компоновке радиус относится к оси провода.
tube_r=wire_center_radius-wire_d*0.25;
inner_r=tube_r-wall;
section_h=helix_length/section_count;
groove_r=(wire_d+wire_clearance)/2;
groove_axis_r=wire_center_radius;
assert(section_count>=3 && floor(section_count)==section_count, "Нужно минимум 3 секции");
assert(inner_r>joint_length/2 && wall>groove_r, "Проверьте стенку и размеры канавки");
assert(bottom_thickness+section_h+joint_length<=250, "Секция слишком длинна для печати");
assert(fit_clearance>0 && inner_r-fit_clearance-wall>0, "Проверьте соединение");
// Канавка строится одним винтовым телом для каждой секции.
module groove(z0, z1) {
  start_t=(z0-bottom_thickness)/pitch;
  angle=360*start_t;
  revolutions=(z1-z0)/pitch;
  translate([0,0,z0]) rotate([0,0,angle])
    linear_extrude(height=z1-z0, twist=-360*revolutions, slices=max(8,ceil(revolutions*segments_per_turn)), convexity=10)
      translate([groove_axis_r,0]) circle(r=groove_r, $fn=12);
}
module raw_section(i) {
  zmin=i==0 ? 0 : bottom_thickness+i*section_h;
  zmax=bottom_thickness+(i+1)*section_h;
  h=zmax-zmin;
  translate([0,0,-zmin]) union() {
    difference() {
      translate([0,0,zmin]) cylinder(r=tube_r,h=h);
      translate([0,0,max(zmin,bottom_thickness)]) cylinder(r=inner_r,h=zmax-max(zmin,bottom_thickness)+0.1);
      if(i==0) translate([0,0,-0.1]) cylinder(d=bolt_hole,h=bottom_thickness+0.2);
      groove(max(bottom_thickness,zmin-0.2),min(bottom_thickness+helix_length,zmax+0.2));
    }
    if(i<section_count-1) translate([0,0,zmax]) difference() {
      cylinder(r=inner_r-fit_clearance,h=joint_length);
      translate([0,0,-0.1]) cylinder(r=inner_r-fit_clearance-wall,h=joint_length+0.2);
    }
    // Перемычка связывает поясок со стенкой; без неё поясок отделён зазором.
    if(i<section_count-1) translate([0,0,zmax-1]) difference() {
      cylinder(r=inner_r+0.8,h=1.5);
      translate([0,0,-0.1]) cylinder(r=inner_r-fit_clearance-wall,h=1.7);
    }
  }
}
module section(i) { raw_section(i); }
module shell() {
  for(i=[0:section_count-1])
    translate([0,0,i==0?0:bottom_thickness+i*section_h]) section(i);
}
if(part==0) shell();
else if(part==1) section(0);
else if(part==2) section(1);
else if(part==3) section(section_count-1);
echo("frequency_MHz",freq,"turns",turns,"pitch_mm",pitch,"tube_outer_diameter_mm",2*tube_r,"height_mm",helix_length+bottom_thickness,"section_count",section_count);
