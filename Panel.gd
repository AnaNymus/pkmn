extends Panel



onready var pkmn= preload("res://Pokemon.tscn")
var opponent
var p_pkmn

var moves_labels

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	#get_node("Button").connect("pressed", self,"_on_Button_pressed")
	
	#global = get_node("/root/global")
	
	#moves_labels = get_parent().get_child(1).get_children()
	#print(moves_labels)
	
	#opponent = pkmn.instance()
	#opponent.setup(global.get_rand_e())
	#opponent.make_opponent()
	
	
	#p_pkmn = pkmn.instance()
	#p_pkmn.setup(global.get_rand_e())
	#p_pkmn.make_players()
	
	#add_child(opponent)
	#add_child(p_pkmn)
	
	# need to make it scale with window size
	#opponent.position = Vector2(683, 50)
	
	#p_pkmn.position = Vector2(400, 500)
	#setup_moves_panel()
	pass

func setup_moves_panel():
	for x in range(4):
		var mv = p_pkmn.moves[x]
		if mv == 0:
			moves_labels[x].text = ""
			
		else:
			var move_name = global.moves[mv]["name"]
			var c_pp = p_pkmn.c_pp[x]
			var m_pp = p_pkmn.max_pp[x]
			moves_labels[x].text = str(move_name, ": ", c_pp, "/", m_pp)
		


func _on_Button_pressed():
	get_tree().change_scene("res://test_overworld.tscn")
