extends Node

onready var pkmn= preload("res://Pokemon.tscn")

var overworld_grid
var overworld_grid_overlay
var player_pos

var random_encounter

var grid_loaded = false

var psd #pokemon species data
var pmd #pokemon move data (which moves pokemon learn)
var moves #pokemon move data
var exp_lookup #experience lookup table

var stat_stage = [1/4.0, 2/7.0, 1/3.0, 2/5.0, 1/2.0, 2/3.0, 1, 1.5, 2, 2.5, 3, 3.5, 4]
var acc_stage = [1/3.0, 3/8.0, 3/7.0, 1/2.0, 3/5.0, 3/4.0, 1, 4/3.0, 5/3.0, 2, 7/3.0, 8/3.0, 3]

var crit_stage = [24, 8, 2, 1, 1]

var type_effect = [
[1,1,1,1,1,0.5,1,0,0.5,1,1,1,1,1,1,1,1,1],
[2,1,0.5,0.5,1,2,0.5,0,2,1,1,1,1,0.5,2,1,2,0.5],
[1,2,1,1,1,0.5,2,1,0.5,1,1,2,0.5,1,1,1,1,1],
[1,1,1,0.5,0.5,0.5,1,0.5,0,1,1,2,1,1,1,1,1,2],
[1,1,0,2,1,2,0.5,1,2,2,1,0.5,2,1,1,1,1,1],
[1,0.5,2,1,0.5,1,2,1,0.5,2,1,1,1,1,2,1,1,1],
[1,0.5,0.5,0.5,1,1,1,0.5,0.5,0.5,1,2,1,2,1,1,2,0.5],
[0,1,1,1,1,1,1,2,1,1,1,1,1,2,1,1,0.5,1],
[1,1,1,1,1,2,1,1,0.5,0.5,0.5,1,0.5,1,2,1,1,2],
[1,1,1,1,1,0.5,2,1,2,0.5,0.5,2,1,1,2,0.5,1,1],
[1,1,1,1,2,2,1,1,1,2,0.5,0.5,1,1,1,0.5,1,1],
[1,1,0.5,0.5,2,2,0.5,1,0.5,0.5,2,0.5,1,1,1,0.5,1,1],
[1,1,2,1,0,1,1,1,1,1,2,0.5,0.5,1,1,0.5,1,1],
[1,2,1,2,1,1,1,1,0.5,1,1,1,1,0.5,1,1,0,1],
[1,1,2,1,2,1,1,1,0.5,0.5,0.5,2,1,1,0.5,2,1,1],
[1,1,1,1,1,1,1,1,0.5,1,1,1,1,1,1,2,1,0],
[1,0.5,1,1,1,1,1,2,1,1,1,1,1,2,1,1,0.5,0.5],
[1,2,1,0.5,1,1,1,1,0.5,0.5,1,1,1,1,1,2,2,1]
]

#player's current party of pokemon
#NOTE: currently only 1 pokemon, need to make it a full 6
var party = [0, 0, 0, 0, 0, 0]

func _ready():
	get_pokemon_battle_data()
	#gen_player_pokemon(5, 15)


func get_pokemon_battle_data():
	
	# pokemon species data
	var file = File.new()
	file.open("species_data.json", File.READ)
	var text = file.get_as_text()
	file.close()
	psd = JSON.parse(text).result["pokemon"]
	
	
	# move data
	
	file.open("move_data.json", File.READ)
	text = file.get_as_text()
	file.close()
	moves = JSON.parse(text).result["moves"]
	
	
	file.open("moveset_data.json", File.READ)
	text = file.get_as_text()
	file.close()
	pmd = JSON.parse(text).result["movesets"]
	
	#experience data
	file.open("exp_lookup.json", File.READ)
	text = file.get_as_text()
	file.close()
	exp_lookup = JSON.parse(text).result["experience"]
	#print(exp_lookup[1]["exp"][11])
	
	
	# item data
	
	# pokedex data (can be saved for later)
	

# temporary utility function, generates pokemon to fill the player's party
func gen_player_pokemon(pk, lv):	
	#mudkip at level 15
	party[0] = pkmn.instance()
	party[0].setup([pk, lv])
	party[0].make_players()
	

func get_base_experience(species):
	return psd[species]["base_exp_yield"]

func get_exp():
	return exp_lookup

# returns the pokemon that the player sends out at the start of a battle
func send_out_pokemon():
	#NOTE: need to make this handle fainted pokemon
	return party[0]

func get_save_data():
	# get pokemon data
	pass

func set_player_pos(p_pos):
	player_pos = p_pos

func get_player_pos():
	return player_pos

func set_grids(o_grid, o_grid_o):
	overworld_grid = o_grid
	overworld_grid_overlay = o_grid_o
	grid_loaded = true

func get_grid():
	return overworld_grid

func get_grid_overlay():
	return overworld_grid_overlay

func get_psd():
	return psd

func get_pmd():
	return pmd

func set_rand_e(r_e):
	random_encounter = r_e

func get_rand_e():
	return random_encounter
