extends Node

'''
Part 1)
In player.gd, declare the following variables/constants at the top of the script (outside any function):

health — an integer, starting at 100
max_health — an integer, also 100 (make this one a constant)
speed — an integer, starting at 50
player_name — a string, set to whatever you like

In _ready(), print all four values on one line using string concatenation, e.g. Chuckles The Clown | HP: 100/100 | Speed: 50.

String formatting and concatenation: 
	use commas for multiple arguments in print, or + to concatenate 
	eg: print("Hello ", "World") or print print("Hello " + "World") both print "Hello World" (you cannot use the '+' sign between a string and a number).
	Remember that print accepts variables as arguments
	eg:
		var score = 5
		print("Score is " , score) will print "Score is 5"
	Extra info: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html

Run it. Confirm the line prints correctly in the Output panel.

Part 2)
You now have health and max_health from Exercise 1. Instead of editing health directly, fill in this function:

func take_damage(amount):
    #subtract damage from health
    #print to the console how much damage the player took and how much health is remaining (use string concatenation)

In _ready(), call take_damage(15) twice in a row. Do not print health directly in _ready() — the function should report it.

Run it. Confirm HP drops by 15, then 15 again, and both messages print.

Part 3)
Using the same health and max_health from before, write a heal() function that will heal the player back to max_health (but no higher).
Use a while loop that adds 7 health to the player each loop.
Log the current health to the console for each step of the while loop.
In _ready(), after your two take_damage(15) calls from Part 2, call heal().

Part 4)
Variable fun time! Here are some exercises to make sure you understand variables. If you can't solve them, watch https://www.youtube.com/watch?v=ijjVDBPwA1o
4.1) What is the final value of a in this example?
var a = 5
a = a - 3
a = 5
a = a + a

4.2) What is the final value of a in this example?
var a = 3
var b = 2
var c = a + b
var b = 0
var a = c - b
var b = 10

'''
# Called when the node enters the scene tree for the first time.
var health = 100
const max_health = 100
var speed = 50
var player_name = "Maaz"

func _ready():
	print(player_name, " | HP: ", health, "/", max_health, " | Speed: ", speed)

	take_damage(15)
	take_damage(15)

	heal()

func take_damage(amount):
	health = health - amount
	print("Damage: ", amount, " | HP: ", health)

func heal():
	while health < max_health:
		health = health + 7

		if health > max_health:
			health = max_health

		print("HP: ", health)
		
		# 4.1 => a = 10
		# 4.2 => a = 5 
