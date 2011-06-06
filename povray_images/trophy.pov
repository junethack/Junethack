#include "include/colors.inc"
#include "include/metals.inc"
#include "include/golds.inc"
#include "include/textures.inc"

global_settings { charset utf8 }

// THE TROPHY with the pedestal and plating
#macro trophy()
union {

// TROPHY CUP 
union
{
    // cup part (no handles)
    difference
    {
        lathe
        {
            cubic_spline
            13,
            <0, 0>,
            <0.9, 0>,
            <0.3, 0.3>,
            <0.2, 0.7>,
            <0.2, 0.9>,
            <0.3, 1.0>,
            <0.2, 1.1>,
            <0.2, 1.3>,
            <0.6, 1.8>,
            <0.8, 3.1>,
            <0, 3.1>,
            <0, 0.0>
            <0, 0>
        }
        box
        {
            <-2, 3.0, -2>
            <2, 3.5, 2>
        }
        sphere
        {
           <0, 3.1, 0>, 0.9 
        }
    }
    // Handles
    union
    {
        #macro handle()
        sphere_sweep
        {
            cubic_spline
            8
            <-0.9, 2.2>, 0.01
            <-0.9, 2.3>, 0.02
            <-0.85, 2.6>, 0.03
            <-1.15, 2.6>, 0.04
            <-1.2, 2.2>, 0.04
            <-0.3, 1.3>, 0.03
            <-0.6, 1.3>, 0.02
            <-1.0, 1.6>, 0.01
            tolerance 1
        }
        #end
        handle()
        union
        {
            handle()
            rotate <0, 180, 0>
        }
    }
    trophymod()
    trophyfinish()
}

// Marble block on which the trophy stands on
union
{
    // Slice off the box from edges and union with cylinders there instead
    union
    {
        difference
        {
            // this next box is the main body of the block
            box
            {
                <-1.1, -0.9, -1.1>
                <1.1, 0, 1.1>
            }
            // and these are subtractions from it
            box
            {
                <-1.2, -0.1, -1.2>
                <1.2, 0.1, -1.0>
            }
            box
            {
                <-1.2, -0.1, -1.2>
                <-1.0, 0.1, 1.2>
            }
            box
            {
                <1.2, -0.1, -1.2>
                <1.0, 0.1, 1.2>
            }
            box
            {
                <-1.2, -0.1, 1.2>
                <1.2, 0.1, 1.0>
            }
            // sides on y-axis
            box
            {
                <1.0, -1.1, 1.0>
                <1.2, 0.1, 1.2>
            }
            box
            {
                <-1.0, -1.1, 1.0>
                <-1.2, 0.1, 1.2>
            }
            box
            {
                <-1.0, -1.1, -1.0>
                <-1.2, 0.1, -1.2>
            }
            box
            {
                <1.0, -1.1, -1.0>
                <1.2, 0.1, -1.2>
            }
        }
        cylinder
        {
            <-1.0, -0.1, -1.0>
            <-1.0, -0.1, 1.0>
            0.1
        }
        cylinder
        {
            <1.0, -0.1, -1.0>
            <1.0, -0.1, 1.0>
            0.1
        }
        cylinder
        {
            <1.0, -0.1, -1.0>
            <-1.0, -0.1, -1.0>
            0.1
        }
        cylinder
        {
            <-1.0, -0.1, -1.0>
            <1.0, -0.1, -1.0>
            0.1
        }
        // cylinders on y-axis
        cylinder
        {
            <1.0, -0.9, -1.0>
            <1.0, -0.1, -1.0>
            0.1
        }
        cylinder
        {
            <-1.0, -0.9, -1.0>
            <-1.0, -0.1, -1.0>
            0.1
        }
        cylinder
        {
            <1.0, -0.9, 1.0>
            <1.0, -0.1, 1.0>
            0.1
        }
        cylinder
        {
            <-1.0, -0.9, 1.0>
            <-1.0, -0.1, 1.0>
            0.1
        }
        sphere
        {
            <-1.0, -0.1, -1.0>
            0.1
        }
        sphere
        {
            <1.0, -0.1, -1.0>
            0.1
        }
        sphere
        {
            <1.0, -0.1, 1.0>
            0.1
        }
        sphere
        {
            <-1.0, -0.1, 1.0>
            0.1
        }
    }
    finish { specular 0.9 }
    pigment { 
        granite
        color_map
        {
            [0.0 color <0.7, 0.7, 0.7>]
            [1.0 color <0.4, 0.4, 0.4>]
        }
    }
    normal
    {
        granite 0.15
        scale 1.0
    }
}

// THE WOODEN PLATE ON WHICH THE MARBLE BLOCK SITS ON
union
{
    box
    {
        <-1.2, -1.0, -1.2>
        <1.2, -0.8, 1.2>
    }
    pigment {
        Tan_Wood
        scale 0.2
    }
    finish { specular 0.4 }
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


// Gold plate
union
{
    difference
    {
        box
        {
            <-0.8, -0.7, -0.5>
            <0.8, -0.3, -1.15>
            texture { T_Gold_1B }
            finish { F_MetalD }
        }
        // carved text
        union
        {
            text
            {
                ttf "font.ttf" "          @      "
                    2.5, <0, 0, 0>
            }
            scale 0.2
            translate <-0.75, -0.5, -1.61>
            pigment { Black }
        }
        union
        {
            text
            {
                ttf "font.ttf" " a thousand corpses for you ", 2.5, <0,0,0>
            }
            scale 0.1
            translate <-0.71, -0.65, -1.35>
            pigment { Black }
        }
    }
}

}
#end

