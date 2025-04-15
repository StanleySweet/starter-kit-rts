class_name SoundGroup extends Resource

@export var sounds : Array[AudioStream] 

func is_valid() -> bool:
	return len(sounds) > 0
