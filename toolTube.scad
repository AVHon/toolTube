use <RoundedRegularPolygon.scad>;
id = 20; // Inside Diameter, millimeters
wt = 0.5; // Wall Thickness, millimeters
ml = 65; // Maximum Length of contained objects, millimeters
ts = 30; // Thread slope, degrees (90 is axial) (calculated on ID)
res = 4; // resolution, segments per hex face, integer 2 or greater
// This is the end of the configurable parameters!
od = id*(16/15)+wt; // Outside Diameter (thread profile diameter is id/15)
ph = ml/2; // Part Height (extra length for overlap will come from cap)
tr = tan(ts)*PI*id/360; // Tab Rise, millimeters per degree
th = tr*360/6; // Thread profile Height, millimeters
nt = floor((ph-(0.5*th)) / th); // Number of Tabs in each spiral
$fn=res*6; // Cylinder resolution, segments per circle
module thread_profile(){
	$fn=6;
	cylinder(h=th/2, r1=id/30, r2=0);
	scale(-1) cylinder(h=th/2, r1=id/30, r2=0);
}
module tab(a, r){ // make a tab spanning back `a` degrees of arc, at radius r
	s = $fn==0 ? $fa : 360/$fn; // angle Step between cylinder edges
	for(pa=[for(i=[-s*floor((a-s)/s):s:0]) [i-s,i]]){ // Pair of Angles
		hull(){ // one thread profile on each edge of the tube cylinder
			rotate(pa[0]) translate([r, 0, tr*pa[0]]) thread_profile();
			rotate(pa[1]) translate([r, 0, tr*pa[1]]) thread_profile();
		}
	}
}
module tab_column(){ // make a column of `nt` many tabs, from `ph` down
		for(n=[0: nt-1]) translate([0, 0, ph-n*th-th/2]) tab(30, id/2);
}
module inner(){
	cylinder(h=ph, d=id);
	for(i=[1: 6]) rotate(i*360/6) tab_column();
	hull(){ // cap at the bottom of the tube
		translate([0, 0, -1*id/8]) cylinder(h=id/8, r1=od/2, r2=id/2);
		cr = od/2/cos(30); // Cap Radius. Hexagon with flats tangent to OD
		translate([0, 0, -3*id/8]) linear_extrude(id/8)
				RoundedRegularPolygon(6, cr, cr/3);
	}
}
translate([1.5*id, 0, 0]) inner();
module outer(){
	difference(){
		cylinder(h=ph, d=od);
		for(i=[1: 6]) rotate(i*360/6) translate([0, 0, ph]) tab(120, od/2);
	}
}
outer();

