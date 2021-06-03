extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_cancel_button_pressed():
	self.get_parent().mini_already_present = false
	self.get_parent().remove_child(self)


func _on_stats_button_pressed():
	self.get_parent().update_summary()
	self.get_parent().mini_already_present = false
	self.get_parent().remove_child(self)


func _on_switch_button_pressed():
	self.get_parent().switching = true
	self.get_parent().mini_already_present = false
	self.get_parent().remove_child(self)
