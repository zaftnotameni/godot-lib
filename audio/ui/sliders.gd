class_name AudioSlidersController extends Node

@onready var values := [%MasterValue, %BGMValue, %SFXValue, %UIValue]
@onready var sliders := [%MasterSlider, %BGMSlider, %SFXSlider, %UISlider]

func on_value_changed(new_value:float, index:int):
	AudioScene.set_volume_linear_0_100(index, new_value, sliders[index], values[index])
	AudioScene.play_volume_tick_sound(index)

func on_focus(index:int):
	var audio := AudioScene.first()
	if not audio: return
	AudioScene.play_ui(audio.ui_focus, false)

func _ready() -> void:
	for index:int in AudioScene.AudioBus.values():
		if index < 0: continue
		AudioScene.get_volume_linear_0_100(index, sliders[index], values[index])
		sliders[index].value_changed.connect(on_value_changed.bind(index))
		sliders[index].focus_entered.connect(on_focus.bind(index))
		sliders[index].mouse_entered.connect(on_focus.bind(index))

# for future reference: https://forum.godotengine.org/t/looking-for-a-slider-theme-tutorial/25351/2
# Icons
# 
# Grabber
# — Drag and drop a pre-sized custom image to use for the slider knob here.
# 
# Grabber Highlight
# — Drag and drop the same pre-sized custom image to use for the slider knob here.
# 
# Styles
# 
# Grabber Area
# — Create a new StyleBoxFlat
# — Set desired Bg Color
# 
# Slider
# — Create a new StyleBoxFlat
# — Set desired Bg Color
# — Set Content Margin
# ----- Set a Top value
# ----- Set a Bottom value (Top and bottom values combined determine overall thickness of the control)
