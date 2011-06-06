#include "include/colors.inc"
global_settings { charset utf8 }

camera
{
   location <0, 0, -5>
   look_at <0, 0, 0>
}
light_source {
   <0, 0, -5>, <1, 1, 1, 1>
   area_light
   <1, 0, 0>, <0, 1, 0>,
   5, 5 
}

union
{
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, 2, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, 1, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, 0, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, -1, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, -2, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, 3, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, 4, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, 5, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, 6, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, -3, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, -4, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, -5, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, -6, 0>
    }
    text
    {
    ttf "font.ttf" "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP",
        0.5, <0, 0, 0>
    translate <-10, -7, 0>
    }
    scale 0.4
    pigment { Blue }
}

