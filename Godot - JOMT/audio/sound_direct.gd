extends AudioStreamPlayer

var offset = 0

func remove_self():
	queue_free()

func play_sound(sound_stream:AudioStreamMP3,volume:float,pich:float):
	set_stream(sound_stream)
	connect("finished",remove_self,0)
	volume_db = volume
	pitch_scale = pich
	play(offset)

func _ready():
	pass # Replace with function body.

