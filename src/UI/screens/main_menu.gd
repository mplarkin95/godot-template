extends Control

## Assign your first game scene in the inspector.
@export var next_scene: PackedScene

## Override to replace the built-in settings screen.
@export var settings_scene: PackedScene = preload("res://src/UI/screens/settings/settings_screen.tscn")


func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.08, 0.08, 1.0)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "Game Title"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 32
	vbox.add_child(spacer)

	var play_btn := Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size.x = 160
	play_btn.pressed.connect(_on_play_pressed)
	vbox.add_child(play_btn)

	var settings_btn := Button.new()
	settings_btn.text = "Settings"
	settings_btn.custom_minimum_size.x = 160
	settings_btn.pressed.connect(_on_settings_pressed)
	vbox.add_child(settings_btn)

	var quit_btn := Button.new()
	quit_btn.text = "Quit"
	quit_btn.custom_minimum_size.x = 160
	quit_btn.pressed.connect(func(): get_tree().quit())
	vbox.add_child(quit_btn)


func _on_play_pressed() -> void:
	if next_scene:
		SceneTransitionManager.transition_to_scene(next_scene)
	else:
		push_warning("MainMenu: next_scene not set — assign it in the inspector")


func _on_settings_pressed() -> void:
	if settings_scene:
		UIManager.push_screen(settings_scene, false)
