extends Control

@onready var music_slider = $VBoxContainer/MusicVolume/HSlider
@onready var sfx_slider = $VBoxContainer/SFXVolume/HSlider
@onready var horn_slider = $VBoxContainer/HornVolume/HSlider

func _ready():
	if AudioManager:
		music_slider.value = AudioManager.music_volume
		sfx_slider.value = AudioManager.sfx_volume
		horn_slider.value = AudioManager.horn_volume

func _on_music_volume_changed(value):
	AudioManager.set_bus_volume("Music", value)

func _on_sfx_volume_changed(value):
	AudioManager.set_bus_volume("SFX", value)

func _on_horn_volume_changed(value):
	AudioManager.set_bus_volume("Horn", value)

func _on_back_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
