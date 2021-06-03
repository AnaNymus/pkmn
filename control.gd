extends Node2D

const UP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)

# shortcuts for the various buttons we could press
const MOVE_UP = "up"
const MOVE_RIGHT = "right"
const MOVE_DOWN = "down"
const MOVE_LEFT = "left"
const SELECT = "select"
const BACK = "back"
const START = "start"
const NONE = "none"

# disables all player input
var controls_disabled = false

# use this to disable player movement in overworld (for menu, etc.)
#var player_can_move = true

# use this to temporarily disable input while animation plays
#var animation_lock = false


var player 
var map
var player_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	# this is so we can update animations later
	player_sprite = self.get_parent().get_node("player/sprite")
	player = self.get_parent().get_node("player")


func _get_input():
	
	if Input.is_action_pressed("ui_up"):
		return MOVE_UP
	elif Input.is_action_pressed("ui_right"):
		return MOVE_RIGHT
	elif Input.is_action_pressed("ui_down"):
		return MOVE_DOWN
	elif Input.is_action_pressed("ui_left"):
		return MOVE_LEFT
	elif Input.is_action_pressed("ui_select"):
		return SELECT
	elif Input.is_action_pressed("ui_cancel"):
		return BACK
	elif Input.is_action_pressed("ui_start"):
		return START
	else:
		return NONE
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	
	# this is just for player control
	
	# if an animation is playing, we don't allow player input
	if !controls_disabled:
	
		# get control input for this frame
		var i = _get_input()
	
		if i == MOVE_UP:
			player.move(UP)
		elif i == MOVE_RIGHT:
			player.move(RIGHT)
		elif i == MOVE_DOWN:
			player.move(DOWN)
		elif i == MOVE_LEFT:
			player.move(LEFT)
		
		# if player attempts to interact with an object
		if i == SELECT:
			pass
		
		# if player attempts to cancel an action
		if i == BACK:
			pass
		
		# if player attempts to open the menu
		if i == START:
			pass
	
	
	# TODO: add NPC controls here


