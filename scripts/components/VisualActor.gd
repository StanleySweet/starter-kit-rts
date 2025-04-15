@tool

class_name CmpVisualActor extends Node

@export var actor : PackedScene

var animation_player : AnimationPlayer
var animation_tree : AnimationTree
var state_machine : AnimationNodeStateMachinePlayback
var actor_instance : Node

var cmp_sound : CmpSound

@onready var entity : CmpEntity = $".."
func _ready() -> void:
	actor_instance = actor.instantiate()
	if actor_instance is Node3D:
		actor_instance.position.y -= 0.5
	entity.add_child.call_deferred(actor_instance)
	self.animation_player = actor_instance.find_child("AnimationPlayer")
	self.animation_tree = actor_instance.find_child("AnimationTree")
	if self.animation_tree != null:
		self.state_machine = animation_tree.get("parameters/StateMachine/playback")
		
	if not Engine.is_editor_hint():
		self.cmp_sound = entity.query_component("Sound")

func select_animation(anim_name : String, custom_speed : float =  1.0) -> void:
	if animation_tree != null:
		state_machine.travel(anim_name)
	else:
		var animation := self.animation_player.get_animation(anim_name)
		if animation != null:
			animation.loop_mode = Animation.LOOP_LINEAR
			self.animation_player.play(anim_name, -1, custom_speed)

	#if self.cmp_sound != null:
	#	self.cmp_sound.play_positioned_sound(anim_name) #moved to animation finished
