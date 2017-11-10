import Foundation
// import Darwin.ncurses
import CNCurses
// import func Darwin.ncurses.move
// import func Darwin.ncurses.addstr
import Cards

public extension Card {
	public func draw(x: Int32=0, y: Int32=0, simple: Bool=false) {
		move(y, x)
		if simple {
			addstr("╭──╮")
			move(y+1, x)
			addstr("│" + (self.visible ? self.getPrint(abbreviate: true) : "??") + "│")
			move(y+2, x)
			addstr("╰──╯")
		} else {
				addstr("╭─────────╮")
				if !self.visible {
					for i in 1...3 {
						move(y+Int32(i*2-1), x)
						addstr("│?   ?   ?│")
					}
					for i in 1...3 {
						move(y+Int32(i*2), x)
						addstr("│  ?   ?  │")
					}
					move(y+7, x)
					addstr("╰─────────╯")
				} else {
				for i in 1...6 {
					move(y+Int32(i), x)
					addstr("│         │")
				}
				move(y+7, x)
				addstr("╰─────────╯")
				move(y+1, x+1)
				if self.rank.rank == 10 {
					addstr("10" + self.suit.letter)
					move(y+6, x+7)
					addstr("10" + self.suit.letter)
				} else {
					addstr(self.rank.letter + self.suit.letter)
					move(y+6, x+8)
					addstr(self.rank.letter + self.suit.letter)
				}
				func quick(_ dx: Int32, _ dy: Int32) {
					move(y+dy+2, x+dx*2+3)
					addstr(self.suit.letter)
				}
				if [10, 11, 12, 13].contains(self.rank.rank) { quick(0, 0); quick(2, 0) }
				if [5, 6, 7, 8, 9, 11, 12].contains(self.rank.rank) { quick(1, 0) }
				if [4, 5, 6, 7, 8, 9, 10, 12, 13].contains(self.rank.rank) { quick(0, 1) }
				if [14, 2, 3, 8, 9, 10, 11, 13].contains(self.rank.rank) { quick(1, 1) }
				if [4, 5, 6, 7, 8, 9, 10, 12].contains(self.rank.rank) { quick(2, 1) }
				if [3, 4, 5, 6, 7, 8, 9, 10, 12, 13].contains(self.rank.rank) { quick(0, 2) }
				if [2, 7, 8, 9, 10, 11, 13].contains(self.rank.rank) { quick(1, 2) }
				if [3, 4, 5, 6, 7, 8, 9, 10, 12].contains(self.rank.rank) { quick(2, 2) }
				if [9, 10, 11, 12, 13].contains(self.rank.rank) { quick(0, 3) }
				if [6, 7, 8, 10, 11, 12].contains(self.rank.rank) { quick(1, 3) }
				if [9, 10, 12, 13].contains(self.rank.rank) { quick(2, 3) }
			}
		}
	}
}

public extension Deck {
	public func draw(x: Int32=0, y: Int32=0, visible: Bool=false, number: Bool=false) {
		if self.cards.count == 0 {
			return
		}
		if self.cards.count > 1 {
			move(y, x)
			addstr("╭")
			for i in 1...6 {
				move(y+Int32(i), x)
				addstr("│")
			}
			move(y+7, x)
			addstr("╰")
		}
		self.cards[0].flip(visible: visible).draw(x: x+1, y: y)
		if number && self.cards.count > 1 {
			move(y, x+10-Int32(String(self.cards.count).characters.count))
			addstr(String(self.cards.count))
		}
	}
}

