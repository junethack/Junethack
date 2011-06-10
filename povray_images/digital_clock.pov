#include "include/colors.inc"
#include "include/metals.inc"
#include "include/golds.inc"
#include "include/textures.inc"

camera
{
    location <0, 0, -16>
    look_at <0, 0, 0>
}

light_source {
   <-8, 8, -4>, <1, 1, 1, 1>
   area_light
   <1, 0, 0>, <0, 0, 1>,
   5, 5 
}

light_source
{
   <0, 0, -5>, <1, 1, 1, 1>
}

box
{
<-6.5, -3, -2.2>, <6.5, -2, 2.2>
    pigment
    {
        Tan_Wood
        scale 0.2
    }
    normal
    {
        gradient x
        normal_map 
        {
            [0.0 marble turbulence 0.7]
            [1.0 marble turbulence 0.7]
        }
        scale 0.3
    }
}

difference
{
    box
    {
        <-6, -2, -2>, <6, 2, 2>
        pigment { color Black }
    }
    box
    {
        <-5.6, -1.6, -1.6>, <5.6, 1.6, -4.0>
        pigment { color White }
    }
}

#declare indicator = mesh
{
    triangle
    {
        <-0.2, 0.0, -1.7>
        <0.0, 0.2, -1.7>
        <0.0, -0.2, -1.7>
    }
    triangle
    {
        <0.0, 0.2, -1.7>
        <1.0, 0.2, -1.7>
        <0.0, -0.2, -1.7>
    }
    triangle
    {
        <0.0, -0.2, -1.7>
        <1.0, -0.2, -1.7>
        <1.0, 0.2, -1.7>
    }
    triangle
    {
        <1.2, 0.0, -1.7>
        <1.0, 0.2, -1.7>
        <1.0, -0.2, -1.7>
    }
    pigment { color Black }
}

// We'll use the number 2135
union
{
// 2
object { indicator rotate <0, 0, 0> translate <0, 0, 0> }
object { indicator rotate <0, 0, 90> translate <1.4, 0.3, 0> }
object { indicator rotate <0, 0, 0> translate <0, 1.6, 0> }
object { indicator rotate <0, 0, 90> translate <-0.3, -1.4, 0> }
object { indicator rotate <0, 0, 0> translate <0, -1.8, 0> }

// 1
object { indicator rotate <0, 0, 90> translate <1.4+2.3, 0.3, 0> }
object { indicator rotate <0, 0, 90> translate <1.4+2.3, -1.4, 0> }

// 3
object { indicator rotate <0, 0, 90> translate <1.4+4.6, 0.3, 0> }
object { indicator rotate <0, 0, 90> translate <1.4+4.6, -1.4, 0> }
object { indicator rotate <0, 0, 0> translate <4.6, 0, 0> }
object { indicator rotate <0, 0, 0> translate <4.6, 1.6, 0> }
object { indicator rotate <0, 0, 0> translate <4.6, -1.8, 0> }

// 5
object { indicator rotate <0, 0, 0> translate <6.9, 0, 0> }
object { indicator rotate <0, 0, 90> translate <6.9-0.3, 0.3, 0> }
object { indicator rotate <0, 0, 0> translate <6.9, 1.6, 0> }
object { indicator rotate <0, 0, 90> translate <6.9+1.4, -1.4, 0> }
object { indicator rotate <0, 0, 0> translate <6.9, -1.8, 0> }

scale <0.7, 0.7, 1.0>
translate <-0.6, 0, 0>
}

