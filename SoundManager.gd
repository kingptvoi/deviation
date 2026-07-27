extends AudioStreamPlayer

@onready var sfx = self

func play_sfx(clip, volume, pitch):
	if clip == null: return
	
	# 1. Create a "one-time" player
	var sfx_node = AudioStreamPlayer.new()
	
	if Global.sounds_on:
		add_child(sfx_node)
		sfx_node.stream = clip
	else:
		sfx_node.queue_free()
	
	sfx_node.pitch_scale = pitch
	sfx_node.volume_db = volume
	
	#if clip == SoundsList.ui_click:
		#sfx_node.pitch_scale = 1
		#sfx_node.volume_db = -12
	#elif clip == SoundsList.ui_results_reveal:
		#sfx_node.pitch_scale = 1.3
		#sfx_node.volume_db = -20
	#elif clip == SoundsList.ui_round_start:
		#sfx_node.pitch_scale = 1.4
		#sfx_node.volume_db = -16
	#elif clip == SoundsList.ui_error:
		#sfx_node.pitch_scale = 1.9
		#sfx_node.volume_db = -16
	#elif clip == SoundsList.ui_winner_reveal:
		#sfx_node.pitch_scale = 1.6
		#sfx_node.volume_db = -16
	#elif clip == SoundsList.ui_number_tick:
		#sfx_node.pitch_scale = 20.0
		#sfx_node.volume_db = -20
	#else:
		## Use your randomized pitch logic here if desired
		#sfx_node.pitch_scale = 1.4
		#sfx_node.volume_db = -22
		
	# 3. Play and then delete the node automatically when finished
	sfx_node.play()
	sfx_node.finished.connect(sfx_node.queue_free)
