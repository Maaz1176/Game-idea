extends Node

# 1) Array with 5 names
var names = ["maaz", "rafail", "rankang", "rasmus", "leonardo"]


# 2) Function that prints names in order
func print_names():
	@warning_ignore("shadowed_variable_base_class")
	for name in names:
		print(name)


# 3) Function that swaps the first and last value
func swap_first_last(array):
	var temp = array[0]
	array[0] = array[array.size() - 1]
	array[array.size() - 1] = temp


func _ready():
	print_names()
	
	swap_first_last(names)
	
	print("After swap:")
	print_names()
