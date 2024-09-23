$fn=200;


// la manopola montata adesso (13 set 2024) risulta avere un diametro di 1mm maggiore
// della manopola originale, si potrebbe procedere a:
// ridurre extdiam  = 10.5
// ridurre intdiam1 =  9.7
// è anche più lungo per cui
// ridurre intheight2=5.3
// si potrebbe anche stampare in due pezzi:
//  - la manopola senza il tappo
//  - il tappo a parte ma forse non da nessun vantaggio

gdiam=1;
texHeight=0.3;  // Texture Height

clearance=0.2;
extdiam=10.7 - texHeight;   // external diameter was 11.5 - 10.7
intdiam1=9.0 + clearance;   // internal diameter was 9.9
intdiam2=8.0 + clearance;   // internal diameter was 8.4
intheight1=2.5 + clearance;   // internal height
intheight2=5.7 + clearance;   // was 5.8
intheight = intheight1 + intheight2;
extheight = intheight + 0.75;  // external height was 9.5

xystepdiam=0.4;
xystepdeg=15;

markw=1.2;
markh=0.2;

zsteps = 7;             // number of notches in the vertical direction

topscale = 0.83;        // reduction factor for the top knob diameter was 7.8

module knob_top(diam, height, zposition)
{
    // top
    translate([0, 0, zposition])
    linear_extrude(height, scale=topscale)
    circle(d=diam);
}
    

// knob round footprint (before difference to make grooves)
//   extd = external diameter
//   intd = internal diameter
module knob_round_footprint1(extd, intd)
{
    difference()
    {   
        difference()
        {
            circle(d=extd);
            circle(d=intd);
         }
    }
}

// knob round footprint (before difference to make grooves)
//   extd = external diameter
//   intd = internal diameter
//   gd   = groove "diameter"
module knob_round_footprint2(extd, intd, gd)
{
    difference()
    {   
        difference()
        {
            circle(d=extd);
            circle(d=intd);
            translate([intd/2,0,0]) circle(d=gd);
         }
    }
}


// knob grooves footprints
//    stepdeg   step degree of each groove
//    d         diameter where to put the grooves
//    stepd     diameter of the grooves
module knob_grooves_footprint(stepdeg, d, stepd)
{
    for(i =[0 : stepdeg : 360])
        rotate(a=i)
        translate([(d - stepd)/2 + stepd/2 , 0, 0])
        circle(d=stepd);
}    


    
// knob zero line mark
// w = wide
// l = len
// h = height
module knob_mark(w, l, h, zpos)
{
    color("Red", 1.0)
    translate([(extdiam-l)/2, 0, zpos]) linear_extrude(h, scale=topscale/1.1)
    square([l,w], center = true);
}

//
// knob with vertical grooves
module knob_zgrooves()
{
    union()
    {
        linear_extrude(intheight1)
        difference()
        {
            knob_round_footprint1(extdiam, intdiam1);
            knob_grooves_footprint(xystepdeg, extdiam, xystepdiam);
        }
       
        translate([0, 0, intheight1])
        linear_extrude(intheight2)
        difference()
        {
            knob_round_footprint2(extdiam, intdiam2, gdiam);
            knob_grooves_footprint(xystepdeg, extdiam, xystepdiam);
        } 
 
        knob_top(extdiam, extheight-intheight1-intheight2, intheight1+intheight2);        
    }
}

module knob_grooves1()
{
    intheight = intheight1 + intheight2;
    step0 = intheight / zsteps ;
    step1 = intheight / zsteps / 7 * 6;
    step2 = intheight / zsteps / 7;
    union()
    for (i = [0 : 1 : zsteps-1 ]) {
        translate([0, 0, i*step0])
        difference() {
            linear_extrude(step1)
            difference()
            {
                knob_round_footprint(extdiam, intdiam, cutdiam);
                knob_grooves_footprint(xystepdeg, extdiam, xystepdiam);
            }
            vsmooth(-step2);
            if (i != zsteps - 1) vsmooth(step1);
        } 
            
        translate([0, 0, i*step0 + step1])
        linear_extrude(step2)
        if (i == zsteps -1) {
            knob_round_footprint(extdiam, intdiam, cutdiam); 
        } else {
            knob_round_footprint(extdiam - xystepdiam, intdiam, cutdiam); 
        } 
 
    }    
    knob_top(extdiam, extheight-intheight, intheight);        
}


module knob_grooves()
{
    intheight = intheight1 + intheight2;
    step0 = intheight / zsteps ;
    step1 = intheight / zsteps / 7 * 6;
    step2 = intheight / zsteps / 7;
    union()
    for (i = [0 : 1 : zsteps-1 ]) {
//        translate([0, 0, i*step0])
//        difference() {
//            linear_extrude(step1)
//            difference()
//            {
//                knob_round_footprint(extdiam, intdiam, cutdiam);
//                knob_grooves_footprint(xystepdeg, extdiam, xystepdiam);
//            }
            vsmooth(-step2);
            if (i != zsteps - 1) vsmooth(step1);
//        } 
            
        translate([0, 0, i*step0 + step1])
        linear_extrude(step2)
        if (i == zsteps -1) {
            knob_round_footprint(extdiam, intdiam, cutdiam); 
        } else {
            knob_round_footprint(extdiam - xystepdiam, intdiam, cutdiam); 
        } 
 
    }    
    knob_top(extdiam, extheight-intheight, intheight);        
}


module vsmooth(zpos)
{
    intheight = intheight1+intheight2;
    polyl  = intheight / zsteps / 7;
    polyx0 = 0;
    polyy0 = 0;
    polyx1 = 0;
    polyy1 = polyl;
    polyx2 = sin(30) * xystepdiam*1.2;
    polyy2 = sin(60) * xystepdiam*1.2 + polyl;
    polyx3 = polyx2;
    polyy3 = -polyy2 + polyl;
    polyx4 = 0 ;
    polyy4 = 0 ;
    polytransx=(extdiam - xystepdiam)/2 ;

    translate([0, 0, zpos])
    rotate_extrude(angle = 360)
    translate([polytransx,0,0])
    polygon(points=[[polyx0,polyy0], [polyx1, polyy1], [polyx2, polyy2], [polyx3, polyy3], [polyx4,polyy4]]);
}

module hgroovescut()
{
    intheight = intheight1 + intheight2;
    step0 = intheight / zsteps ;
    step1 = intheight / zsteps / 7 * 6;
    step2 = intheight / zsteps / 7;
    union() {
        for (i = [0 : 1 : zsteps-2 ]) {
            vsmooth(i*step0+step0);
        }
    }
}
               

//--- Start of main program
include <../BOSL2/std.scad>
//path = glued_circles(r=15, spread=40, tangent=45);
//vnf = linear_sweep(
//    path, h=40, texture="trunc_pyramids", tex_size=[5,5],
//    tex_depth=1, style="convex");
//vnf_polyhedron(vnf, convexity=10);

path = circle(extdiam/2);
vnf = linear_sweep(
    path, h=intheight, texture="trunc_pyramids", tex_size=[intheight/zsteps,intheight/zsteps],
    tex_depth=texHeight, style="convex");

pathgroove = circle(gdiam/2);
vnfgroove  = linear_sweep(pathgroove, h=intheight + 2);
pathint1 = circle(intdiam1/2);
vnfint1  = linear_sweep(pathint1, h=intheight1+ 1);
pathint2 = circle(intdiam2/2);
vnfint2  = linear_sweep(pathint2, h=intheight + 2);
difference() {
    translate([0, 0, intheight/2]) vnf_polyhedron(vnf, convexity=10);
    translate([0, 0, -1])          vnf_polyhedron(vnfint2, convexity=10);
    translate([0, 0, -1])          vnf_polyhedron(vnfint1, convexity=10);
    translate([intdiam2/2, 0, -1])          vnf_polyhedron(vnfgroove, convexity=10);
}

//translate([20,0,0])
//difference()
//{
//    knob_zgrooves();
//    hgroovescut();
//}

//translate([20,0,0])
knob_top(extdiam, extheight-intheight1-intheight2, intheight1+intheight2);
knob_mark(markw, extdiam / 2, extheight - intheight1 - intheight2, intheight1+intheight2);

