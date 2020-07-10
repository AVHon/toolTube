use <RoundedRegularPolygon.scad>;
// all lengths are in milimeters
id = 20; // Inside Diameter
wt = 0.5; // Wall Thickness
ml = 65; // Maximum Length of contained objects
ts = 30; // Tab slope, in Degrees
res = 3; // resolution
// end of configurable parameters

c = PI*id; // Circumference
od= id*(16/15); // Outside Diameter (tab profile diameter is id/15)

ph = ml/2; // Part Height (overlap will come from caps)

tr = tan(ts)*c/360; // Tab Rise per degree
nt = floor(6 * ph / (tr*360)); // Number of Tabs in each spiral
echo(str(nt, " rows of tabs in each column."));

$fn=res*6; // Cylinder resolution, segments per circle

module thread_profile(){
	scale(id/15) union(){
		$fn=6;
		cylinder(0.5, 0.5, 0);
		translate ([ 0, 0, -0.5]) cylinder(0.5, 0, 0.5);
	}
}

module tab_column(){
	// make a column of `nt` many tabs, from top to bottom
	for(n=[1:nt]){
		z=ph-n*ph/nt;
		// make one tab
		hull(){
			for(i=[0:360/$fn:30]){ // tabs are 30 degrees long
				rotate(i){
					translate([id/2,0,tr*(i+15)+z]){

						thread_profile();
					}
				}
			}
		}
	}
}

translate([1.5*id,0,0]) union(){
	// make the tube
	cylinder(h=ph, d=id);
	
	// make 6 columns of tabs
	for(i=[00:360/6:360-360/6]){
		rotate(i) tab_column();
	}
			
	// make the cap at the bottom of the tube
	hull(){
		cylinder(h=0.01, d=id);
		cr = od/2/cos(30); // Cap Radius. Hexagon flats will be tangent to OD
		translate([0,0,-1*id/6]){ cylinder(0.1, cr*cos(30));}
		translate([0,0,-3*id/6]){ linear_extrude(id/6){
			RoundedRegularPolygon(6,cr,cr/3);
		}}
	}
}

// difference(){
// 	cylinder(h=ph, r=id/2+wt);
// 	as = [ for(i=[0:360/$fn:(ph/tr)+(360/$fn)]) i];
// 	for(j=[360/6:360/6:360]){
// 		for(i=[1:len(as)-1]){
// 			hull(){
// 				rotate(as[i-1]+j){
// 					translate([id/2+wt,0,tr*as[i-1]]){
// 						scale([id/15,id/15,th]){
// 							union(){
// 								$fn=6;
// 								translate([0,0,0.5]) cylinder(0.5,0.5,0);
// 								cylinder(0.5,0,0.5);
// 							}
// 						}
// 					}
// 				}
// 				rotate(as[i]+j){
// 					translate([id/2+wt,0,tr*as[i]]){
// 						scale([id/15,id/15,th]){
// 							union(){
// 								$fn=6;
// 								translate([0,0,0.5]) cylinder(0.5,0.5,0);
// 								cylinder(0.5,0,0.5);
// 							}
// 						}
// 					}
// 				}
// 			}
// 		}
// 	}
// }

// TODO:
//  - make the outside part
//  - make the outside and inside parts fit each other
//      the innermost parts of the outer piece need to barely touch the outside of the inner piece,
//      and vice versa
