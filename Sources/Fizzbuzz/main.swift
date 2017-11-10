#!/usr/bin/swift

func FizzBuzz(with fizz: String, and buzz: String) {
	for i in 1...100 {
		print((i % 3 == 0 || i % 5 == 0) ? (i % 3 == 0 ? fizz : "") + (i % 5 == 0 ? buzz : "") : i)
	}
}

FizzBuzz(with: "Fizz", and: "Buzz")
