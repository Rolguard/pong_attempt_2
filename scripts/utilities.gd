class_name Utilities

# Credit from: https://forum.godotengine.org/t/choosing-random-float-from-two-ranges/53479
static func random_float(min, max) -> float:
	min = abs(min)
	max = abs(max)
	
	var f = randf_range(min, max)
	
	# 50% chance to be even or odd, so random whether the float is negated or not
	var i = randi() % 2
	if i == 0:
		f = -f
	
	return f
