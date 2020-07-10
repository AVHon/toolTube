use <RoundedRegularPolygon.scad>;
// all lengths are in milimeters
id = 20; // Inside Diameter
wt = 0.5; // Wall Thickness
ml = 65; // Maximum Length of contained objects
ts = 30; // Tab slope, in Degrees
res = 4; // resolution. Integer 2 or greater
// end of configurable parameters

c = PI*id; // Circumference
od= id*(16/15); // Outside Diameter (tab profile diameter is id/15)

ph = ml/2; // Part Height (overlap will come from caps)

tr = tan(ts)*c/360; // Tab Rise per degree
th = tr*360/6; // Tab Height (6 spirals of threads fill the available space)
echo(th=th, ph=ph);
nt = floor((ph-(0.5*th)) / th); // Number of Tabs in each spiral
echo(str(nt, " rows of tabs in each column."));

$fn=res*6; // Cylinder resolution, segments per circle

module thread_profile(){
	scale([id/15,id/15,th]) union(){
		$fn=6;
		cylinder(0.5, 0.5, 0);
		translate ([ 0, 0, -0.5]) cylinder(0.5, 0, 0.5);
	}
}

module tab(a, r){ // make a tab spanning back `a` degrees of arc, at radius r
	s = 360/$fn; // angle Step of all cylinders
	for(ca=[-a+s:s:0]){ // Current Angle to put a thread profile at
		pa = ca-s; // Previous Angle of a thread profile, to connect to
		hull(){
			rotate(pa) translate([r, 0, tr*pa]) thread_profile();
			rotate(ca) translate([r, 0, tr*ca]) thread_profile();
		}
	}
}

module tab_column(){
	// make a column of `nt` many tabs, from top to bottom
	for(n=[0:nt-1]){
		z=ph-n*th-th/2;
		// make one tab
		translate([0,0,z]) tab(30, id/2);
	}
}

module inner(){
	union(){
		cylinder(h=ph, d=id); // tube
		for(i=[1:6]) rotate(i*360/6) tab_column(); // 6 columns of tabs
				
		// cap at the bottom of the tube
		hull(){
			cylinder(h=0.01, d=id);
			cr = od/2/cos(30); // Cap Radius. Hexagon with flats tangent to OD
			translate([0,0,-1*id/8]) cylinder(h=0.01, r=od/2);
			translate([0,0,-3*id/8]) linear_extrude(id/8){
				RoundedRegularPolygon(6,cr,cr/3);
			}
		}
	}
}
translate([1.5*id,0,0]) inner();

// TODO:
//  - make the outside part
//  - make the outside and inside parts fit each other
//      the innermost parts of the outer piece need to barely touch the outside of the inner piece,
//      and vice versa
