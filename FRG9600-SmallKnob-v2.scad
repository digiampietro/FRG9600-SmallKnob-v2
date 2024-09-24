$fn=200;
include <../BOSL2/std.scad>

// --------- Parametric constant definition

noCap=1;        // =0 knob on top of the original cap; =1 knob directly on the shaft

gdiam=1;        // groove diameter, of the "largest" groove on the "zero" position
texHeight=0.3;  // Texture Height
clearance=0.2;  // clearance to use to avoid interference

extdiam=10.7 - texHeight;               // external diameter
intdiam1=6.0 + clearance + 3*(1-noCap); // internal diameter near the shaft
intdiam2=6.0 + clearance + 2*(1-noCap); // internal diameter near the top
intheight1=2.5 + clearance;             // larger diameter height, near the shaft
intheight2=5.7 + clearance;             // smaller diameter height, near the top
intheight = intheight1 + intheight2;    // internal height
extheight = intheight + 0.75;           // external height

markw=1.2;                              // red mark width

zsteps = 7;             // number of notches in the vertical direction
topscale = 0.83;        // reduction factor for the top knob diameter vs base
nteeths = 18;            // number of theets in the shaft, including the missing teeth at zero and 180° position

// draw the knob top
module knob_top(diam, height, zposition)
{
    translate([0, 0, zposition])
    linear_extrude(height, scale=topscale)
    circle(d=diam);
}
    
// draw the red mark
module knob_mark(w, l, h, zpos)
{
    color("Red", 1.0)
    translate([(extdiam-l)/2, 0, zpos]) linear_extrude(h, scale=topscale/1.1)
    square([l,w], center = true);
}



//--- Start of main program

// knob external cylinder
path = circle(extdiam/2);
vnf = linear_sweep(
        path, h=intheight, texture="trunc_pyramids", 
        tex_size=[intheight/zsteps,intheight/zsteps],
        tex_depth=texHeight, style="convex");

// small groove for each teeth
pathgroove = circle(gdiam/2);
vnfgroove  = linear_sweep(pathgroove, h=intheight);

// bigger groove for zero position
pathgroove2 = circle(gdiam/2/2);
vnfgroove2  = linear_sweep(pathgroove2, h=intheight);

// knob internal cylinder near the shaft
pathint1 = circle(intdiam1/2);
vnfint1  = linear_sweep(pathint1, h=intheight1+ 1);

// knob internal cylinder near the top
pathint2 = circle(intdiam2/2);
vnfint2  = linear_sweep(pathint2, h=intheight + 2);

// the knob main cylinder 
difference() {
    translate([0, 0, intheight/2]) vnf_polyhedron(vnf, convexity=10);
    translate([0, 0, -1])          vnf_polyhedron(vnfint2, convexity=10);
    translate([0, 0, -1])          vnf_polyhedron(vnfint1, convexity=10);
    if (noCap == 0) { 
        translate([intdiam2/2, 0, -1]) vnf_polyhedron(vnfgroove, convexity=10);
    }
}

if (noCap == 1) {
    color("red") translate([ intdiam2/2, 0, 0]) vnf_polyhedron(vnfgroove, convexity=10);
    color("red") translate([-intdiam2/2, 0, 0]) vnf_polyhedron(vnfgroove, convexity=10);

    for(iteeth =[360/nteeths : 360/nteeths : 360-1]) {
        color("red")
        rotate([0, 0, iteeth])
        translate([intdiam2/2, 0, 0])  vnf_polyhedron(vnfgroove2, convexity=10);
    }
}

knob_top(extdiam, extheight-intheight1-intheight2, intheight1+intheight2);
knob_mark(markw, extdiam / 2, extheight - intheight1 - intheight2, intheight1+intheight2);


