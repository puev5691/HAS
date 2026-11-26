// Предварительная компоновка двух антенн: только габариты, не РЧ-проект.
// мм; оси совмещены, излучение условно вдоль +Z.
$fn=$preview ? 8 : 16;
base_x=174; base_y=148; base_th=3;
wire=4;
// Число витков выбрано отдельно; максимальный габарит учитывает диаметр провода.
turns_low=4.20;
turns_high=5.65;
freq_low=635; freq_high=860;
c=299792.458;
module winding(f, turns, col) {
  lambda=c/f; r=lambda/(2*PI); pitch=lambda/4;
  n=ceil(turns*($preview ? 16 : 48));
  color(col) for(i=[0:n-1]) hull() {
    for(j=[i,i+1]) let(t=min(j/n,1)*turns, a=360*t, z=pitch*t)
      translate([r*cos(a),r*sin(a),base_th+z]) sphere(d=wire);
  }
}
color("silver") translate([-base_x/2,-base_y/2,0]) cube([base_x,base_y,base_th]);
winding(freq_low,turns_low,"orange");
winding(freq_high,turns_high,"deepskyblue");
