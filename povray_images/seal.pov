
#declare x_co = function(ang) { cos(ang / 180.0 * pi) }
#declare y_co = function(ang) { sin(ang / 180.0 * pi) }

#declare seal = union {

union
{
    prism
    {
       linear_sweep
       0, 0.1, 10
       <x_co(36), y_co(36)>*2.5,
       <x_co(72), y_co(72)>,
       <x_co(108), y_co(108)>*2.5,
       <x_co(144), y_co(144)>,
       <x_co(180), y_co(180)>*2.5,
       <x_co(216), y_co(216)>,
       <x_co(252), y_co(252)>*2.5,
       <x_co(288), y_co(288)>,
       <x_co(324), y_co(324)>*2.5,
       <x_co(0), y_co(0)>
    }
    rotate <0, 198, 0>
    rotate <90, 0, 0>
    pigment { White }
}

    cylinder
    {
        <0, 0, 0.05>
        <0, 0, 0.15>,
        2.6
        pigment { Red }
    }
    cylinder
    {
        <0, 0, 0.1>
        <0, 0, 0.25>,
        2.8
        pigment { White }
    }
    difference
    {
        box
        {
            <-1.4, 0, 0.13>,
            <1.4, -7.5, 0.14>
        }
        box
        {
            <2.0, 2.0, 2.0>
            <-2.0, -2.0, -2.0>
            rotate <0, 0, 45>
            translate <0, -8.0, 0>
        }
        pigment 
        { 
            marble
            color_map
            {
               [0.0 color <1, 1, 1>]
               [0.1 color <1, 1, 1>]
               [0.3 color <0, 0, 1>]
               [1.0 color <0, 0, 1>]
            }
        }
    }
    scale 0.1
    translate <0, 2.5, -0.91>
}

