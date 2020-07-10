use <RoundedRegularPolygon.scad>;
id = 20; // Inside Diameter, millimeters
wt = 0.5; // Wall Thickness, millimeters
ml = 65; // Maximum Length of contained objects, millimeters
ts = 30; // Tab slope, degrees
// This is the end of the configurable parameters!
od = id*(32/30); // Outside Diameter (tab profile radius is id/30)
ph = ml/2; // Part Height (extra length for overlap will come from cap)
tr = tan(ts)*PI*id/360; // Tab Rise, millimeters per degree
th = tr*360/6; // Thread profile Height, millimeters
nt = floor((ph-(0.5*th)) / th); // Number of Tabs in each spiral
module thread_profile(){ // uses approximations of cube angles and distances
	scale([1.2*id/30,1.2*id/30,th/1.7]) rotate([45,-35,0]) cube(1,center=true);
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
				RoundedRegularPolygon(6, cr, cr/3, $fn=$fn==0?360/$fa:$fn);
	}
}
translate([1.5*id, 0, 0]) inner();
module outer(){
	scale([-1,1,-1]) translate([0,0,-ph]) difference(){
		cylinder(h=ph, d=od);
		for(i=[1: 6]) rotate(i*360/6) translate([0, 0, 90*tr]) tab(120, od/2);
	}
}
outer();

