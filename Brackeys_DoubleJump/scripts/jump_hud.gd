extends CanvasLayer
# Entire file is an addition: a fixed-screen UI for the double-jump mechanic.
var jumps_label: Label
var coins_label: Label
var player: CharacterBody2D

func _ready():
	player = get_parent().get_node("Player")
	var panel = PanelContainer.new()
	panel.position = Vector2(16, 16)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	var margin = MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(margin)
	var column = VBoxContainer.new()
	margin.add_child(column)
	var title = Label.new()
	title.text = "BRACKEYS + DOUBLE JUMP"
	title.add_theme_color_override("font_color", Color("7de3e1"))
	column.add_child(title)
	jumps_label = Label.new()
	column.add_child(jumps_label)
	coins_label = Label.new()
	column.add_child(coins_label)
	var controls = Label.new()
	controls.text = "A/D or arrows: move   |   SPACE twice: double jump
Land to recharge. Cyan flash = air jump. R = restart."
	controls.add_theme_font_size_override("font_size", 14)
	column.add_child(controls)
	player.jumps_changed.connect(_on_jumps_changed)
	_on_jumps_changed(player.jumps_remaining)

func _on_jumps_changed(remaining: int):
	jumps_label.text = "JUMPS AVAILABLE: " + str(remaining) + " / 2"
	jumps_label.add_theme_color_override("font_color", Color("f7db8b") if remaining > 0 else Color("fa8c8c"))

func _process(_delta):
	coins_label.text = "COINS: " + str(get_parent().get_node("GameManager").score)

func _unhandled_key_input(event):
	if event.is_pressed() and not event.is_echo() and event.keycode == KEY_R:
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()
