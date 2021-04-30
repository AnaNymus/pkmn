extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var txt = 1

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
#	global = get_node("/root/global")
	get_node("Button").connect("pressed", self,"_on_grass_Button_pressed")
	get_node("Button2").connect("pressed", self,"_on_fire_Button_pressed")
	get_node("Button3").connect("pressed", self,"_on_water_Button_pressed")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_grass_Button_pressed():
	global.gen_player_pokemon(1, 15)
	get_tree().change_scene("res://test_overworld.tscn")
	
func _on_fire_Button_pressed():
	global.gen_player_pokemon(4, 15)
	get_tree().change_scene("res://test_overworld.tscn")
	
func _on_water_Button_pressed():
	global.gen_player_pokemon(7, 15)
	get_tree().change_scene("res://test_overworld.tscn")
