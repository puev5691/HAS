// Габаритная компоновка: две соседние спирали. Не конструкция для печати.
// Размеры в мм; излучение условно вдоль +Z.
$fn=$preview ? 8 : 16;
base_x=174; base_y=148; base_th=3;
wire=4;
turns_low=4.20; turns_high=5.65;
freq_low=635; freq_high=860;
c=299792.458;
edge_gap=5; // зазор между проводниками в плане, не результат РЧ-расчета
r_low=c/freq_low/(2*PI);
r_high=c/freq_high/(2*PI);
center_spacing=r_low+r_high+wire+edge_gap;
module winding(f, turns, col) {
  lambda=c/f; r=lambda/(2*PI); pitch=lambda/4;
  n=ceil(turns*($preview ? 16 : 48));
  color(col) for(i=[0:n-1]) hull() {
    for(j=[i,i+1]) let(t=min(j/n,1)*turns, a=360*t, z=pitch*t)
      translate([r*cos(a),r*sin(a),base_th+z]) sphere(d=wire);
  }
}
color("silver") translate([-base_x/2,-base_y/2,0]) cube([base_x,base_y,base_th]);
// Центр общего габарита спиралей совмещен с центром площадки.
x_low=-(r_high+wire/2+edge_gap/2);
x_high=r_low+wire/2+edge_gap/2;
translate([x_low,0,0]) winding(freq_low,turns_low,"orange");
translate([x_high,0,0]) winding(freq_high,turns_high,"deepskyblue");
echo("center_spacing_mm",center_spacing,"total_width_mm",2*r_low+2*r_high+2*wire+edge_gap);
