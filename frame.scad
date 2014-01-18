$fn = 50;

wall_thickness = 1.0;
padding = 0.5;

border_h = 15.0;

picture_h = 89.0 + (2 * padding);
picture_w = 65.0 + (2 * padding);
picture_thickness = 0.25;

picture_hole_w = 2.0;

badges_wide = 5;
badges_high = 7;
badge_r = border_h / 2.0;
badge_thickness = 6.0;
badge_sphere_thickness = 3.0;

star_inner_ratio = 0.5;

heart_square_ratio = 0.75;

back_cross_beam_w = 13.0;

picture_border_w = 2.0;
picture_border_h = 1.5 * picture_border_w;
picture_border_angle = atan(picture_border_h / picture_border_w);

frame_h = picture_h + (2 * border_h) - (2 * picture_border_w);
frame_w = picture_w + (2 * border_h) - (2 * picture_border_w);
frame_thickness = (2 * wall_thickness) + picture_thickness + padding + picture_border_h;

frame_opening_h = picture_h - (2 * picture_border_w);
frame_opening_w = picture_w - (2 * picture_border_w);
frame_opening_thickness = wall_thickness + picture_thickness + picture_border_h;

picture_border_cutter_h = frame_thickness;
picture_insert_cutter_h_offset = picture_border_cutter_h * cos(picture_border_angle);

back_hole_h = frame_opening_h - (1.5 * back_cross_beam_w);
back_hole_w = frame_opening_w - back_cross_beam_w;

badge_spacing_w = (frame_w - (border_h * badges_wide)) / (badges_wide - 1);
badge_spacing_h = (frame_h - (border_h * badges_high)) / (badges_high - 1);

debug_corner_cuts = false;

//translate([badge_r, 0, 0])
//	make_star();

//translate([-badge_r, 0, 0])
//	make_heart();

difference() {
	make_frame();
	
	if (debug_corner_cuts) {
		translate([-0.5, -0.5, 0])
			cube([border_h + 1, border_h + 1, border_h]);

		translate([frame_w - border_h - 0.5, -0.5, 0])
			cube([border_h + 1, border_h + 1, border_h]);
	
		translate([-0.5, frame_h - border_h - 0.5, 0])
			cube([border_h + 1, border_h + 1, border_h]);

		translate([frame_w - border_h - 0.5, frame_h - border_h - 0.5, 0])
			cube([border_h + 1, border_h + 1, border_h]);
	}
}

module make_frame() {
	difference() {
		union() {
			// rough out frame
			cube([frame_w, frame_h, frame_thickness]);
	
			// bottom row
			for(i = [0 : badges_wide - 1]) {
				translate([i * (border_h + badge_spacing_w), 0, frame_thickness])
					make_heart();
			}

			// top row
			for(i = [0 : badges_wide - 1]) {
				translate([i * (border_h + badge_spacing_w), frame_h - border_h, frame_thickness])
					make_heart();
			}

			// left column
			for(i = [1 : badges_high - 2]) {
				translate([0, i * (border_h + badge_spacing_h), frame_thickness])
					make_heart();
			}

			// right column
			for(i = [1 : badges_high - 2]) {
				translate([frame_w - border_h, i * (border_h + badge_spacing_h), frame_thickness])
					make_heart();
			}
		}

		// cut picture hole
		translate([border_h, border_h, wall_thickness])
			cube([frame_opening_w, frame_opening_h, frame_opening_thickness + 1]);

		intersection() {
			// cutter blank
			translate([border_h - picture_border_w, 
					border_h - picture_border_w, wall_thickness])
				cube([picture_w + (2 * padding), picture_h + (2 * padding), 
						frame_thickness - (2 * wall_thickness)]);

			// cut picture border sides
			translate([border_h - picture_border_w, 
					picture_h + border_h - picture_border_w, 
					wall_thickness])
				rotate([90, 0, 0])
					make_border_lip_cutter(picture_w, picture_h);

			// cut border top and bottom
			translate([border_h - picture_border_w, border_h - picture_border_w, 
					wall_thickness])
				rotate([90, 0, 90])
					make_border_lip_cutter(picture_h, picture_w);
		}

		// cut picture insert hole
		translate([border_h - picture_border_w, 
				frame_h - border_h - picture_hole_w + picture_border_w, -0.01])
			cube([picture_w, picture_hole_w, wall_thickness + 0.02]);

		// cut hole in backing
		translate([border_h + (back_cross_beam_w / 2.0), 
				border_h + (back_cross_beam_w / 2.0), -0.5])
			cube([back_hole_w, back_hole_h, wall_thickness + 1]);

		// cut lip on left back of frame
		translate([0, frame_h + 0.5, -0.01])
			rotate([90, 0, 0])
				make_frame_lip_cutter(frame_h + 1);

		// cut lip on right back of frame
		translate([frame_w, -0.5, -0.01])
			rotate([90, 0, 180])
				make_frame_lip_cutter(frame_h + 1);
		
		// cut lip on bottom back of frame
		translate([-0.5, 0, -0.01])
			rotate([90, 0, 90])
				make_frame_lip_cutter(frame_w + 1);

		// cut lip on top back of frame
		translate([frame_w + 0.5, frame_h, -0.01])
			rotate([90, 0, -90])
				make_frame_lip_cutter(frame_w + 1);
	}
};

module make_frame_lip_cutter(height) {
	linear_extrude(height=height + 0.01)
		polygon([
				[-0.01, 0],
				[-0.01, frame_thickness - wall_thickness],
				[(frame_thickness - wall_thickness) / 1.5, 0]
			]);
}

module make_border_lip_cutter(width, height) {
	linear_extrude(height=height)
		polygon([
				[0, 0],
				[0, picture_thickness + padding],
				[picture_border_w + (picture_thickness + padding), 
						frame_thickness - (2 * padding)],
				[width - picture_border_w - (picture_thickness + padding), 
						frame_thickness - (2 * padding)],
				[width, picture_thickness + padding],
				[width, 0]
			]);
};

module make_heart() {
	square_w = (sqrt(2) / 2.0) * (heart_square_ratio * badge_r);
	
	translate([badge_r, badge_r, 0])
		difference() {
			make_badge_sphere();

			translate([0, -((badge_r - square_w) / 2.5), 0])
				rotate([0, 0, 45])
					union() {
						translate([-square_w, -square_w, 0])
							cube([2 * square_w, 2 * square_w, badge_thickness]);
						translate([square_w, 0, 0])
							cylinder(badge_thickness, square_w, square_w, [0, 0, 0]);

						translate([0, square_w, 0])
							cylinder(badge_thickness, square_w, square_w, [0, 0, 0]);
					}
		};
};

module make_badge_sphere(extra=0) {
	scale([1, 1, (badge_sphere_thickness + extra) / (badge_r + extra)])
		sphere(badge_r + extra);
};
