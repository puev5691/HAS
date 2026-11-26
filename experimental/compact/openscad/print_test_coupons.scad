// Пробники для helix_support.scad. Размеры в мм.
/* [Выбор] */
test_part=0; // [0:Канавка,1:Внешнее кольцо,2:Внутреннее кольцо]
antenna=0; // [0:550-720 МГц,1:720-1000 МГц]
wire_d=4; // [3:0.5:5]
wire_clearance=0.35;
wall=3;
fit_clearance=0.25;
$fn=32; // как при точном рендере основной трубы
c=299792.458;
freq=antenna==0?635:860;
tube_r=c/freq/(2*PI)-wire_d*0.25;
inner_r=tube_r-wall;
module arc_piece(r_out,r_in,h) {
 intersection() {
  difference() {cylinder(r=r_out,h=h); translate([0,0,-0.1]) cylinder(r=r_in,h=h+0.2);}
  translate([inner_r-8,-15,0]) cube([12,30,h]);
 }
}
if(test_part==0) {
 // Прямой участок с тем же поперечным профилем, что и канавка на трубе.
 difference() {
  cube([40,16,6]);
  translate([-1,8,6+wire_d*0.25]) rotate([0,90,0]) cylinder(d=wire_d+wire_clearance,h=42);
 }
}
if(test_part==1) {
 // Стенка трубы: принимающая часть соединения.
 difference() { cylinder(r=tube_r,h=12); translate([0,0,-0.1]) cylinder(r=inner_r,h=12.2); }
}
if(test_part==2) {
 // Поясок входит внутрь стенки; зазор задаётся по радиусу.
 difference() { cylinder(r=inner_r-fit_clearance,h=12); translate([0,0,-0.1]) cylinder(r=inner_r-fit_clearance-wall,h=12.2); }
}
