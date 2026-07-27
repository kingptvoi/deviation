extends AudioStreamPlayer

func _process(delta: float) -> void:
	if Global.sounds_on == true:
		self.volume_db = -12
	else:
		self.volume_db = -999


func _ready() -> void:
	self.play()
