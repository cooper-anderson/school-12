#!/usr/bin/swift

import Foundation

func getRandom(min:Int, max:Int) -> Int {
	let x = Int(arc4random_uniform(UInt32(max - min + 1)) + UInt32(min))
	return x
}

func getInput(_ query:String) -> String {
	while true {
		print(query, terminator:"")
		let input = readLine()
		if let string = input {
			return string
		}
	}
}

func decaguesser(min:Int, max:Int, lives lifeCount:Int, hints hintCount:Int) {
	let random:Int = getRandom(min: min, max: max)
	var lives = lifeCount
	var hints = hintCount
	while lives > 0 {
		print("You have \(lives) \((lives == 1) ? "life" : "lives") left.")
		let entry = getInput("Guess a number between \(min) and \(max) or type 'hint' for a hint: ").lowercased()
		if entry == "exit" {
			return
		} else if entry == "hint" {
			if hints > 0 {
				print("It is a factor of \(random * getRandom(min:2, max:10)).")
				hints -= 1
			}
			print("\(hints) \((hints == 1) ? "hint" : "hints") left")
		} else if let number = Int(entry) {
			if (number < min || number > max) {
				print("Out of bounds.")
			} else if number == random {
				print("\nYou win! It took you \(lifeCount - lives) \((lifeCount - lives == 1) ? "try" : "tries")!\n")
				return
			} else {
				lives -= 1
			}
		} else {
			print("Please enter something valid.")
		}
	}
	print("\nYou lose! It took you \(hintCount - hints) \((hintCount - hints == 1) ? "hint" : "hints").")
}

repeat {
	decaguesser(min: 1, max: 10, lives: 3, hints: 3)
} while !getInput("Would you like to play again (y/n): ").lowercased().characters.contains("n")

