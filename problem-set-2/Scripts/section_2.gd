extends Node

#Write a function greet() that prints "Hello, adventurer!" to the console.
func greet():
	print("Helllo, Adventurer!")

#Write a function add_score(points) that takes one parameter and returns the current score plus points.
var score := 5
func add_score(points):
	return score+points

#Write a function is_alive(hp) that takes an integer hp and returns true if hp is greater than 0, and false otherwise.
var hp := 80
func is_alive(hp):
	if hp > 0:
		return true
	else:
		return false

#Write a function heal(current_hp, amount, max_hp) that returns the new HP after healing, but never lets it exceed max_hp.
func heal(current_hp, amount, max_hp):
	current_hp = current_hp + amount
	if current_hp > max_hp:
		current_hp = max_hp
	return current_hp

#What keyword built into every Godot Node script runs once when the node enters the scene tree? Write a stub for it that prints a number of your choice.
func _ready():
	print()
# _ready() runs once when the node enters the scene tree
#How often does the _process() function run?
# the _process() function runs every frame for example if a game is running in 120 fps _process() will run 120 times per second
