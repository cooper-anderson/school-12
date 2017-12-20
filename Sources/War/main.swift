#!/usr/bin/swift

import Foundation
import CNCurses
import Cards
import DrawCards

func getNumber(_ query: String="") -> Int {
	while true {
		print(query, terminator: "")
		let rawInput = readLine()!
		if let input = Int(rawInput) {
			return input
		} else if rawInput.characters.count == 0 {
			return 32
		}
	}
}

func getInput(query: String, x: Int32, y: Int32) -> String {
	var input = ""
	var curx = x + Int32(query.characters.count)
	let backspace = Character(UnicodeScalar(127))
	let delimeter = Character("\n")
	curs_set(1)
	move(y, x)
	addstr(query)
	move(y, curx)
	refresh()
	while true {
		let ic = UInt32(getch())
		let c = Character(UnicodeScalar(ic)!)
		switch c {
			case backspace:
				guard curx != x + Int32(query.characters.count) else { break }
				curx -= 1
				move(y, curx)
				delch()
				refresh()
				input = String(input.characters.dropLast())
			case delimeter:
				curs_set(0)
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

print("Enter the first name: ", terminator: "")
let name1 = readLine()!
print("Enter the second name: ", terminator: "")
let name2 = readLine()!
var duration = max(min(getNumber("Enter the speed (default 32): "), 128), 1)
print("Do you want to play manually (Y/n): ", terminator: "")
var automode = readLine()!.lowercased().characters.contains("n")
var superfastmode = false
if automode {
	print("Do you want to use super-fast mode (y/N): ", terminator: "")
	superfastmode = readLine()!.lowercased().characters.contains("y")
}

setlocale(LC_ALL, "")
initscr()
noecho()
curs_set(0)

class Player {
	let name: String
	var hand: Deck
	var discard: Deck

	init(name: String="", cards: Array<Card>?=nil) {
		self.name = name
		if let c = cards {
			self.hand = Deck(full: false, cards: c)
		} else {
			self.hand = Deck(full: false)
		}
		self.discard = Deck(full: false)
	}

	func drawCard() -> Card? {
		if self.hand.count + self.discard.count == 0 {
			return nil
		} else if self.hand.count == 0 {
			self.hand.addCards(self.discard.popCards(count: self.discard.count)!)
			self.hand.shuffle()
		}
		return self.hand.popCard()
	}
}

class MovingCard {
	let card: Card
	var deck: Deck?
	var duration: Int
	var start: Array<Int32>
	var end: Array<Int32>
	var frame: Int=0

	init(card: Card, deck: Deck?=nil, duration: Int=16, start: Array<Int32>, end: Array<Int32>) {
		self.card = card
		self.deck = deck
		self.duration = duration
		self.start = start
		self.end = end
	}

	func reset(deck: Deck?=nil, duration: Int=16, start: Array<Int32>, end: Array<Int32>) {
		self.deck = deck
		self.duration = duration
		self.start = start
		self.end = end
		self.frame = 0
	}

	@discardableResult func draw() -> Bool {
		let penultimate: Bool = self.frame == self.duration - 1
		self.frame += self.frame < self.duration ? 1 : 0
		let ratio = Double(self.frame) / Double(self.duration)
		let x = Int32(Double(self.start[0]) + Double(self.end[0] - self.start[0]) * ratio)
		let y = Int32(Double(self.start[1]) + Double(self.end[1] - self.start[1]) * ratio)
		if !penultimate || self.deck == nil {
			self.card.draw(x: x, y: y)
		}
		if self.frame == self.duration, let finish = self.deck {
			finish.addCard(self.card)
			return true
		}
		return false
	}
}

class War {
	var left: Player
	var right: Player
	var tableLeft: Array<Card> = []
	var tableRight: Array<Card> = []
	var movingCards: Array<MovingCard> = []
	var warCount: Int = -1
	var duration: Int
	var round: Int = 0
	var animating: Bool {
		for c in self.movingCards {
			if c.frame < c.duration {
				return true
			}
		}
		return false
	}

	static let width: Int32 = 80
	static let height: Int32 = 24

	init(leftName: String="Player 1", rightName: String="Player 2", duration: Int=32) {
		let d = Deck(shuffle: true, visible: false)
		self.left = Player(name: leftName, cards: d.popCards(count: 26))
		self.right = Player(name: rightName, cards: d.popCards(count: 26))
		self.duration = duration
	}

	func playCard(leftCard: Card, rightCard: Card) {
		self.tableLeft.append(leftCard)
		var x = Int32(28 - 12 * ((self.tableLeft.count-1) / 7))
		var y = Int32(2 * ((self.tableLeft.count-1) % 7))
		self.movingCards.append(MovingCard(card: leftCard, duration: self.duration, start: [1, 3], end: [x, y]))
		self.tableRight.append(rightCard)
		x = Int32(Int(War.width) - 40 + 12 * ((self.tableRight.count-1) / 7))
		y = Int32(2 * ((self.tableRight.count-1) % 7))
		self.movingCards.append(MovingCard(card: rightCard, duration: self.duration, start: [War.width-13, 3], end: [x, y]))
	}

	func winRound(deck: Deck, end: Array<Int32>=[]) {
		if self.movingCards.count == 0 { return }
		for c in self.movingCards {
			c.reset(deck: deck, duration: self.duration, start: c.end, end: end)
		}
		self.tableLeft = []
		self.tableRight = []
		self.round += 1
	}

	@discardableResult func winRoundLeft() -> Int {
		self.winRound(deck: self.left.discard, end: [1, 12])
		return 1
	}

	@discardableResult func winRoundRight() -> Int {
		self.winRound(deck: self.right.discard, end: [War.width - 13, 12])
		return 2
	}

	func activateWar() {
		self.warCount = 3
	}

	@discardableResult func update() -> Int {

		var returnValue = 0

		if warCount < 0 {
			if self.tableLeft.count + self.tableRight.count > 0 {
				if self.tableLeft.last!.rank.rank == self.tableRight.last!.rank.rank {
					self.activateWar()
				} else if self.tableLeft.last!.rank.rank > self.tableRight.last!.rank.rank {
					return self.winRoundLeft()
				} else {
					return self.winRoundRight()
				}
			}
		}
		let leftCard: Card
		let rightCard: Card
		returnValue = self.warCount < 1 ? 0 : 3
		if self.left.hand.count + self.left.discard.count + self.right.hand.count + self.right.discard.count == 0 { return 6 }
		if let lc = self.left.drawCard() {
			leftCard = lc.flip(visible: self.warCount < 1)
		} else {
			return 4
		}
		if let rc = self.right.drawCard() {
			rightCard = rc.flip(visible: self.warCount < 1)
		} else {
			return 5
		}
		self.playCard(leftCard: leftCard, rightCard: rightCard)

		self.warCount -= self.warCount == -1 ? 0 : 1

		return returnValue
	}

	func draw(skipMovingCards: Bool=false) {
		if true {
			for y in 0...War.height-5 {
				move(y, 14)
				addstr("│")
				move(y, War.width - 15)
				addstr("│")
			}
			move(20, 0)
			addstr(String(repeating: "─", count: Int(War.width)))
			move(20, 14)
			addstr("┴")
			move(20, War.width - 15)
			addstr("┴")
		}
		move(0, max(0, Int32(14 - self.left.name.characters.count)/2))
		addstr(self.left.name)
		move(0, min(War.width - Int32(self.right.name.characters.count), (War.width - Int32((14 + self.right.name.characters.count))/2)))
		addstr(self.right.name)
		move(2, 5)
		addstr("Hand")
		move(2, War.width - 9)
		addstr("Hand")
		self.left.hand.draw(x: 1, y: 3, number: true)
		self.right.hand.draw(x: War.width - 13, y: 3, number: true)
		move(11, 3)
		addstr("Discard")
		move(11, War.width - 10)
		addstr("Discard")
		self.left.discard.draw(x: 1, y: 12, visible: true, number: true)
		self.right.discard.draw(x: War.width - 13, y: 12, visible: true, number: true)
		let leftScore = String(self.left.hand.count + self.left.discard.count)
		let rightScore = String(self.right.hand.count + self.right.discard.count)
		let round = "┤Round #\(self.round)├"
		move(War.height - 4, max(0, Int32(14 - leftScore.characters.count)/2))
		addstr(leftScore)
		move(War.height - 4, min(War.width - Int32(rightScore.characters.count), (War.width - Int32((14 + rightScore.characters.count))/2)))
		addstr(rightScore)
		move(War.height - 4, (War.width - Int32(round.characters.count))/2)
		addstr(round)
		if !skipMovingCards {
			var removed = 0
			for (index, card) in self.movingCards.enumerated() {
				var skip = false
				if card.draw() {
					self.movingCards.remove(at: index - removed)
					removed += 1
					skip = true
				}
				if skip {
					self.draw(skipMovingCards: true)
				}
			}
		}
	}
}

func logMessage(_ message: String="") {
	move(War.height - 2, 0)
	addstr(String(repeating: " ", count: Int(War.width)))
	move(War.height - 2, (War.width - Int32(message.characters.count)) / 2)
	addstr(message)
}

func setLog(value: Int=0, war: War) -> String {
	let log: String
	switch value {
	case 0:
		log = "Both players play a card"
	case 1:
		log = "\(war.left.name) wins round #\(war.round)"
	case 2:
		log = "\(war.right.name) wins round #\(war.round)"
	case 3:
		log = "WAR!"
	case 4:
		log = "\(war.right.name) WINS after \(war.round) rounds!"
	case 5:
		log = "\(war.left.name) WINS after \(war.round) rounds!"
	case 6:
		log = "TIE! YOU SHOULD GO BUY A LOTTERY TICKET!"
	default:
		log = ""
	}
	return log
}

var replay: Bool = true

while replay {
	replay = false
	let war: War = War(leftName: name1 == "" ? "Player 1" : name1, rightName: name2 == "" ? "Player 2" : name2, duration: duration)
	var log = ""
	var gameRunning = true

	while gameRunning {
		flushinp()
		clear()
		war.draw()
		logMessage(log)
		refresh()

		if !war.animating {
			let c = automode ? 32 : getch()
			var value: Int = -1
			if c == 32 {
				value = war.update()
				gameRunning = ![4, 5, 6].contains(value)
			} else if c == 91 {
				value = war.winRoundLeft()
			} else if c == 93 {
				value = war.winRoundRight()
			} else if c == 45 {
				if war.warCount == -1 {
					war.activateWar()
				}
				value = war.update()
			} else if c == 97 {
				logMessage("Continue the rest of the game in autopilot mode? (y/n)")
				refresh()
				if getch() == 121 {
					automode = true
				}
			} else if c == 115 {
				while true {
					let input = getInput(query: "Enter the new speed: ", x: 0, y: War.height-2)
					if input == "" {
						break
					} else if let number = Int(input) {
						war.duration = max(min(number, 128), 0)
						break
					}
				}
			} else if c == 113 {
				break
			}
			log = setLog(value: value, war: war)
		}
		if !superfastmode {
			usleep(1000000/60)
		}
	}

	if !gameRunning {
		logMessage(log + " Play again? (y/n)")
		refresh()
		while true {
			let c = getch()
			if c == 121 {
				replay = true
				break
			} else if c == 110 {
				break
			}
		}
	}
}

echo()
endwin()
exit(EX_OK)

