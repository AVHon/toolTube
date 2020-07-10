use <RoundedRegularPolygon.scad>
id = 20; // Inside Diameter, millimeters
pl = 32; // Part Length, millimeters. Maximum contained length is 2*PL
th = 6; // Thread Height, millimeters. Like metric screw pitch, but 6 threads
wt = 0.5; // Wall Thickness, millimeters. Tune to suit your printer+slicer
module thread_profile(){
	resize([id/15,id/15,th]) rotate([45,-atan(1/sqrt(2))]) cube(1,true);
}
module thread(a, r){ // make a thread spanning back `a` degrees, at radius r
	s = $fn==0 ? $fa : 360/$fn; // angle Step between cylinder edges
	for(pa=[for(i=[-s*floor((a-s)/s):s:0]) [i-s,i]]){ // Pair of Angles
		hull(){ // one thread profile on each edge of the tube cylinder
			rotate(pa[0]) translate([r, 0, pa[0]*th/360*6]) thread_profile();
			rotate(pa[1]) translate([r, 0, pa[1]*th/360*6]) thread_profile();
		}
	}
}
od = id*(16/15)+wt; // Outside Diameter (thread profile diameter is id/15)
module inner(){ // tube, 6 columns of threads, and a cap at the bottom
	cylinder(h=pl, d=id);
	for(i=[1:6]) rotate(i*360/6) translate([0,0,pl+th/2])
	for(n=[1:floor(pl/th)-1]) translate([0, 0, -n*th]) thread(30, id/2);
	translate([0, 0, -3*id/8]) hull(){
		linear_extrude(id/8) RoundedRegularPolygon(6, od/2/cos(30), od/5);
		translate([0, 0, 2*id/8]) cylinder(h=id/8, d1=od, d2=id);
	}
}
translate([1.3*od, 0, 3*id/8]) inner();
module outer(){ // tube, and 6 upside-down threads
	rotate([0,180]) translate([0,0,-pl]) difference(){
		cylinder(h=pl, d=od);
		for(i=[1:6]) rotate(i*360/6) translate([0,0,1.5*th]) thread(120, od/2);
	}
}
outer();

