#!/usr/bin/swift

import Foundation
import Darwin.ncurses
setlocale(LC_ALL, "")
initscr()
noecho()

extension String {
	func replace(string:String, replacement:String) -> String {
		return self.replacingOccurrences(of: " ", with: "")
	}

	func removeWhitespace() -> String {
		return self.replace(string: " ", replacement: "")
	}
	func substring(from: Int?, to: Int?) -> String {
		if let start = from {
			guard start < self.characters.count else {
				return ""
			}
		}

		if let end = to {
			guard end >= 0 else {
				return ""
			}
		}

		if let start = from, let end = to {
			guard end - start >= 0 else {
				return ""
			}
		}

		let startIndex: String.Index
		if let start = from, start >= 0 {
			startIndex = self.index(self.startIndex, offsetBy: start)
		} else {
			startIndex = self.startIndex
		}

		let endIndex: String.Index
		if let end = to, end >= 0, end < self.characters.count {
			endIndex = self.index(self.startIndex, offsetBy: end + 1)
		} else {
			endIndex = self.endIndex
		}

		return self[startIndex ..< endIndex]
	}

	func substring(from: Int) -> String {
		return self.substring(from: from, to: nil)
	}

	func substring(to: Int) -> String {
		return self.substring(from: nil, to: to)
	}
	subscript (i: Int) -> Character {
		return self[index(startIndex, offsetBy: i)]
	}

	subscript (i: Int) -> String {
		return String(self[i] as Character)
	}

	subscript (r: Range<Int>) -> String {
		let start = index(startIndex, offsetBy: r.lowerBound)
		let end = index(startIndex, offsetBy: r.upperBound)
		return self[Range(start ..< end)]
	}
}

func getInput(query: String, x: Int32, y: Int32) -> String {
	var input = ""
	var curx = x + query.characters.count
	let backspace = Character(UnicodeScalar(127))
	let delimeter = Character("\n")
	move(y, x)
	addstr(query)
	move(y, curx)
	refresh()
	while true {
		let ic = UInt32(getch())
		let c = Character(UnicodeScalar(ic)!)
		switch c {
			case backspace:
				guard curx != x + query.characters.count else { break }
				curx -= 1
				move(y, curx)
				delch()
				refresh()
				input = String(input.characters.dropLast())
			case delimeter:
				// clearline(y)
				return input
			default:
				if isprint(Int32(ic)) != 0 && String(c).characters.count == 1 {
					addch(UInt32(ic))
					curx += 1
					refresh()
					input.append(c)
				}
		}
	}
}

func printGallows(lives: Int, x: Int32, y: Int32) {
	move(y, x)
	addstr("┌───░░░────────────┐")
	move(y+1, x)
	addstr("│┴┐ ░░░┌┬─   -──-  │")
	move(y+2, x)
	addstr("└───░░░─┴──╲╲──┐ │ │")
	move(y+3, x)
	addstr("     ░      ╲╲ │ │ │")
	move(y+4, x)
	addstr("     ░       ╲╲│┌┘ │")
	move(y+5, x)
	addstr("     ░        ╲ │ ││")
	move(y+6, x+15)
	addstr("││ ││")
	move(y+7, x+15)
	addstr("││  │")
	move(y+8, x+15)
	addstr("│ ┌┘│")
	move(y+9, x+15)
	addstr("│ │ │")
	move(y+10, x+15)
	addstr("│ │││")
	move(y+11, x+15)
	addstr("││ ││")
	move(y+12, x+15)
	addstr("│└  │")
	move(y+13, x+15)
	addstr("│ │ │")
	move(y+14, x+15)
	addstr("│┌┤││")
	move(y+15, x+15)
	addstr("││  │")
	move(y+16, x+15)
	addstr("│   │")
	move(y+17, x+15)
	addstr("│  ││")
	move(y+18, x+15)
	addstr("│   │")
	move(y+19, x)
	addstr("┌──────────────┘   └───┐")
	move(y+20, x)
	addstr("└──────────────────────┘")
	if lives < 6 {
		move(y+6, x+4)
		addstr("███")
		move(y+7, x+3)
		addstr("█   █")
		move(y+8, x+3)
		addstr("█   █")
		move(y+9, x+4)
		addstr("███")
	}
	if lives < 5 {
		move(y+10, x+5)
		addstr("█")
		move(y+11, x+5)
		addstr("█")
		move(y+12, x+5)
		addstr("█")
		move(y+13, x+5)
		addstr("█")
		move(y+14, x+5)
		addstr("█")
	}
	if lives < 4 {
		move(y+11, x+4)
		addstr("█")
		move(y+12, x+3)
		addstr("█")
		move(y+13, x+2)
		addstr("█")
	}
	if lives < 3 {
		move(y+11, x+6)
		addstr("█")
		move(y+12, x+7)
		addstr("█")
		move(y+13, x+8)
		addstr("█")
	}
	if lives < 2 {
		move(y+15, x+4)
		addstr("█")
		move(y+16, x+4)
		addstr("█")
		move(y+17, x+3)
		addstr("██")
	}
	if lives < 1 {
		move(y+15, x+6)
		addstr("█")
		move(y+16, x+6)
		addstr("█")
		move(y+17, x+6)
		addstr("██")
	}
}

func printLetterList(text: String, x: Int32, y: Int32) {
	move(y, x)
	addstr(text.substring(to: 49))
	move(y+1, x)
	addstr(text.substring(from: 49))
}

func getFormat(text _text: String, width: Int, delimeter: String=" ") -> Array<String> {
	var text = _text.trimmingCharacters(in: .whitespacesAndNewlines)
	var lines: Array<String> = [String]()
	while text.characters.count > width {
		var index = width + 1
		while text[index..<index+delimeter.characters.count] != delimeter {
			index -= 1
			if index < 0 {
				index = width
				break
			}
		}
		lines.append(text.substring(to: index).trimmingCharacters(in: .whitespacesAndNewlines))
		text = text.substring(from: index)
	}
	if text != "" {
		lines.append(text.trimmingCharacters(in: .whitespacesAndNewlines))
	}
	return lines
}

func drawFormat(lines: Array<String>, x: Int32, y: Int32, newLine:Bool=false) -> Int32 {
	for l in lines.indices {
		move(y+(newLine ? l * 2 : l), x)
		addstr(lines[l])
	}
	return Int32(lines.count)
}

func printFormat(text _text: String, x: Int32, y: Int32, width: Int, delimeter: String=" ", newLine:Bool=false) -> Int32 {
	return drawFormat(lines: getFormat(text: _text, width: width, delimeter: delimeter), x: x, y: y, newLine: newLine)
}

func getGameBoard(letters: Array<Slot>) -> String {
	var formatted = ""
	for slot in letters {
		if slot.letter == Character(" ") {
			formatted += "  "
		} else if slot.guessed {
			formatted += " " + String(slot.letter)
		} else {
			formatted += " _"
		}
	}
	return formatted
}

func drawGameBoard(lines: Array<String>, xMin: Int32, xMax: Int32, yMin: Int32, yMax: Int32) {
	for l in lines.indices {
		move(1 + yMin + (yMax - yMin) / 2 + (l * 2 - lines.count), 1 + xMin + (xMax - xMin - lines[l].characters.count) / 2)
		addstr(lines[l])
	}
}

func drawGameOutline(yMin: Int32, yMax: Int32) {
	let x:Int32 = 49
	move(yMin, 1)
	addstr("┌" + String(repeating: "─", count: x-2) + "┐")
	for y in yMin+1...yMax {
		move(y, 1)
		addstr("│")
		move(y, x)
		addstr("│")
	}
	move(yMax, 1)
	addstr("└" + String(repeating: "─", count: x-2) + "┘")
}

struct Slot {
	var letter:Character = " "
	var guessed = false
}

func hangman(phrase _phrase: String, lives _lives: Int, screenHeight: Int32) -> Bool {
	var phrase:String = _phrase.lowercased()
	var lives:Int = _lives;
	var guesses = [String]()
	var guessesCorrect = [String]()
	var guessesIncorrect = [String]()
	var guessesAgain = [String]()
	var letters = [Slot]()
	var victory = false
	for letter in phrase.characters {
		var s = Slot()
		s.letter = letter
		if s.letter == Character(" ") {
			s.guessed = true
		}
		letters.append(s)
	}
	whileLoop: while true {
		clear()
		printGallows(lives: lives, x: 52, y: 1)
		var y:Int32 = 1
		y += printFormat(text: "Guessed Letters: " + guesses.joined(separator: ", "), x: 1, y: y, width: 48)
		y += printFormat(text: "Guessed Correct: " + guessesCorrect.joined(separator: ", "), x: 1, y: y + 1, width: 48) + 1
		y += printFormat(text: "Guessed Wrongly: " + guessesIncorrect.joined(separator: ", "), x: 1, y: y + 1, width: 48) + 1
		if (guessesAgain.count > 0) {
			y += printFormat(text: "You already guessed: " + guessesAgain.joined(separator: ", "), x: 1, y: y + 1, width: 48) + 1
			guessesAgain = [String]()
		}
		drawGameOutline(yMin: y+1, yMax: screenHeight - 3)
		drawGameBoard(lines: getFormat(text: getGameBoard(letters: letters), width: 45, delimeter: "   "), xMin: 1, xMax: 49, yMin: y+1, yMax: screenHeight - 3)
		victory = true
		for slot in letters {
			if slot.guessed == false {
				victory = false
			}
		}
		if victory || lives <= 0 {
			break whileLoop
		}
		var guess = getInput(query: "Enter a few letters: ", x: 1, y: screenHeight - 1).removeWhitespace().lowercased()
		for letter in guess.characters {
			if letter == Character(" ") {
				// Don't guess " "
			} else {
				if guesses.contains(String(letter)) {
					guessesAgain.append(String(letter))
				} else {
					guesses.append(String(letter))
					var correct = false
					for slot in letters.indices {
						if letter == letters[slot].letter {
							letters[slot].guessed = true
							correct = true
						}
					}
					if correct {
						guessesCorrect.append(String(letter))
						victory = true
						for slot in letters {
							if slot.guessed == false {
								victory = false
							}
						}
						if victory {
							break
						}
					} else {
						guessesIncorrect.append(String(letter))
						lives -= 1
						if lives <= 0 {
							break
						}
					}
				}
			}
		}
		refresh()
	}
	return victory
}

let screenWidth = getmaxx(stdscr)
let screenHeight = getmaxy(stdscr)

while true {
	clear()
	let phrase = getInput(query: "Enter a word or phrase: ", x: 1, y: screenHeight - 1)
	let victory = hangman(phrase: phrase, lives: 6, screenHeight: screenHeight)
	if getInput(query: "You \(victory ? "Win" : "Lose")! Would you like to play again (y/n): ", x: 1, y: screenHeight - 1).lowercased().characters.contains("n") {
		break
	}
	refresh()
}

endwin()
exit(EX_OK)

