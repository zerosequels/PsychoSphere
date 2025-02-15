extends Node3D

var chunk_size = 9
enum direction {ORIGIN,NORTHWARD, SOUTHWARD, EASTWARD, WESTWARD, NO_CHUNK_AVAILABLE}

func chunk_to_grid_coord(point:Vector2i,chunk_id:Vector2i):
	var x = point.x - (chunk_size/2) + chunk_id.x * chunk_size
	var y = point.y - (chunk_size/2)+ chunk_id.y * chunk_size

	return Vector3(x,0,y)

func generate_random_path(extension_point: Vector3, exit_point: Vector3, chunk_id: Vector2i) -> Array:
	var points = [extension_point]
	var num_points = randi_range(2, 5)  # Random number of points between 2 and 5
	for i in range(num_points):
		var random_x = randi_range(0, chunk_size - 1)
		var random_y = randi_range(0, chunk_size - 1)
		var random_point:Vector3 = chunk_to_grid_coord(Vector2i(random_x, random_y), chunk_id)
		points.append(random_point)
	points.append(exit_point)
	return points

func generate_right_angled_path(extension_point: Vector3, exit_point: Vector3, chunk_id: Vector2i, path_out_dir: direction) -> Array:
	var points = [extension_point]
	var current_point = extension_point
	
	# Calculate safe zone boundaries (1 unit away from chunk edges)
	var safe_min = 1
	var safe_max = chunk_size - 2
	
	# Determine initial movement direction based on path direction
	var move_horizontal_first = true
	match path_out_dir:
		direction.NORTHWARD, direction.SOUTHWARD:
			move_horizontal_first = true
		direction.EASTWARD, direction.WESTWARD:
			move_horizontal_first = false
	
	# Calculate number of turns (2 or 3)
	var num_turns = randi_range(2, 3)
	var chunk_thirds = chunk_size / 3
	
	# Create intermediate points for a snake-like pattern
	if move_horizontal_first:
		# First horizontal movement
		var safe_x = chunk_to_grid_coord(Vector2i(chunk_thirds, 0), chunk_id).x
		var first_point = Vector3(safe_x, 0, current_point.z)
		points.append(first_point)
		current_point = first_point
		
		# First vertical movement
		var mid_z = chunk_to_grid_coord(Vector2i(0, chunk_thirds * 2), chunk_id).z
		var second_point = Vector3(current_point.x, 0, mid_z)
		points.append(second_point)
		current_point = second_point
		
		if num_turns > 2:
			# Second horizontal movement
			safe_x = chunk_to_grid_coord(Vector2i(chunk_thirds * 2, 0), chunk_id).x
			var third_point = Vector3(safe_x, 0, current_point.z)
			points.append(third_point)
			current_point = third_point
		
		# Final alignment with exit
		var pre_exit = Vector3(exit_point.x, 0, current_point.z)
		points.append(pre_exit)
		
	else:
		# First vertical movement
		var safe_z = chunk_to_grid_coord(Vector2i(0, chunk_thirds), chunk_id).z
		var first_point = Vector3(current_point.x, 0, safe_z)
		points.append(first_point)
		current_point = first_point
		
		# First horizontal movement
		var mid_x = chunk_to_grid_coord(Vector2i(chunk_thirds * 2, 0), chunk_id).x
		var second_point = Vector3(mid_x, 0, current_point.z)
		points.append(second_point)
		current_point = second_point
		
		if num_turns > 2:
			# Second vertical movement
			safe_z = chunk_to_grid_coord(Vector2i(0, chunk_thirds * 2), chunk_id).z
			var third_point = Vector3(current_point.x, 0, safe_z)
			points.append(third_point)
			current_point = third_point
		
		# Final alignment with exit
		var pre_exit = Vector3(current_point.x, 0, exit_point.z)
		points.append(pre_exit)
	
	# Finally reach the exit point
	points.append(exit_point)
	return points


func generate_multi_turn_snake_path(extension_point: Vector3, exit_point: Vector3, chunk_id: Vector2i, path_out_dir: direction) -> Array:
	var points = [extension_point]
	var current_point = extension_point
	
	# Calculate safe zone boundaries (1 unit away from chunk edges)
	var safe_min = 1
	var safe_max = chunk_size - 2
	
	# Create a grid to track where we've been (to prevent self-intersection)
	var used_positions = {}
	var current_grid_pos = Vector2i(
		int(current_point.x - chunk_id.x * chunk_size + chunk_size/2),
		int(current_point.z - chunk_id.y * chunk_size + chunk_size/2)
	)
	used_positions[current_grid_pos] = true
	
	# Determine initial movement direction based on path direction
	var move_horizontal_first = true
	match path_out_dir:
		direction.NORTHWARD, direction.SOUTHWARD:
			move_horizontal_first = true
		direction.EASTWARD, direction.WESTWARD:
			move_horizontal_first = false
	
	# Calculate number of turns (3 to 5)
	var num_turns = randi_range(3, 5)
	var chunk_quarter = chunk_size / 4
	
	# Track our current direction (1 = horizontal, -1 = vertical)
	var current_direction = 1 if move_horizontal_first else -1
	
	# Create a snake-like pattern with multiple turns
	for turn in range(num_turns):
		var step_size = chunk_quarter * (1 + (turn % 2))  # Alternate between different step sizes
		
		if current_direction == 1:  # Moving horizontally
			# Determine if we should move left or right based on exit point
			var move_right = current_point.x < exit_point.x
			var target_x = current_point.x + (step_size if move_right else -step_size)
			
			# Clamp to safe zone
			target_x = clamp(target_x,
				chunk_to_grid_coord(Vector2i(safe_min, 0), chunk_id).x,
				chunk_to_grid_coord(Vector2i(safe_max, 0), chunk_id).x)
			
			var new_point = Vector3(target_x, 0, current_point.z)
			var new_grid_pos = Vector2i(
				int(target_x - chunk_id.x * chunk_size + chunk_size/2),
				int(current_point.z - chunk_id.y * chunk_size + chunk_size/2)
			)
			
			# Only add point if we haven't been here
			if !used_positions.has(new_grid_pos):
				points.append(new_point)
				current_point = new_point
				used_positions[new_grid_pos] = true
		else:  # Moving vertically
			# Determine if we should move up or down based on exit point
			var move_up = current_point.z < exit_point.z
			var target_z = current_point.z + (step_size if move_up else -step_size)
			
			# Clamp to safe zone
			target_z = clamp(target_z,
				chunk_to_grid_coord(Vector2i(0, safe_min), chunk_id).z,
				chunk_to_grid_coord(Vector2i(0, safe_max), chunk_id).z)
			
			var new_point = Vector3(current_point.x, 0, target_z)
			var new_grid_pos = Vector2i(
				int(current_point.x - chunk_id.x * chunk_size + chunk_size/2),
				int(target_z - chunk_id.y * chunk_size + chunk_size/2)
			)
			
			# Only add point if we haven't been here
			if !used_positions.has(new_grid_pos):
				points.append(new_point)
				current_point = new_point
				used_positions[new_grid_pos] = true
		
		# Switch direction for next turn
		current_direction *= -1
	
	# Add final points to align with exit
	var pre_exit_1 = Vector3(current_point.x, 0, exit_point.z)
	var pre_exit_2 = Vector3(exit_point.x, 0, exit_point.z)
	points.append(pre_exit_1)
	points.append(pre_exit_2)
	points.append(exit_point)
	return points

func generate_arc_based_curved_path(extension_point: Vector3, exit_point: Vector3, chunk_id: Vector2i) -> Array:
	var points = [extension_point]
	var current_point = Vector3(extension_point.x, extension_point.y, extension_point.z)
	var exit_point_v3 = Vector3(exit_point.x, exit_point.y, exit_point.z)
	
	# Set center point to chunk center
	var center_point = chunk_to_grid_coord(Vector2i(chunk_size/2, chunk_size/2), chunk_id)
	
	# Calculate maximum safe radius (distance to closest chunk border - 1)
	var max_radius = (chunk_size / 2.0) - 1.0
	
	# Calculate minimum radius needed to reach both points
	var dist_to_start = current_point.distance_to(center_point)
	var dist_to_end = exit_point_v3.distance_to(center_point)
	var min_radius = max(dist_to_start, dist_to_end)
	
	# Choose a radius between min and max
	var radius = clamp(min_radius, min_radius, max_radius)
	
	# Calculate start and end angles relative to center
	var start_angle = atan2(current_point.z - center_point.z, current_point.x - center_point.x)
	var end_angle = atan2(exit_point_v3.z - center_point.z, exit_point_v3.x - center_point.x)
	
	# Determine which direction to arc based on exit direction
	var angle_diff = end_angle - start_angle
	if angle_diff < 0:
		angle_diff += 2 * PI
	
	# We want the longer arc, so if the difference is less than PI,
	# we should go the other way around to get the longer path
	var clockwise = angle_diff < PI
	
	# Ensure we take the longer arc path (more than 180 degrees)
	if clockwise:
		while end_angle > start_angle:
			end_angle -= 2 * PI
		# Make sure we have a negative difference greater than PI
		if start_angle - end_angle < PI:
			end_angle -= 2 * PI
	else:
		while end_angle < start_angle:
			end_angle += 2 * PI
		# Make sure we have a positive difference greater than PI
		if end_angle - start_angle < PI:
			end_angle += 2 * PI
	
	# Use more points for smoother curves
	var num_points = 24  # Fixed number for smooth semicircles
	var angle_step = (end_angle - start_angle) / num_points
	
	# Generate points along the arc
	for i in range(1, num_points):
		var angle = start_angle + angle_step * i
		var point_x = center_point.x + radius * cos(angle)
		var point_z = center_point.z + radius * sin(angle)
		
		var new_point = Vector3(point_x, 0, point_z)
		points.append(new_point)
	
	# Add exit point
	points.append(exit_point)
	return points

func generate_diagonal_zigzag_path(extension_point: Vector3, exit_point: Vector3, chunk_id: Vector2i) -> Array:
	var points = [extension_point]
	var current_point = Vector3(extension_point.x, extension_point.y, extension_point.z)
	var exit_point_v3 = Vector3(exit_point.x, exit_point.y, exit_point.z)
	
	# Calculate safe zone boundaries
	var safe_min = 1
	var safe_max = chunk_size - 2
	
	# Calculate total distance to cover
	var total_distance = current_point.distance_to(exit_point_v3)
	
	# Determine number of zigzags based on distance
	var num_zigzags = mini(4, maxi(2, int(total_distance / (chunk_size / 3.0))))
	
	# Calculate step sizes
	var dx = (exit_point_v3.x - current_point.x) / num_zigzags
	var dz = (exit_point_v3.z - current_point.z) / num_zigzags
	
	# Create zigzag pattern
	for i in range(num_zigzags - 1):
		# Calculate next point with alternating offset
		var offset = chunk_size / 4.0 * (1 if i % 2 == 0 else -1)
		var next_point = Vector3(
			current_point.x + dx,
			0,
			current_point.z + dz + offset
		)
		
		# Clamp point within safe boundaries
		next_point.x = clamp(next_point.x,
			chunk_to_grid_coord(Vector2i(safe_min, 0), chunk_id).x,
			chunk_to_grid_coord(Vector2i(safe_max, 0), chunk_id).x)
		next_point.z = clamp(next_point.z,
			chunk_to_grid_coord(Vector2i(0, safe_min), chunk_id).z,
			chunk_to_grid_coord(Vector2i(0, safe_max), chunk_id).z)
		
		points.append(next_point)
		current_point = next_point
	
	# Add exit point
	points.append(exit_point)
	return points
