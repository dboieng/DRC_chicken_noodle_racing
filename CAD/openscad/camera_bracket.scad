// DRC IMX219-83 Stereo Camera Adjustable Fixed-Angle Bracket
// Units: mm
//
// Change mount_angle to alter the camera plate angle.
// 90  = perpendicular / vertical
// 100 = tilted further back
// 120 = tilted much further back

$fn = 64;

// ------------------------------------------------------------
// Main adjustable parameters
// ------------------------------------------------------------

mount_angle = 110;          // angle between base plate and camera plate

material_thick = 2.0;

// Base plate
base_width  = 70;
base_depth  = 40;
base_thick  = material_thick;

// Camera plate
camera_plate_width  = 34;  // IMX219-83 board is approx 85mm wide
camera_plate_height = 34;  // IMX219-83 board is approx 24mm tall
camera_plate_thick  = material_thick;

// Camera PCB mounting holes
// These are adjustable because you should check against your real board.
camera_hole_dia = 2.6;     // M2.5 clearance
camera_hole_x_spacing = 21;
camera_hole_z_spacing = 14;

// Base mounting holes
base_hole_dia = 3.1;       // M3 clearance
base_hole_x_spacing = 45;
base_hole_y_spacing = 25;

// Side support triangles / gussets
gusset_thick = material_thick;
gusset_height = 32;
gusset_depth = 32;

// ------------------------------------------------------------
// Helper modules
// ------------------------------------------------------------

module rounded_slot_hole(d, h) {
    cylinder(d = d, h = h);
}

module screw_hole(d) {
    translate([0, 0, -1])
        cylinder(d = d, h = material_thick + 2);
}

// 2D right triangle used for side gussets
module gusset_2d() {
    polygon(points = [
        [0, 0],
        [gusset_depth, 0],
        [0, gusset_height]
    ]);
}

// Camera mounting plate
module camera_plate() {
    difference() {
        cube([
            camera_plate_width,
            camera_plate_thick,
            camera_plate_height
        ], center = false);

        // Camera mounting holes
        // Plate local coordinates:
        // X = camera width
        // Y = thickness
        // Z = camera height
        for (x = [
            camera_plate_width / 2 - camera_hole_x_spacing / 2,
            camera_plate_width / 2 + camera_hole_x_spacing / 2
        ]) {
            for (z = [
                camera_plate_height / 2 - camera_hole_z_spacing / 2,
                camera_plate_height / 2 + camera_hole_z_spacing / 2
            ]) {
                translate([x, -1, z])
                    rotate([-90, 0, 0])
                        cylinder(d = camera_hole_dia, h = camera_plate_thick + 2);
            }
        }

        // Optional centre cable relief slot
        translate([
            camera_plate_width / 2 - 12,
            -1,
            camera_plate_height / 2 - 4
        ])
            cube([24, camera_plate_thick + 2, 8], center = false);
    }
}

// Base mounting plate
module base_plate() {
    difference() {
        cube([base_width, base_depth, base_thick], center = false);

        // Base mounting holes
        for (x = [
            base_width / 2 - base_hole_x_spacing / 2,
            base_width / 2 + base_hole_x_spacing / 2
        ]) {
            for (y = [
                base_depth / 2 - base_hole_y_spacing / 2,
                base_depth / 2 + base_hole_y_spacing / 2
            ]) {
                translate([x, y, -1])
                    cylinder(d = base_hole_dia, h = base_thick + 2);
            }
        }
    }
}

// Side gusset that stays flat on the base
// and follows the same angle as the camera plate
module side_gusset(x_pos) {

    tilt_angle = 90 - mount_angle;

    // Same hinge/pivot line as the camera plate
    y_hinge = base_depth - camera_plate_thick;
    z_base  = base_thick;

    // Bottom edge of gusset stays on top of base plate
    y_front = y_hinge - gusset_depth;

    // Top point follows the angled camera plate
    y_top = y_hinge - gusset_height * sin(tilt_angle);
    z_top = z_base  + gusset_height * cos(tilt_angle);

    // Gusset thickness in X direction
    x0 = x_pos;
    x1 = x_pos + gusset_thick;

    polyhedron(
        points = [
            // Left side triangle
            [x0, y_hinge, z_base],   // 0 rear bottom / hinge
            [x0, y_front, z_base],   // 1 front bottom
            [x0, y_top,   z_top],    // 2 top angled point

            // Right side triangle
            [x1, y_hinge, z_base],   // 3 rear bottom / hinge
            [x1, y_front, z_base],   // 4 front bottom
            [x1, y_top,   z_top]     // 5 top angled point
        ],

        faces = [
            [0, 1, 2],       // left triangle face
            [3, 5, 4],       // right triangle face

            [0, 3, 4, 1],    // bottom face
            [1, 4, 5, 2],    // long sloped face
            [2, 5, 3, 0]     // rear face against camera plate
        ]
    );
}

// ------------------------------------------------------------
// Main bracket assembly
// ------------------------------------------------------------

module camera_bracket() {
    union() {
        // Base
        base_plate();

        // Angled camera plate
        // Pivot is near the rear of the base plate.
        translate([
            (base_width - camera_plate_width) / 2,
            base_depth - camera_plate_thick,
            base_thick
        ])
            rotate([90 - mount_angle, 0, 0])
                camera_plate();

        // Left and right side support gussets
        side_gusset_x_position = 18;
        side_gusset(side_gusset_x_position);
        side_gusset(base_width - side_gusset_x_position - gusset_thick);
    }
}

camera_bracket();