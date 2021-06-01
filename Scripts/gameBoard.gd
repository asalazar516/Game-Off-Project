extends Node2D

var Block = preload("res://Scenes/Block.tscn")
var Circle = preload("res://Scenes/Circle.tscn")

const blockSize = 30.0							# Size of block sprite

export var movement_speed = 0.3					# Movement speed of snake

export var width = 14							# Width of snake board
export var height = 14 							# Height of snake board

export var wall_color = Color(1, 1, 0)
export var player1_color = Color(1, 0, 1)
export var player2_color = Color(48, 19, 79)
export var food_coloring = Color(0, 1, 1)

const startingLength = 4
var startingPos1 = Vector2(3, 12)
var startingPos2 = Vector2(3, 2)

var player_snake									# Player 1 Snake
var player_2_snake									# Player 2 Snake

var board = {}

var roundOver = false
var timer
var game_timer
var food
var runtime = 0

var snake_moving
var snake2_moving

var snakeLength_text
var snake2Length_text
var time_text
var winner_text
var resultMenu

class Snake:
	var Block = preload("res://Scenes/Block.tscn")
	
	var position = Vector2(0,0)
	var _blocks = []
	var movement = Vector2(0,0)
	var _color
	
	var _roundOver = false
	var _board_node
	var _board = {}
	var _board_width = 0
	var _board_height = 0
	
	# return player's length
	func length():
		return _blocks.size()
		
	# return player's blocks
	func blocks():
		return _blocks
	
	# return player's position
	func pos():
		return position
	
	# set player's directions
	func set_dir(dir):
		if movement.dot(dir) != 0:
			#wrong direction
			return false
		movement = dir
		return true
	
	func dir():
		return movement
	
	# return round over
	func gameover():
		return _roundOver
	
	# set Snake board's Node2D reference for add_child
	func setBoardNode(board_node):
		_board_node = board_node
	
	# set board's reference
	func setBoard(board, width, height):
		_board = board
		_board_width = width
		_board_height = height
	
	# setup snake player
	func setup(pos, dir, length, color):
		if _blocks.size() > 0:
			for block in _blocks:
				block.queue_free()
			_blocks = []
		position = pos
		movement = dir
		_color = color
		for i in range(length):
			var block = Block.instance()
			var block_pos = position - Vector2(1,0) * i
			block.set_modulate(_color)
			block.set_position(block_pos * blockSize)
			_board_node.add_child(block)
			_board[block_pos] = 1
			_blocks.push_back(block)
		_roundOver = false
	
	# move with movement, switch statement can_move: 1 - hit wall or self, 2 - hit food, 0 -  hit empty tile
	func move_and_collide():
		var can_move = check_move_and_collide(movement)
		
		if can_move == 1:
			_roundOver = true
		
		elif can_move == 2:
			position += movement
			var new_block = Block.instance()
			new_block.set_modulate(_color)
			new_block.set_position(position * blockSize)
			_blocks.insert(0, new_block)
			_board_node.add_child(new_block)
			_board[position] = 1
		else:
			var tail_block = _blocks[_blocks.size()-1]
			var tail_pos = tail_block.get_position() / blockSize
			_board[tail_pos] = 0
			position += movement
			tail_block.set_position(position * blockSize)
			_board[position] = 1
			# remove the tail block and insert to head
			_blocks.resize(_blocks.size()-1)
			_blocks.insert(0, tail_block)
			
		return can_move
		
	# check if the move is avaliable
	func check_move_and_collide(dir):
		# if snake hit the wal or self, return 1
		# if snake will eat food, return 2
		# if snake will move to an empty tile, return 0
		var attempt_move = position + dir
		if attempt_move.x < 0 || attempt_move.x >= _board_width || attempt_move.y < 0 || attempt_move.y >= _board_height:
			return 1
		return _board[attempt_move]
		
	
###################### end of Class Snake player ########################

func _ready():
	# Starting up game
	GettingNodes()
	snake_wall()
	player_snake = Snake.new()
	player_2_snake = Snake.new()
	player_snake.setBoardNode(get_node("."))
	player_2_snake.setBoardNode(get_node("."))
	
	setup_game()
	set_process(true)
	set_physics_process(true)
	
###################### end of _ready #####################

func setup_game():
	
	setup_board()
	#Lasers.setBoard(board, 50, 80)
	player_snake.setBoard(board, width, height)
	player_2_snake.setBoard(board, width, height)
	player_snake.setup(startingPos1, Vector2(1, 0), startingLength, player1_color)
	player_2_snake.setup(startingPos2, Vector2(1, 0), startingLength, player2_color)
	generate_food()
	
	timer = movement_speed
	snake_moving = false
	snake2_moving = false
	roundOver = false
	update_snake_length_text()

############################ END OF SETUP #############################

func _process(delta):
	if roundOver:
			get_tree().set_pause(false)
			setup_game()
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://Scenes/mainMenu.tscn")
	
	timer -= delta
	
	time_text.set_text(str(int(game_timer.get_time_left())))
	SnakeMove()
	Snake2Move()
	
	
	if timer < runtime:
		#move the players
		var result = player_snake.move_and_collide()
		var result2 = player_2_snake.move_and_collide()
		
		# Snake hits food
		if result == 2:
			# Create new food
			generate_food()
			update_snake_length_text()
		elif result2 == 2:
			generate_food()
			update_snake_length_text()
		
		# Snake hit wall or self
		if result == 1:
			round_over()
			resultMenu.show()
			winner_text.set_text("Winner is Snake 2")
			
		elif result2 == 1:
			round_over()
			resultMenu.show()
			winner_text.set_text("Winner is Snake 1")
		
		timer = movement_speed
		snake_moving = false
		snake2_moving = false

func snake_wall():
	
	var Wall
	# Left and Right walls
	for i in range(0, height):
		Wall = Block.instance()
		Wall.set_modulate(wall_color)
		Wall.set_position(Vector2(-blockSize, i * blockSize))
		add_child(Wall)
		
		Wall = Block.instance()
		Wall.set_modulate(wall_color)
		Wall.set_position(Vector2(width * blockSize, i * blockSize))
		add_child(Wall)
	
	# Top and Bottom walls
	for i in range(-1, width + 1):
		Wall = Block.instance()
		Wall.set_modulate(wall_color)
		Wall.set_position(Vector2( i * blockSize, - blockSize))
		add_child(Wall)
		
		Wall = Block.instance()
		Wall.set_modulate(wall_color)
		Wall.set_position(Vector2(i * blockSize, height * blockSize))
		add_child(Wall) 
###############################END OF SNAKE BOUNDARIES #########################

func setup_board():
	for i in range(width):
		for j in range(height):
			board[Vector2(i, j)] = 0

############################# END OF BOARD ###############################

func generate_food():
	if food == null:
		# Make snake food
		food = Circle.instance()
		food.set_modulate(food_coloring)
		add_child(food)
	
	var foodPosition = Vector2(0,0)
	# Locate a random drop for food
	if player_snake.length() > height * width * 0.5 || player_2_snake.length() > height * width * 0.5:
		var available = []
		for key in board.keys():
			if board[key] == 0:
				available.push_back(key)
		foodPosition = available[randi() % available.size()]
		
	else:
		foodPosition = Vector2(randi() % width, randi() % height)
		while(board[foodPosition] == 1):
			foodPosition = Vector2(randi() % width, randi() % height)
		
	food.set_position(foodPosition * blockSize)
	board[foodPosition] = 2
	
########################## END OF CREATING SNAKE FOOD ######################

func round_over():
	for block in player_snake.blocks():
		block.set_modulate(Color(0.3, 0.3, 0.3))
	for block in player_2_snake.blocks():
		block.set_modulate(Color(0.3, 0.3, 0.3))
	roundOver = true
	get_tree().set_pause(true)

################### END OF ROUND ####################################

func SnakeMove():
	var attemptMove = Vector2(1.0, 1.0) #Attempt snake movement
	if !snake_moving:
		if Input.is_action_pressed("ui_up"):
			attemptMove = Vector2(0.0, -1.0)
		
		elif Input.is_action_pressed("ui_down"):
			attemptMove = Vector2(0.0, 1.0)
			
		elif Input.is_action_pressed("ui_right"):
			attemptMove = Vector2(1.0, 0.0)
		
		elif Input.is_action_pressed("ui_left"):
			attemptMove = Vector2(-1.0, 0.0)
		
		snake_moving = player_snake.set_dir(attemptMove)
		
############################ END OF SNAKE 1 MOVEMENT ################################

func Snake2Move():
	var attemptMove = Vector2(1.0, 1.0) #Attempt snake movement
	if !snake2_moving:
		if Input.is_action_pressed("P2_up"):
			attemptMove = Vector2(0.0, -1.0)
		
		elif Input.is_action_pressed("P2_down"):
			attemptMove = Vector2(0.0, 1.0)
		
		elif Input.is_action_pressed("P2_right"):
			attemptMove = Vector2(1.0, 0.0)
		
		elif Input.is_action_pressed("P2_left"):
			attemptMove = Vector2(-1.0, 0.0)
		
		snake2_moving = player_2_snake.set_dir(attemptMove)

######################## END OF SNAKE 2 MOVEMENT ##############################

func update_snake_length_text():
	snakeLength_text.set_text("Snake 1 length: " + str(player_snake.length()))
	snake2Length_text.set_text("Snake 2 length: " + str(player_2_snake.length()))
	
######################## END OF TEXT LENGTH ########################################

func GettingNodes():
	snakeLength_text = get_node("../HUD/P1LengthText")
	snake2Length_text = get_node("../HUD/P2LengthText")
	time_text = get_node("../HUD/TimeCounter")
	game_timer = get_node("../game_timer")
	winner_text = get_node("../HUD/ResultMenu/WinnerText")
	resultMenu = get_node("../HUD/ResultMenu")

func _on_game_timer_timeout():
	Result()
	round_over()

func Result():
	if player_snake.length() > player_2_snake.length():
		resultMenu.show()
		get_node("Label").add_color_override("WinnerText", Color(1, 0, 1, 255))
		winner_text.set_text("Winner is Snake 1!")
	elif player_2_snake.length() > player_snake.length():
		resultMenu.show()
		get_node("Label").add_color_override("WinnerText", Color(48, 19, 79, 255))
		winner_text.set_text("Winner is Snake 2!")
	elif player_snake.length() == player_2_snake.length():
		resultMenu.show()
		winner_text.set_text("Tie Game!")

func _on_ReplayButton_pressed():
	resultMenu.hide()
	get_tree().set_pause(false)
	get_tree().change_scene("res://Scenes/Game.tscn")


func _on_QuitButton_pressed():
	resultMenu.hide()
	get_tree().set_pause(false)
	get_tree().change_scene("res://Scenes/mainMenu.tscn")

