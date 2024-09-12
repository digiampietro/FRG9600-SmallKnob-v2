$fn=200;

////extdiam=10.5;               // external diameter
//extdiam=11.5;               // external diameter
//intdiam1=9.9;               // internal diameter
//intdiam2=8.4;               // internal diameter
//extheight=10.7;             // external height
//intheight1=3;             // internal height
//intheight2=6;             // may be 5 is better and may be extheight must be reduced
//intheight = intheight1 + intheight2;
gdiam=1;

//extdiam=10.5;               // external diameter
extdiam=11.5;               // external diameter
intdiam1=9.9;               // internal diameter
intdiam2=8.4;               // internal diameter
extheight=9.5;             // external height
intheight1=3;             // internal height
intheight2=5.8;             // may be 5 is better and may be extheight must be reduced
intheight = intheight1 + intheight2;



xystepdiam=0.4;
xystepdeg=15;

markw=1.2;
markh=0.2;

zsteps = 7;             // number of notches in the vertical direction

topscale = 0.78;        // reduction factor for the top knob diameter

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
               

// knob_grooves();

//knob_round_footprint1(extdiam,intdiam1);
//knob_round_footprint2(extdiam,intdiam2,gdiam);
//knob_grooves_footprint(xystepdeg, extdiam, xystepdiam);

//hgroovescut();

difference()
{
    knob_zgrooves();
    hgroovescut();
}
//vsmooth(intheight/zsteps*2);

knob_mark(markw, extdiam / 2, extheight - intheight1 - intheight2, intheight1+intheight2);




    
//knob_grooves();
//knob_mark(markw, extdiam / 2, extheight - intheight, intheight);
