extends Node

#WARNING! The following problems are hard and NOT MANDATORY. Only do them if you already know how to code and want a fun challenge

#Excercise 1 - Linear Recursion
#The following function computes a mathematical function called Ackermann’s function:
func A(x: int, y: int) -> int:
	if y == 0:
		return 0
	elif x == 0:
		return 2 * y
	elif y == 1:
		return 2
	else:
		return A(x - 1, A(x, y - 1))
		
#Consider the following functions, where A is the function defined above:

func f(n: int) -> int:
	return A(0, n)


func g(n: int) -> int:
	return A(1, n)


func h(n: int) -> int:
	return A(2, n)


func k(n: int) -> int:
	return 5 * n * n

#Give concise mathematical definitions for the functions computed by f, g, and h for positive integer values of n. For example, k(n) computes: 5n^2

#Excercise 2 - Tree Recursion
'''Exercise 1.12: the following pattern of numbers is called
Pascal’s triangle.
    1
   1 1
  1 2 1
 1 3 3 1
1 4 6 4 1
  . . .
the numbers at the edge of the triangle are all 1, and each
number inside the triangle is the sum of the two numbers
above it. Write a procedure that computes elements of
Pascal’s triangle by means of a recursive process'''
