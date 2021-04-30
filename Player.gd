extends KinematicBody2D

var direction = Vector2()
var velocity = Vector2()

const num_frame = 6

var frame_counter = num_frame

var controls_locked = false

const UP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)

const WALK = 0
const SWIM = 1

var state = WALK #walking, running, biking, swimming, etc.

var grid
var sprite

func _ready():
#	global = get_node("/root/global")
	grid = get_parent()
	sprite = get_child(0)
	

func _get_input():
	#note make new UI thing later
	var is_moving = Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_left")
	
	if is_moving:
		frame_counter = 0
		var dir = 0
		if Input.is_action_pressed("ui_up"):
			direction = UP
			dir = 1
		elif Input.is_action_pressed("ui_right"):
			direction = RIGHT
			dir = 2
		elif Input.is_action_pressed("ui_down"):
			direction = DOWN
			dir = 3
		elif Input.is_action_pressed("ui_left"):
			direction = LEFT
			dir = 4
		sprite.change_direction(dir)
		return true
	else:
		if Input.is_action_pressed("ui_s"):
			change_state(SWIM)
			print("swimming")
		elif Input.is_action_pressed("ui_c"):
			grid.save_board()
			get_tree().change_scene("res://Battle.tscn")
		elif Input.is_action_pressed("ui_h"):
			#heals pokemon for beta
			print("Healing Pokemon")
			global.party[0].full_heal()
		elif Input.is_action_pressed("ui_a"):
			grid.check_in_front(self.position, direction)
		return false
	

func set_position(pos):
	#print(pos)
	#print("test")
	self.global_position = pos

func change_state(s):
	state = s

func check_for_mons():
	grid.check_for_mons(self.position)

func change_map():
	grid.change_map(self.position)

func trans():
	translate(direction*16)

func _physics_process(delta):
	frame_counter += 1
	
	if frame_counter >= num_frame:
		
		if !controls_locked:
			if _get_input():
				var target_pos = grid.update_child_pos(self)
				if target_pos != null:
					controls_locked = true
		
		if controls_locked:
			sprite.update_image()
			frame_counter = 0
