class_name CmpSound extends Node

@onready var system_entity : CmpEntity =  $"/root/Session/SystemEntity"
@onready var entity : CmpEntity = $".."

var sound_manager : CmpSoundManager

@export var sound_groups : Dictionary[String, SoundGroup]

func _ready() -> void:
	self.sound_manager = self.system_entity.query_component("SoundManager")

func play_positioned_sound(key : String) -> void:
	if self.sound_groups.has(key):
		self.sound_manager.play_at_position(self.entity.global_position, self.sound_groups[key])
	
func play(key : String)  -> void:
	if self.sound_groups.has(key):
		self.sound_manager.play(self.sound_groups[key])
	
