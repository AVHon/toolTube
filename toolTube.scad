use <RoundedRegularPolygon.scad>
id = 20; // Inside Diameter, millimeters
pl = 32; // Part Length, millimeters. Maximum contained length is 2*pl
wt = 0.5; // Wall Thickness, millimeters. Tune to suit your printer+slicer
translate([2*id, 0, 3*id/8]) inner();
outer();
tp = PI*id/8; // Thread Pitch, millimeters
module thread_profile(){
	resize([id/15,id/15,tp]) rotate([45,atan(1/sqrt(2))]) cube(1,true);
}
module thread(a, r){ // make a thread spanning back `a` degrees, at radius r
	s = $fn==0 ? $fa : 360/$fn; // angle Step between cylinder edges
	for(pa=[for(i=[1:a/s]) -s*[i-1,i]]){ // Pair of Angles of cylinder edges
		hull(){ // one thread profile on each edge of the tube cylinder
			rotate(pa[0]) translate([r, 0, pa[0]*tp/360*6]) thread_profile();
			rotate(pa[1]) translate([r, 0, pa[1]*tp/360*6]) thread_profile();
		}
	}
}
od = id*(16/15)+2*wt; // Outside Diameter (thread profile diameter is id/15)
module inner(){ // tube, 6 columns of threads, and a cap at the bottom
	cylinder(h=pl, d=id);
	for(i=[1:6]) rotate(i*360/6) translate([0,0,pl+tp/2])
	for(n=[1:pl/tp-1]) translate([0, 0, -n*tp]) thread(30, id/2);
	translate([0, 0, -3*id/8]) hull(){
		linear_extrude(id/8) RoundedRegularPolygon(6, od/2/cos(30), od/5);
		translate([0, 0, 2*id/8]) cylinder(h=id/8, d1=od, d2=id);
	}
}
module outer(){ // tube, and 6 upside-down threads
	rotate([0,180]) translate([0,0,-pl]) difference(){
		cylinder(h=pl, d=od);
		for(i=[1:6]) rotate(i*360/6) translate([0,0,1.5*tp]) thread(120, od/2);
	}
}

