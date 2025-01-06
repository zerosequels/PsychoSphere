extends Node

var cursor: Vector3i

func generate_chunk(path,advancement_options):

	if advancement_options.is_empty():
		print("ERROR NO CHUNKS TO OUTPUT TO")
		return
	var origin_dir = path.get_origin_dir()
	var terminal_dir = advancement_options.pick_random()
	var terminal_point
	var starting_point = Vector3i(path.get_terminal_point())
	print(starting_point)
	var points = []
	var next_chunk_id 

	#Change advancement option to instead grab a list of available directions from the path object
	#Give the path object a chunk dictionary so it knows which chunks are taken vs which are available

	#starting_point = Vector3(x,y,z)
	#shift the starting point forward by one based on the direction of the originating chunk
	match origin_dir:
		1:#North
			starting_point.z = starting_point.z + 1
			next_chunk_id = Vector2i(path.chunk_id.x,path.chunk_id.y + 1)
		2:#South
			starting_point.z = starting_point.z - 1
			next_chunk_id  = Vector2i(path.chunk_id.x,path.chunk_id.y - 1)
		3:#East
			starting_point.x = starting_point.x - 1
			next_chunk_id = Vector2i(path.chunk_id.x - 1,path.chunk_id.y)
		4:#West
			starting_point.x = starting_point.x + 1
			next_chunk_id = Vector2i(path.chunk_id.x + 1,path.chunk_id.y)
	
		
	points.append(starting_point)
	
	#calculate ending point based on starting point and direction
	var offset = randi_range(1,7)
	
	#var chunk_id = next_chunk_id
	var chunk_size = 9
	#var x_coord = (offset - (chunk_size/2)+ chunk_id.x * chunk_size) + 4
	#var z_coord = (offset - (chunk_size/2)+ chunk_id.y * chunk_size) + 4
	
	
	match terminal_dir:
		1:#North
			#print("terminal_dir is north")
			path.set_origin_dir(2)
			path.set_terminal_dir(1)
			var chunk_id = path.get_advancing_chunk_id()
			#var chunk_id = next_chunk_id
			terminal_point = Vector3i((chunk_id.x*chunk_size)+offset,0,chunk_id.y*chunk_size)
		2:#South
			#print("terminal_dir is south")
			path.set_origin_dir(1)
			path.set_terminal_dir(2)
			var chunk_id = path.get_advancing_chunk_id()
			#var chunk_id = next_chunk_id
			terminal_point = Vector3i((chunk_id.x*chunk_size)+offset,0,(chunk_id.y*chunk_size)+8)
		3:#East
			#print("terminal_dir is east")
			
			path.set_origin_dir(4)
			path.set_terminal_dir(3)
			var chunk_id = path.get_advancing_chunk_id()
			#var chunk_id = next_chunk_id
			terminal_point = Vector3i((chunk_id.x*chunk_size)+8,0,(chunk_id.y*chunk_size)+offset)
		4:#West
			#print("terminal_dir is west")
			
			path.set_origin_dir(3)
			path.set_terminal_dir(4)
			var chunk_id = path.get_advancing_chunk_id()
			#var chunk_id = next_chunk_id
			terminal_point = Vector3i((chunk_id.x*chunk_size),0,(chunk_id.y*chunk_size)+offset)
	
	points.append_array(add_connecting_points(starting_point,terminal_point,path.get_origin_dir(),terminal_dir))
	points.append(terminal_point)
	path.extend_path_by_points(points, terminal_dir)
	path.chunk_id = next_chunk_id
	
func add_connecting_points(starting_point,terminal_point,origin_dir,terminal_dir):
	cursor = Vector3i(starting_point)
	
	var connecting_points = []
	var should_offset = false
	var offset = 0
	
	print("origin_dir")
	print(origin_dir)
	match terminal_dir:
		1:#North
			print("terminal_dir is north")
			if origin_dir == 2:
				print("origin_dir is south")
				for step in 8:
					if step == 7:
						var terminal_offset
						terminal_offset = terminal_point.x - cursor.x

						connecting_points.append_array(increment_x_offset(terminal_offset))
						should_offset = false
					elif should_offset:
						var should_increase = (randi_range(0,1) == 1)
						var index = cursor.x % 9
						var lower_lim = index - 1
						var upper_lim = 7 - index
						offset = 0
						if should_increase:
							offset = randi_range(0,upper_lim)
						else:
							offset = randi_range(0,lower_lim)
							offset = offset * -1
						should_offset = false 
						#apply offset
						connecting_points.append_array(increment_x_offset(offset))
						cursor = Vector3i(cursor.x,cursor.y,cursor.z - 1)
						connecting_points.append(Vector3i(cursor))
					else:
						should_offset = true 
						offset = 0
						cursor = Vector3i(cursor.x,cursor.y,cursor.z - 1)
						connecting_points.append(Vector3i(cursor))
			if origin_dir == 3:
				print("origin_dir is east")
				var steps_left = cursor.x - terminal_point.x
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x - 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.z - cursor.z
						connecting_points.append_array(increment_y_offset(terminal_offset))
						
					
					else:
						cursor = Vector3i(cursor.x - 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.z % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_y_offset(offset))
									should_offset = false
						else:
							should_offset = true
			if origin_dir == 4:
				print("origin_dir is west")
				var steps_left = terminal_point.x - cursor.x
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.z - cursor.z
						connecting_points.append_array(increment_y_offset(terminal_offset))
						
					
					else:
						cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.z % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_y_offset(offset))
									should_offset = false
						else:
							should_offset = true
			else:
				#determine how many steps are left to reach the terminal point
				print("origin_dir")
				print(origin_dir)
				
			
		2:#South
			print("terminal_dir is south")
			if origin_dir == 1:
				print("origin_dir is north")
				for step in 8:
					if step == 7:
						var terminal_offset
						terminal_offset = terminal_point.x - cursor.x
						print(terminal_offset)
						connecting_points.append_array(increment_x_offset(terminal_offset))
						should_offset = false
					elif should_offset:
						var should_increase = (randi_range(0,1) == 1)
						var index = cursor.x % 9
						var lower_lim = index - 1
						var upper_lim = 7 - index
						offset = 0
						if should_increase:
							offset = randi_range(0,upper_lim)
						else:
							offset = randi_range(0,lower_lim)
							offset = offset * -1
						should_offset = false 
						#apply offset
						connecting_points.append_array(increment_x_offset(offset))
						cursor = Vector3i(cursor.x,cursor.y,cursor.z + 1)
						connecting_points.append(Vector3i(cursor))
					else:
						should_offset = true 
						offset = 0
						cursor = Vector3i(cursor.x,cursor.y,cursor.z + 1)
						connecting_points.append(Vector3i(cursor))
			if origin_dir == 3:
				print("origin_dir is east")
				var steps_left = cursor.x - terminal_point.x
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x - 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.z - cursor.z
						connecting_points.append_array(increment_y_offset(terminal_offset))
						
					
					else:
						cursor = Vector3i(cursor.x - 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.z % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_y_offset(offset))
									should_offset = false
						else:
							should_offset = true
			if origin_dir == 4:
				print("origin_dir is west")
				var steps_left = terminal_point.x - cursor.x
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.z - cursor.z
						connecting_points.append_array(increment_y_offset(terminal_offset))
						
					
					else:
						cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.z % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_y_offset(offset))
									should_offset = false
						else:
							should_offset = true
			
			else:
				#determine how many steps are left to reach the terminal point
				print(terminal_point.z - cursor.z)
				print("side to side")

		3:#East
			print("terminal_dir is east")


			if origin_dir == 1:
				print("origin_dir is north")
				var steps_left = terminal_point.z - cursor.z
				print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z + 1)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.x - cursor.x
						connecting_points.append_array(increment_x_offset(terminal_offset))
						
					else:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z + 1)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.x % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_x_offset(offset))
									should_offset = false
						else:
							should_offset = true
							
			if origin_dir == 2:
				print("origin_dir is south")
				var steps_left = cursor.z - terminal_point.z
				print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z - 1)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.x - cursor.x
						connecting_points.append_array(increment_x_offset(terminal_offset))
						
					
					else:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z - 1)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.x % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_x_offset(offset))
									should_offset = false
						else:
							should_offset = true
			if origin_dir == 4:
				print("origin_dir is west")
				var steps_left = terminal_point.x - cursor.x
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = true
				else:
					should_offset = false
				for steps in steps_left:
					if steps == steps_left - 1:
						#cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
						#connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.z - cursor.z
						connecting_points.append_array(increment_y_offset(terminal_offset))
						
					
					else:
						cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.z % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_y_offset(offset))
									should_offset = false
						else:
							should_offset = true

		4:#West

			print("terminal_dir is west")

			if origin_dir == 1:
				print("origin_dir is north")
				var steps_left = terminal_point.z - cursor.z
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z + 1)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.x - cursor.x
						connecting_points.append_array(increment_x_offset(terminal_offset))
						
					else:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z + 1)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.x % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_x_offset(offset))
									should_offset = false
						else:
							should_offset = true
			if origin_dir == 2:
				print("origin_dir is north")
				var steps_left = cursor.z - terminal_point.z
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = false
				else:
					should_offset = true
				for steps in steps_left:
					if steps == steps_left - 1:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z - 1)
						connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.x - cursor.x
						connecting_points.append_array(increment_x_offset(terminal_offset))
						
					
					else:
						cursor = Vector3i(cursor.x,cursor.y,cursor.z - 1)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.x % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_x_offset(offset))
									should_offset = false
						else:
							should_offset = true
			if origin_dir == 3:
				print("origin_dir is north")
				var steps_left = cursor.x - terminal_point.x
				#print(steps_left)
				if steps_left % 2 == 0:
					should_offset = true
				else:
					should_offset = false
				for steps in steps_left:
					if steps == steps_left - 1:
						#cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
						#connecting_points.append(Vector3i(cursor))
						var terminal_offset = terminal_point.z - cursor.z
						connecting_points.append_array(increment_y_offset(terminal_offset))
						
					else:
						cursor = Vector3i(cursor.x - 1,cursor.y,cursor.z)
						connecting_points.append(Vector3i(cursor))
						if should_offset:
							var should_increase = (randi_range(0,1) == 1)
							var index = cursor.z % 9
							var lower_lim = index - 1
							var upper_lim = 7 - index
							offset = 0
							if should_increase:
								offset = randi_range(0,upper_lim)
							else:
								offset = randi_range(0,lower_lim)
								offset = offset * -1
								if steps == steps_left - 2:
									should_offset = false
								else:
									connecting_points.append_array(increment_y_offset(offset))
									should_offset = false
						else:
							should_offset = true
							
	return connecting_points.duplicate(true)

func increment_x_offset(x_offset):
	var points_to_add = []
	if x_offset == 0:
		return points_to_add
	elif x_offset > 0:
		for step in x_offset:
			cursor = Vector3i(cursor.x + 1,cursor.y,cursor.z)
			points_to_add.append(Vector3i(cursor))
	else:
		x_offset = x_offset * -1
		for step in x_offset:
			cursor = Vector3i(cursor.x - 1,cursor.y,cursor.z)
			points_to_add.append(Vector3i(cursor))
	return points_to_add

func increment_y_offset(y_offset):
	var points_to_add = []
	if y_offset == 0:
		return points_to_add
	elif y_offset > 0:
		for step in y_offset:
			cursor = Vector3i(cursor.x,cursor.y,cursor.z + 1)
			points_to_add.append(Vector3i(cursor))
	else:
		y_offset = y_offset * -1
		for step in y_offset:
			cursor = Vector3i(cursor.x,cursor.y,cursor.z - 1)
			points_to_add.append(Vector3i(cursor))
	return points_to_add
	
func generate_procedural_path_points(offset:Vector2i):
	var points: Array[Vector3i]
	var chunk_length = 8
	var chunk_height = 8
	var x = 0 + offset.x
	var y = int(chunk_height/2) + offset.y
	
	while x < chunk_length:
		if !points.has(Vector3i(x,0,y)):
			points.append(Vector3i(x,0,y))
		var choice:int = randi_range(0,2)
		if choice == 0 or x % 2 == 0 or x == chunk_length-1:
			x += 1
		elif choice == 1 and y < chunk_height-2 and not points.has(Vector3i(x,0,y+1)):
			y += 1
		elif choice == 2 and y > 1 and not points.has(Vector3i(x,0,y-1)):
			y -= 1
	print(points)
	return points.duplicate(true)
		
	
	
