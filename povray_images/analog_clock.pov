#include "include/colors.inc"
#include "include/metals.inc"
#include "include/golds.inc"
#include "include/textures.inc"

global_settings { charset utf8 }

// Looking from -Z direction to center
camera
{
    location <0, 0, -6>
    look_at <0, 0, 0>
}

light_source {
   <-2, 8, -2>, <1, 1, 1, 1>
   area_light
   <1, 0, 0>, <0, 0, 1>,
   5, 5 
}

light_source
{
   <0, 0, -5>, <1, 1, 1, 1>
}

// The side of the clock is a torus, with a box that
// flattens its surface.
union
{
    difference
    {
        torus
        {
            2.0, 0.2
            rotate <90, 0, 0>
        }
        box
        {
            <-5, -5, -0.15>
            <5, 5, -0.35>
        }
    }
    // And it's made of wood
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

// This is the clock's base, so that you can't put your hand
// through the clock.
disc
{
    <0, 0, 0>,
    <0, 0, -1>,
    2.0,

    // The base is white
    pigment { White }
}

// The clock indicators are little knobs scattered around.
// We'll do them in a loop

#declare nob_angle = 0.0;
#declare number_of_nobs = 60; // For every minute
#declare minute = 0.0;

#while (nob_angle < 359.999)
    #if (mod(minute, 15.0) = 0.0)
    box
    {
        <-0.06, -0.07, -0.02>,
        <0.12, 0.07, 0.02>
        translate <1.7, 0, 0>
        rotate <0, 0, nob_angle>
    }
    #else
    #if (mod(minute, 5.0) = 0.0)
    box
    {
        <-0.03, -0.05, -0.02>,
        <0.1, 0.05, 0.02>
        translate <1.7, 0, 0>
        rotate <0, 0, nob_angle>
    }
    #else
    box
    {
        <-0.02, -0.02, -0.02>,
        <0.05, 0.02, 0.02>
        translate <1.7, 0, 0>
        rotate <0, 0, nob_angle>
    }
    #end
    #end
    #declare nob_angle = nob_angle + 360.0 / number_of_nobs;
    #declare minute = minute + 1;
#end


// Then, the hands of the clock
// There's a cylinder in the middle where they are based
cylinder
{
    <0, 0, 0>, <0, 0, -0.1>, 0.1
}

#declare minute_hand = 33.0;
#declare second_hand = 5.0;

// Hands (also cylinders)
// We use a kinky motion blur effect.
// Basically, we render many hands together, but adjust
// alpha so that it looks like it's in motion.

#declare num_images = 50;
#declare counter = 0;
#declare minute_increment = 2.0 / num_images;
#declare second_increment = 3.0 / num_images;
#declare alph = 1.0 - 1 / num_images;

#while (counter < num_images)
cylinder
{
    <0, 0, 0>, 
    <1.3 * cos((minute_hand / 60.0)*pi*2), 
     1.3 * sin((minute_hand / 60.0)*pi*2), 0>
    0.08
    pigment { color <0, 0, 0> transmit alph }
}
cylinder
{
    <0, 0, 0>, 
    <1.7 * cos((second_hand / 60.0)*pi*2), 
     1.7 * sin((second_hand / 60.0)*pi*2), 0>
    0.06
    pigment { color <0, 0, 0> transmit alph }
}
#declare counter = counter + 1;
#declare minute_hand = minute_hand + minute_increment;
#declare second_hand = second_hand + second_increment;
#end

