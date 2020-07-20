use <RoundedRegularPolygon.scad>
// Inside Diameter (millimeters)
id = 20;
// Length (millimeters)
l = 32;
// Wall Thickness (millimeters) of parts. Tune to your printer & slicer.
wt = 0.5;
parts = 6; // [2:inside, 3:outside, 6:inside and outside]
resolution = 3; // [1:5]
$fn = 6*pow(2,resolution);
p = PI*id/8; // thread Pitch, millimeters
tprofile = [id/15,id/15,p]; // size of thread profile
od = id+tprofile.x+2*wt; // Outside Diameter
module thread(a, d){ // make a thread, spanning Arc degrees, at Diameter
	for(edge=[1:a*$fn/360]) hull() for(angle=(-360/$fn)*[edge-1, edge])
		rotate(angle) translate([d/2,0,angle*p/60])
			resize(tprofile) rotate([45,atan(1/sqrt(2))]) cube(1,true);
}
// Inside part is a tube, 6 Columns of threads, and a cap underneath
if(parts%2==0) translate([(parts%3==0)?1.5*id:0, 0, 3*id/8]){
	cylinder(h=l, d=id);
	for(c=[1:6],z=[l-p/2:-p:p]) rotate(c*60) translate([0,0,z]) thread(30,id);
	hull() for(i=[1:3]) translate([0,0,-i*id/8]) linear_extrude(id/8)
		RoundedRegularPolygon(i==1?$fn:6, i==1?id/2:od/2/cos(30), od/(4*i-6));
}
// Outside part is a tube, and 6 upside-down threads
if(parts%3==0) rotate([0,180]) translate([0,0,-l]) difference(){
		cylinder(h=l, d=od);
		for(i=[1:6]) rotate(i*60) translate([0,0,1.5*p]) thread(120, od);
}
