extends Sprite

const UP = Vector2(0, -1)
const RIGHT = Vector2(1, 0)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)

var direction = DOWN
var frame_num = 0

var player

func _ready():
	player = self.get_parent()

func change_direction(new_dir):
	direction = new_dir
	frame_num = 1
	
	if direction == UP:
		self.frame = 8
	elif direction == RIGHT:
		self.frame = 12
	elif direction == DOWN:
		self.frame = 0
	elif direction == LEFT:
		self.frame = 4

func update_image():
	#print(frame_num)
	if direction == UP:
		self.frame = 8 + frame_num
	elif direction == RIGHT:
		self.frame = 12 + frame_num
	elif direction == DOWN:
		self.frame = 0 + frame_num
	elif direction == LEFT:
		self.frame = 4 + frame_num
	
	if frame_num == 0:
		player.end_move()
		#pyr.check_for_mons()
		#pyr.change_map()
	elif frame_num < 3:
		frame_num = frame_num+1
	else:
		frame_num = 0
