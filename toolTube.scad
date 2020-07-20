use <RoundedRegularPolygon.scad>
// Inside Diameter (millimeters)
id = 20;
// Part Length (millimeters)
pl = 32;
// Wall Thickness (millimeters) of parts. Tune to your printer & slicer.
wt = 0.5;
// Which parts to render: inside, outside, or both.
parts=6; // [2:inside, 3:outside, 6:both]
// Between 1 and 5. Bigger is smoother, but slower to render and slice.
resolution = 3; // [1:5]

$fn=6*pow(2,resolution);
if(parts%2==0) translate([(parts%3==0)?1.5*id:0, 0, 3*id/8]) inside();
if(parts%3==0) outside();
p = PI*id/8; // thread Pitch, millimeters
module thread_profile(){
	resize([id/15,id/15,p]) rotate([45,atan(1/sqrt(2))]) cube(1,true);
}
module thread(l, d){ // make a thread, arc length `l` degrees, at Diameter
	for(edge=[1:l*$fn/360]) hull() for(angle=(-360/$fn)*[edge-1, edge])
		rotate(angle) translate([d/2,0,angle*p/360*6]) thread_profile();
}
od = id*(16/15)+2*wt; // Outside Diameter (thread profile diameter is id/15)
module inside(){ // tube, 6 columns of threads, and a cap underneath
	cylinder(h=pl, d=id);
	for(c=[1:6],h=[pl-p/2:-p:p]) rotate(c*60) translate([0,0,h]) thread(30,id);
	translate([0, 0, -3*id/8]) hull(){
		linear_extrude(id/8) RoundedRegularPolygon(6, od/2/cos(30), od/6);
		translate([0, 0, 2*id/8]) cylinder(h=id/8, d1=od, d2=id);
	}
}
module outside(){ // tube, and 6 upside-down threads
	rotate([0,180]) translate([0,0,-pl]) difference(){
		cylinder(h=pl, d=od);
		for(i=[1:6]) rotate(i*360/6) translate([0,0,1.5*p]) thread(120, od);
	}
}
