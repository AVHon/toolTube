use <RoundedRegularPolygon.scad>;
// all lengths are in milimeters
id = 20; // Inside Diameter
wt = 0.5; // Wall Thickness
ml = 65; // Maximum Length of contained objects
ts = 30; // Tab slope, in Degrees
res = 3; // resolution
// end of configurable parameters

r = id/2; // Radius
c = PI*id; // Circumference

ph = ml/2; // Part Height (overlap will come from caps)

tr = tan(ts)*c/360; // Tab Rise per degree
th = tr*20; // Height of a Tab
nt = floor(6 * ph / (tr*360)); // Number of Tabs in each spiral
echo(str(nt, " rows of tabs in each column."));

$fn=res*6; // Cylinder resolution, segments per circle

module thread_profile(){
	scale([id/15,id/15,th]) union(){
		$fn=6;
		cylinder(0.5, 0.5, 0);
		translate ([ 0, 0, -0.5]) cylinder(0.5, 0, 0.5);
	}
}

translate([1.5*id,0,0]) union(){
	// make the tube
	linear_extrude(ph){
			circle(r);
	}
	
	// make 6 columns of tabs
	for(j=[00:360/6:360-360/6]){
		// make a column of up to `nt` tabs
		for(k=[ph-ph/nt : -ph/nt : ph-nt*ph/nt]){
			// make one tab
			hull(){
				for(i=[15:360/$fn:45]){
					rotate(i+j-15){
						translate([r,0,tr*i+k]){
							thread_profile();
						}
					}
				}
			}
		}
	}
			
	// make the cap at the bottom of the tube
	hull(){
		cylinder(0.1, r);
		cr = r*1.3; // Cap Radius
		translate([0,0,-1*r/3]){ cylinder(0.1, cr*cos(30));}
		translate([0,0,-3*r/3]){ linear_extrude(r/3){
			RoundedRegularPolygon(6,cr,cr/3);
		}}
	}
}

difference(){
	cylinder(h=ph, r=id/2+wt);
	as = [ for(i=[0:360/$fn:(ph/tr)+(360/$fn)]) i];
	for(j=[360/6:360/6:360]){
		for(i=[1:len(as)-1]){
			hull(){
				rotate(as[i-1]+j){
					translate([id/2+wt,0,tr*as[i-1]]){
						scale([id/15,id/15,th]){
							union(){
								$fn=6;
								translate([0,0,0.5]) cylinder(0.5,0.5,0);
								cylinder(0.5,0,0.5);
							}
						}
					}
				}
				rotate(as[i]+j){
					translate([id/2+wt,0,tr*as[i]]){
						scale([id/15,id/15,th]){
							union(){
								$fn=6;
								translate([0,0,0.5]) cylinder(0.5,0.5,0);
								cylinder(0.5,0,0.5);
							}
						}
					}
				}
			}
		}
	}
}

// TODO:
//  - make the outside part
//  - make the outside and inside parts fit each other
//      the innermost parts of the outer piece need to barely touch the outside of the inner piece,
//      and vice versa
