class_name CmpOwnership extends Node

@export var owner_id : int
@onready var system_entity : CmpEntity =  $"/root/Session/SystemEntity"

var player_manager : CmpPlayerManager

func _ready() -> void:
	self.player_manager = system_entity.query_component("PlayerManager")

func get_player_color() -> Color:
	await ready
	return self.player_manager.players[owner_id].player_color
