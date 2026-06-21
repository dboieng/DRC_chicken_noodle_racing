// DRC Frame Plate
// Units: mm

$fn = 64;

// Plate dimensions
plate_length = 314 + 10 + 10;   // 334 mm total
plate_width  = 195;
plate_thick  = 3;

// Hole dimensions
hole_diameter = 7.0;
hole_radius   = hole_diameter / 2;

// Hole offsets from the left/right edges
side_a_x_offset = 37.5 + hole_radius;  // 40.75 mm
side_b_x_offset = 60.5 + hole_radius;  // 65.75 mm

// Distance of holes inward from each long side
// Change this if your holes need to be further in/out.
hole_y_inset = 10;


// Row of rectangular holes spaced evenly along Y
module rectangular_hole_row(
    x_center,
    y_start,
    row_length = 280,
    hole_width = 3,
    hole_length = 65,
    hole_count = 3
) {
    gap = (row_length - hole_count * hole_length) / (hole_count + 1);

    for (i = [0 : hole_count - 1]) {
        y_pos = y_start + gap + i * (hole_length + gap);

        translate([
            x_center - hole_width / 2,
            y_pos,
            -1
        ])
            cube([
                hole_width,
                hole_length,
                plate_thick + 2
            ], center = false);
    }
}

// Main model
difference() {
    // Base rectangular plate
    cube([plate_width, plate_length, plate_thick], center = false);

    // Side A holes
    // Near y = 0 side
    translate([side_a_x_offset, hole_y_inset, -1])
        cylinder(h = plate_thick + 2, d = hole_diameter);

    translate([plate_width - side_a_x_offset, hole_y_inset, -1])
        cylinder(h = plate_thick + 2, d = hole_diameter);

    // Side B holes
    // Near y = plate_width side
    translate([side_b_x_offset, plate_length - hole_y_inset, -1])
        cylinder(h = plate_thick + 2, d = hole_diameter);

    translate([plate_width - side_b_x_offset, plate_length - hole_y_inset, -1])
        cylinder(h = plate_thick + 2, d = hole_diameter);
    
    // Cube hole for cables
    translate([plate_width - 20 - 50 , 60 , -1])
        cube([50, 30, plate_thick+2], center = false);
    
    // Cube hole for cables  
    translate([20, 60 , -1])
        cube([50, 30, plate_thick+2], center = false);
    
    // Row of 3 rectangular holes
    rectangular_hole_row(x_center = 10 , y_start = 27);
    
    // Row of 3 rectangular holes
    rectangular_hole_row(x_center = plate_width - 10 , y_start = 27);
}