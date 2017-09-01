#!/usr/bin/swift

let numbers = [1, 2, 3]
var average = Float(0)

for num in numbers {
	average += Float(num)
}

average /= (numbers.count != 0) ? Float(numbers.count) : Float(1)

print(average)

