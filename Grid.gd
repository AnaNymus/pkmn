extends TileMap

var tile_size = Vector2(64, 64)
var half_tile_size = tile_size/2

var grid_size = Vector2(24, 100)

var grid = [] #grid for holding player and other interactive objects
var grid_overlay = [] #grid for holding sprites that can be walked over

var encounter_density = [25, 10, 10] #grass, water, cave
var encounters = []

const GRASS = 0
const WALL = 1
const WATER = 2
const DIRT = 3
const DOOR = 4
const BUILDING = 5
const HEAL = 6

const WALK = 0
const SWIM = 1

var player

onready var Obstacle = preload("res://blank_node.tscn")

func _ready():
	randomize()
#	global = get_node("/root/global")
	player = get_child(0)
	
	#generate random pokemon encounters
	
	#grass
	var grass_e = []
	#encounter format: percent encounter, dex number, min level, max level
	grass_e.append([40, 10, 10, 12])
	grass_e.append([60, 12, 9, 10])
	grass_e.append([90, 14, 11, 13])
	grass_e.append([100, 17, 14, 15])
	encounters.append(grass_e)
	
	var water_e = []
	water_e.append([60, 4, 9, 12])
	water_e.append([85, 5, 8, 10])
	water_e.append([100, 6, 10, 11])
	
	encounters.append(water_e)
	
	#no cave encounters on this map
	encounters.append([])
	
	
	if global.grid_loaded:
		load_board(global)
	else:
		gen_new_board()
	

func load_board(global):
	grid = global.get_grid()
	grid_overlay = global.get_grid_overlay()
	player.global_position = global.get_player_pos()
	#print(player.global_position)
	#probably need to set player position (and later all other object positions) too

func save_board():
#	global = get_node("/root/global")
	global.set_grids(grid, grid_overlay)
	global.set_player_pos(player.global_position)
	#print(player.global_position)

func gen_new_board():
	for x in range(grid_size.x):
		grid.append([])
		grid_overlay.append([])
		for y in range(grid_size.y):
			grid[x].append(null)
			grid_overlay[x].append(null)
			
			if get_cell(x, y) == GRASS:
				var new_obstacle = Obstacle.instance()
				add_child(new_obstacle)
				
				new_obstacle.to_global(map_to_world(Vector2(x, y)))
				
				grid_overlay[x][y] = new_obstacle


func is_cell_vacant(grid_pos):
	if grid_pos.x < grid_size.x and grid_pos.x >= 0:
		if grid_pos.y < grid_size.y and grid_pos.y >= 0:
			#print(get_cell(grid_pos.x, grid_pos.y))
			if get_cell(grid_pos.x, grid_pos.y) != WALL:
				if grid[grid_pos.x][grid_pos.y] == null:
					return true
	return false

func is_cell_traversible(grid_pos, child_node):
	var cell_type = get_cell(grid_pos.x, grid_pos.y)
	var child_state = child_node.state
	if child_state == SWIM:
		if cell_type == WATER:
			return true
		elif cell_type == DIRT or cell_type == GRASS:
			child_node.change_state(WALK)
			return true
		return false
	else:
		if cell_type == GRASS or cell_type == DIRT or cell_type == DOOR:
			return true
		return false
		
	

func update_child_pos(child_node):
	var grid_pos = world_to_map(child_node.global_position)
	#print(grid_pos)

	var new_pos = grid_pos + child_node.direction
	#print(new_pos)

	if is_cell_vacant(new_pos):
		if is_cell_traversible(new_pos, child_node):
			grid[grid_pos.x][grid_pos.y] = null
			grid[new_pos.x][new_pos.y] = child_node
			var target_pos = map_to_world(new_pos)
			return target_pos + half_tile_size
	return null
	
func check_for_mons(world_pos):
	var grid_pos = world_to_map(world_pos)
	var cell_type = get_cell(grid_pos.x, grid_pos.y)
	
	var encounter = randi()%100+1
	
	if cell_type == GRASS:
		if encounter <= encounter_density[0]:
			#print("mon found in grass")
			var e_rand = randi()%100+1
			
			var e_type = encounters[0][0]
			var c = 0
			
			while e_type[0] <= e_rand:
				c = c + 1
				e_type = encounters[0][c]
			
			var lvl = randi()%(e_type[3]-e_type[2]+1)+e_type[2]
			#print("encountered ", e_type[1], " at level ", lvl)
			
			global.set_rand_e([e_type[1], lvl])
			save_board()
			get_tree().change_scene("res://Battle.tscn")
			
	elif cell_type == WATER:
		if encounter <= encounter_density[1]:
			#print("mon found in water")
			
			var e_rand = randi()%100+1
			
			var e_type = encounters[1][0]
			var c = 0
			
			while e_type[0] <= e_rand:
				c = c + 1
				e_type = encounters[1][c]
			
			var lvl = randi()%(e_type[3]-e_type[2]+1)+e_type[2]
			#print("encountered ", e_type[1], " at level ", lvl)
			
			global.set_rand_e([e_type[1], lvl])
			save_board()
			get_tree().change_scene("res://Battle.tscn")
	else:
		return null
		
		
func change_map(world_pos):
	var grid_pos = world_to_map(world_pos)
	var cell_type = get_cell(grid_pos.x, grid_pos.y)
	
	var scene_name = get_tree().get_current_scene().get_name()
	
	if cell_type == DOOR:
		if scene_name == "Game":
			global.set_player_pos(map_to_world(Vector2(5, 9)) + half_tile_size)
			get_tree().change_scene("res://rest_stop.tscn")
		elif scene_name == "rest_stop":
			global.set_player_pos(map_to_world(Vector2(5, 28)) + half_tile_size)
			get_tree().change_scene("res://test_overworld.tscn")
	

func check_in_front(world_pos, dir):
	var grid_pos = world_to_map(world_pos) + dir
	var cell_type = get_cell(grid_pos.x, grid_pos.y)
	
	if cell_type == HEAL:
		print("healing pokemon!")
		for x in 6:
			global.party[x].full_heal()
	


func _on_pkmn_pressed():
	save_board()
	get_tree().change_scene("res://stats_page.tscn")
