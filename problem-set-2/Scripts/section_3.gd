extends Node

# Write a for loop using range() that prints the numbers 1 through 10 (inclusive).
for i in range(1, 10):
	print(i)

#rewrite it as a while loop
var i = 1
while i <= 10:
	print(i)
	i = i + 1

#Given an array scores = [10, 9, 7, 10, 6], write a for loop that calculates and prints the total sum.
var scores := [10, 9, 7, 10, 6]
var total = 0

for score in scores:
	total = total + score
	
print(total)
