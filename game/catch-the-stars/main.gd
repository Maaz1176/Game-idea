extends Node2D

@onready var basket = $Basket
@onready var star = $Star
@onready var score_label = $ScoreLabel
@onready var lives_label = $LivesLabel
@onready var game_over_label = $GameOverLabel

var speed = 300
var direction = Vector2(0.6, 1)
var score = 0
var lives = 3
var game_over = false


func _ready():
	game_over_label.visible = false


func _process(delta):

	if game_over:
		return

	# Move basket with mouse
	basket.position.x = get_global_mouse_position().x - basket.size.x / 2

	# Keep basket inside screen
	basket.position.x = clamp(basket.position.x, 0, 1152 - basket.size.x)

	# Move star
	star.position += direction.normalized() * speed * delta

	# Bounce from side walls
	if star.position.x <= 0 or star.position.x + star.size.x >= 1152:
		direction.x = -direction.x

	# Bounce from top
	if star.position.y <= 0:
		direction.y = -direction.y

	# Hit basket
	if star.get_rect().intersects(basket.get_rect()) and direction.y > 0:

		# Bounce upward
		direction.y = -1

		# Random horizontal direction
		direction.x = randf_range(-1, 1)

		# Increase speed
		speed += 30

		# Increase score
		score += 1
		score_label.text = "Score: " + str(score)

	# Missed star
	if star.position.y > 648:

		lives -= 1
		lives_label.text = "Lives: " + str(lives)

		# Reset star
		star.position = Vector2(randf_range(100, 1050), 200)
		direction = Vector2(randf_range(-1, 1), 1)
		speed = 300

		if lives <= 0:
			game_over = true
			game_over_label.text = "GAME OVER\nClick to restart"
			game_over_label.visible = true


func _input(event):

	if game_over and event is InputEventMouseButton:
		if event.pressed:
			get_tree().reload_current_scene()
