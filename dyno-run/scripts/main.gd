extends Node

#preload obstacles
var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var bullet_scene = preload("res://scenes/bullet.tscn")

# Game Variable
const  DYNO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576,324)
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
const SCORE_MODIFIER : int = 10
const SPEED_MODIFIER : int = 5000
const MAX_DIFFICULTY: int = 2

var speed: float
var screen_size: Vector2i
var score: int
var total_score: int
var bird_score: int
var hight_score: int
var game_is_running: bool
var last_obs
var ground_height: int
var difficulty
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles: Array
var bird_heights := [200,390]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$game_over.get_node("gameOverPanel/Button").pressed.connect(new_game)
	new_game()

# function game Awal
func new_game():
	# Reset variable
	score = 0
	bird_score = 0
	show_score()
	game_is_running = false
	difficulty = 0
	get_tree().paused = false
	
	# delete all obstacles
	for obs in obstacles:
		if obs != null:
			obs.queue_free()
	obstacles.clear()
	
	#reset hud
	$HUD.get_node("PlayLabel").show()
	$game_over.hide()
	
	# Restart nodes
	$dyno.position = DYNO_START_POS
	$dyno.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_is_running:
		#speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		# generate obstacles
		generate_obstacles()
		
		# move dyno and camera
		$dyno.position.x += speed
		$Camera2D.position.x += speed
		
		# update score
		score += speed
		show_score()
		
		#  update ground position
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		# remove obstacles that have gone off screen
		for obs in obstacles:
			if obs != null:
				if obs.position.x < ($Camera2D.position.x - screen_size.x):
					remove_obs(obs)
				
		if Input.is_action_just_pressed("fire"):
			shoot()
	else:
		if Input.is_action_pressed("ui_accept"):
			game_is_running = true
			$HUD.get_node("PlayLabel").hide()

# function generate obstacles
func  generate_obstacles():
	if last_obs == null or obstacles.is_empty() or last_obs.position.x < score + randi_range(300,500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x: int = screen_size.x + score + 100 + (i * 100)
			var obs_y: int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			add_obs(obs,obs_x,obs_y)
		# add random chance to spawn a bird
		if (randi() % 2) == 0:
			# generate obs bird
			obs = bird_scene.instantiate()
			var obs_bird_x: int = screen_size.x + score + 100
			var obs_bird_y: int = bird_heights[randi() % bird_heights.size()]
			add_obs(obs, obs_bird_x, obs_bird_y)

# function add obstacles
func add_obs(obs, x,y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	last_obs = obs
	add_child(obs)
	obstacles.append(obs)

# function hit obstacles
func hit_obs(body):
	if body.name == 'dyno':
		game_over()

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

# Function remove abs
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

#function game over
func game_over():
	calculete_score()
	check_high_score()
	game_is_running = false
	get_tree().paused = true
	$game_over.show()
	
# function show score
func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)
	$HUD.get_node("BirdScore").text = "BIRD SCORE: " + str(bird_score)

# function calculate score
func calculete_score():
	var _score: int = score / SCORE_MODIFIER
	total_score = _score if bird_score == 0 else _score * bird_score
	$game_over.get_node("gameOverPanel/PrevScoreLabel").text = "SCORE: " + str(_score)
	$game_over.get_node("gameOverPanel/PrevBirdScoreLabel").text = "BIRD SCORE: " + str(bird_score)
	$game_over.get_node("gameOverPanel/EndScoreLabel").text = "TOTAL SCORE: " + str(total_score)

func check_high_score():
	if total_score > hight_score:
		hight_score = total_score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(hight_score)

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.add_to_group("bullet-dyno")
	var offet = Vector2(80, 0)
	bullet.position = $dyno.position + offet
	get_parent().add_child(bullet)
	
