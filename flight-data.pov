#version 3.7;
#include "colors.inc"
#include "textures.inc"
#include "flight-data.inc"

global_settings {
	assumed_gamma srgb
}

camera {
	location <0, 2, -15>
	look_at <0, 0, 2>
	up <0, 1, 0>
	right <image_width / image_height, 0, 0> // calculate aspect ratio
}

light_source {
	<2, 4, -3>
	color White
}

#declare arrow = union {
	cylinder {
		0, 4*x, 0.5
	}
	cone {
		3.99*x, 1,
		5*x, 0
	}
};

#declare axes = union {
	object {
		arrow
		texture { pigment { color Red } }
	}
	object {
		arrow rotate 90*z
		texture { pigment { color Green } }
	}
	object {
		arrow rotate 90*y
		texture { pigment { color Blue } }
	}
	box {
		-0.5, 0.5
		texture { pigment { color Gray50 } }
	}
};

#macro humidity(value)
#local hum_min = 0;
#local hum_max = 100;
#local hum_y = max(0, min(5, (value - hum_min) / (hum_max - hum_min) * 5));
#end

#macro thermometer(value)
#local temp_min = -20;
#local temp_max = 80;
#local temp_y = max(0, min(5.4, (value - temp_min) / (temp_max - temp_min) * 5));
#local zero_y = -temp_min / (temp_max - temp_min) * 5;
union {
	difference {
		merge {
			sphere { 0, 0.8 }
			cylinder { 0, y*5, 0.5 }
			sphere { y*5, 0.5 }
		}
		merge {
			sphere { 0, 0.7 }
			cylinder { 0, y*5, 0.4 }
			sphere { y*5, 0.4 }
		}
		material { M_Glass2 }
	}
	difference {
		union {
			sphere { 0, 0.699 }
			cylinder { 0, y*5, 0.399 }
			sphere { y*5, 0.399 }
		}
		box { <-1, 0.7 + temp_y, -1>, <1, 6, 1> }
		pigment { color Red }
	}
#if ((zero_y >= 0.8) & (zero_y <= 5))
	difference {
		cylinder { (zero_y + 0.68) * y, (zero_y + 0.72) * y, 0.401 }
		cylinder { (zero_y + 0.68) * y, (zero_y + 0.72) * y, 0.4 }
		pigment { color White }
	}
#end
}
#end

object {
	axes
	rotate craft_orientation
}
object {
	thermometer(temp_h)
	translate -7.8*x
}
object {
	thermometer(temp_p)
	translate -6*x
}
text {
	ttf "DejaVuSans.ttf" datetime(flight_timestamp, "%Y-%m-%dT%H:%M:%SZ")
	0.1, 0
	pigment { White }
	translate <-5, 6, 0>
}
