use <RoundedRegularPolygon.scad>
// Inside Diameter (millimeters)
id = 20;
// Length (millimeters)
l = 32;
// Wall Thickness (millimeters) of parts. Tune to your printer & slicer.
wt = 0.5;
parts=6; // [2:inside, 3:outside, 6:inside and outside]
resolution = 3; // [1:5]
$fn=6*pow(2,resolution);
od = id*(16/15)+2*wt; // Outside Diameter (thread profile diameter is id/15)
if(parts%2==0) translate([(parts%3==0)?1.5*id:0, 0, 3*id/8]) inside();
if(parts%3==0) outside();
p = PI*id/8; // thread Pitch, millimeters
module thread_profile(){
	resize([id/15,id/15,p]) rotate([45,atan(1/sqrt(2))]) cube(1,true);
}
module thread(l, d){ // make a thread, arc length `l` degrees, at Diameter
	for(edge=[1:l*$fn/360]) hull() for(angle=(-360/$fn)*[edge-1, edge])
		rotate(angle) translate([d/2,0,angle*p/60]) thread_profile();
}
module inside(){ // tube, 6 Columns of threads, and a cap underneath
	cylinder(h=l, d=id);
	for(c=[1:6],z=[l-p/2:-p:p]) rotate(c*60) translate([0,0,z]) thread(30,id);
	hull() for(i=[0:2]) translate([0,0,-(i+1)*id/8]) linear_extrude(id/8)
		RoundedRegularPolygon(i==0?$fn:6, i==0?id/2:od/2/cos(30), od/(4*i-2));
}
module outside(){ // tube, and 6 upside-down threads
	rotate([0,180]) translate([0,0,-l]) difference(){
		cylinder(h=l, d=od);
		for(i=[1:6]) rotate(i*60) translate([0,0,1.5*p]) thread(120, od);
	}
}
