use <RoundedRegularPolygon.scad>;
id = 20; // Inside Diameter, millimeters
wt = 0.5; // Wall Thickness, millimeters
ml = 65; // Maximum Length of contained objects, millimeters
ts = 30; // Tab slope, degrees
res = 4; // resolution, segments per hex face, integer 2 or greater
// This is the end of the configurable parameters!
od = id*(32/30); // Outside Diameter (tab profile radius is id/30)
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
	s = $fn==0 ? $fa : 360/$fn; // angle Step between verticies
	for(ca=[-s*floor((a-s)/s): s: 0]){ // Current Angle to extend tab to
		pa = ca-s; // Previous Angle of a thread profile, to connect to
		echo(pa=pa, ca=ca);
		hull(){
			rotate(pa) translate([r, 0, tr*pa]) thread_profile();
			rotate(ca) translate([r, 0, tr*ca]) thread_profile();
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
		cylinder(h=0.01, d=id);
		translate([0, 0, -1*id/8]) cylinder(h=0.01, r=od/2);
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

