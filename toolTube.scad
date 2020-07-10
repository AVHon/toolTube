use <RoundedRegularPolygon.scad>
ID = 20; // Inside Diameter, millimeters
PL = 32; // Part Length, millimeters. Maximum contained length is 2*PL
WT = 0.5; // Wall Thickness, millimeters. Tune to suit your printer+slicer
TS = 30; // Thread Slope, degrees. 90 is axial. Calculated on ID
od = ID*(16/15)+WT; // Outside Diameter (thread profile diameter is id/15)
tr = tan(TS)*PI*ID/360; // Thread Rise, millimeters per degree
th = tr*360/6; // Thread profile Height, millimeters
module thread_profile(){
	resize([ID/15,ID/15,th]) rotate([45,-atan(1/sqrt(2))]) cube(1,true);
}
module thread(a, r){ // make a thread spanning back `a` degrees, at radius r
	s = $fn==0 ? $fa : 360/$fn; // angle Step between cylinder edges
	for(pa=[for(i=[-s*floor((a-s)/s):s:0]) [i-s,i]]){ // Pair of Angles
		hull(){ // one thread profile on each edge of the tube cylinder
			rotate(pa[0]) translate([r, 0, tr*pa[0]]) thread_profile();
			rotate(pa[1]) translate([r, 0, tr*pa[1]]) thread_profile();
		}
	}
}
module inner(){ // tube, 6 columns of threads, and a cap at the bottom
	cylinder(h=PL, d=ID);
	for(i=[1:6]) rotate(i*360/6) translate([0,0,PL+th/2])
	for(n=[1:floor(PL/th)-1]) translate([0, 0, -n*th]) thread(30, ID/2);
	translate([0, 0, -3*ID/8]) hull(){
		linear_extrude(ID/8) RoundedRegularPolygon(6, od/2/cos(30), od/5);
		translate([0, 0, 2*ID/8]) cylinder(h=ID/8, d1=od, d2=ID);
	}
}
translate([1.3*od, 0, 3*ID/8]) inner();
module outer(){ // tube, and 6 upside-down threads
	rotate([0,180]) translate([0,0,-PL]) difference(){
		cylinder(h=PL, d=od);
		for(i=[1:6]) rotate(i*360/6) translate([0,0,1.5*th]) thread(120, od/2);
	}
}
outer();

