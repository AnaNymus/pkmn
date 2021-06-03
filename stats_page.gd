extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var msp = preload("res://mini_stats_panel.tscn")

var selected_pkmn = 0

var mini_already_present = false

var switching = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# rename buttons 
	name_buttons()
		
	

func name_buttons():
	for x in 6:
		if global.party[x] == null:
			self.get_node("Panel0").get_child(x).text = ""
		else:
			self.get_node("Panel0").get_child(x).text = global.party[x].pkmn_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_summary():
	var pkmn = global.party[selected_pkmn]
	
	var mon = pkmn.species
	var sprite_folder = ""
	
	if mon < 10:
		sprite_folder = "sprites/00" + str(mon)
	elif mon < 100:
		sprite_folder = "sprites/0" + str(mon)
	else:
		sprite_folder = "sprites/" + str(mon)
	
	var spr = self.get_node("Panel1/sprite")
	spr.set_texture(load(sprite_folder + "/01_base.png"))
	spr.vframes = 2
	
	
	var species_stats = global.get_psd()[pkmn.species]
	
	self.get_node("Panel1/name_label").text = pkmn.pkmn_name + " / " + species_stats["name"]
	self.get_node("Panel1/level").text = "Lvl: " + str(pkmn.level)
	
	var t1 = species_stats["type_1"]
	var t2 = species_stats["type_2"]
	
	if t1 == t2:
		self.get_node("Panel1/types").text = global.types[t1]
	else:
		self.get_node("Panel1/types").text = global.types[t1] + "/" + global.types[t2]
		
	# TODO ability
	
	# TODO nature
	
	# TODO item
	
	self.get_node("Panel1/experience").text = str(pkmn.experience)
	
	var tnl = global.get_exp()[pkmn.exp_group]["exp"][pkmn.level] - pkmn.experience
	
	self.get_node("Panel1/to_next_level").text = str(tnl)
	
	
	if pkmn.moves[0] == 0:
		self.get_node("Panel1/move1").text = ""
	else:
		self.get_node("Panel1/move1").text = global.moves[pkmn.moves[0]]["name"] + ": " + global.types[global.moves[pkmn.moves[0]]["type"]] + " - " + str(global.moves[pkmn.moves[0]]["bp"])
	
	if pkmn.moves[1] == 0:
		self.get_node("Panel1/move2").text = ""
	else:
		self.get_node("Panel1/move2").text = global.moves[pkmn.moves[1]]["name"] + ": " + global.types[global.moves[pkmn.moves[1]]["type"]] + " - " + str(global.moves[pkmn.moves[1]]["bp"])
	
	if pkmn.moves[2] == 0:
		self.get_node("Panel1/move3").text = ""
	else:
		self.get_node("Panel1/move3").text = global.moves[pkmn.moves[2]]["name"] + ": " + global.types[global.moves[pkmn.moves[2]]["type"]] + " - " + str(global.moves[pkmn.moves[2]]["bp"])
	
	if pkmn.moves[3] == 0:
		self.get_node("Panel1/move4").text = ""
	else:
		self.get_node("Panel1/move4").text = global.moves[pkmn.moves[3]]["name"] + ": " + global.types[global.moves[pkmn.moves[3]]["type"]] + " - " + str(global.moves[pkmn.moves[3]]["bp"])

func switch_pkmn(p1, p2):
	var temp = global.party[p1]
	
	global.party[p1] = global.party[p2]
	global.party[p2] = temp
	
	name_buttons()
	switching = false


func _on_exit_pressed():
	get_tree().change_scene("res://test_overworld.tscn")


func _on_pkmn1_pressed():
	if global.party[0] != null:
	
		if switching:
			switch_pkmn(selected_pkmn, 0)
		
		else:
			if !mini_already_present:
				var m = msp.instance()
				self.add_child(m)
				m.set_position(Vector2(200, 25))
				selected_pkmn = 0
				mini_already_present = true
	


func _on_pkmn2_pressed():
	if global.party[1] != null:
		if switching:
			switch_pkmn(selected_pkmn, 1)
		else:
			if !mini_already_present:
				var m = msp.instance()
				self.add_child(m)
				m.set_position(Vector2(200, 125))
				selected_pkmn = 1
				mini_already_present = true
	


func _on_pkmn3_pressed():
	if global.party[2] != null:
		if switching:
			switch_pkmn(selected_pkmn, 2)
		else:
			if !mini_already_present:
				var m = msp.instance()
				self.add_child(m)
				m.set_position(Vector2(200, 200))
				selected_pkmn = 2
				mini_already_present = true


func _on_pkmn4_pressed():
	if global.party[3] != null:
		if switching:
			switch_pkmn(selected_pkmn, 3)
		else:
			if !mini_already_present:
				var m = msp.instance()
				self.add_child(m)
				m.set_position(Vector2(200, 275))
				selected_pkmn = 3
				mini_already_present = true


func _on_pkmn5_pressed():
	if global.party[4] != null:
		if switching:
			switch_pkmn(selected_pkmn, 4)
		else:
			if !mini_already_present:
				var m = msp.instance()
				self.add_child(m)
				m.set_position(Vector2(200, 350))
				selected_pkmn = 4
				mini_already_present = true


func _on_pkmn6_pressed():
	if global.party[5] != null:
		if switching:
			switch_pkmn(selected_pkmn, 5)
		else:
			if !mini_already_present:
				var m = msp.instance()
				self.add_child(m)
				m.set_position(Vector2(200, 450))
				selected_pkmn = 5
				mini_already_present = true
