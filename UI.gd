extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _prev_slice_val

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func update_combo(val):
	pass

func show_menu():
	$ColorRect.visible = true
	$AnimationPlayer.play("black_fade_out")
	
func game_start():
	$"..".restart_game()
	pass
	
func _input(event):
	if not $AnimationPlayer.is_playing() and $ColorRect.visible and Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.play("menu_to_game")
		
func set_color_palette(ColorPalatte):
	$ColorRect.color = ColorPalatte[0]
	$ColorRect/Heading.modulate = ColorPalatte[1]
	$ColorRect/ToDo.modulate = ColorPalatte[1]
	$ColorRect/Score.self_modulate = ColorPalatte[2]
	$ColorRect/Score/Value.self_modulate = ColorPalatte[2]
	
func update_num_slices(val):
	if val > 0:
#		$Control.visible = true
		$Control/BreadSlices.text = str(val)
		$AnimationPlayer.play("slice_change")
	else:
		if not (_prev_slice_val == val):
			$AnimationPlayer.play("slice_fade")
#		$Control.visible = false
	_prev_slice_val = val

func on_miss():
	$AnimationPlayer2.play("show_miss")
	$MissSFX.play()
