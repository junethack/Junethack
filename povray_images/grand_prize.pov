#include "trophy.pov"
#include "seal.pov"

// General settings
camera
{
   location <3, 3, -6>
   look_at <0, 1, 0>
}

light_source {
   <-2, 8, -2>, <1, 1, 1, 1>
   area_light
   <1, 0, 0>, <0, 0, 1>,
   5, 5 
}

// Surrounding room (invisible to camera)
box
{
    <-10, -10, -10>, <10, 10, 10>
    pigment { color <0.8, 0.8, 0.8> }
    hollow
    no_image
}

// Points lights++
light_source
{
   <0, 0, -5>, <1, 1, 1, 1>
}

#macro trophymod()
texture { T_Gold_1E } 
#end

#macro trophyfinish()
finish { F_MetalD }
#end

trophy()
seal


