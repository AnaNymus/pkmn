extends Node2D

const UP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)

# is player movement in general disabled
var movement_disabled = false

# is player input disabled to let a sprite animation play?
var animation_playing = false

# direction player is facing/moving
var direction = DOWN

# is player moving?
var is_moving = false

# player sprite (for animation purposes)
var sprite

# to control framerate
var timer = 0.0
var frame_rate = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = self.get_node("sprite")

# initiate movement in a direction
func move(d):
	if !movement_disabled:
		if !is_moving:
			direction = d
			is_moving = true
			animation_playing = true
		
			sprite.change_direction(direction)

		

func end_move():
	animation_playing = false
	is_moving = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_moving:
		timer = timer + delta
		if timer >= frame_rate:
			timer = 0
			# move to next frame of animation
			sprite.update_image()
			# slide player in correct direction
			self.translate(direction*16)
