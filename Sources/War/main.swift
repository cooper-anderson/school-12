#!/usr/bin/swift

import Foundation
import CNCurses
import Cards
import DrawCards

setlocale(LC_ALL, "")
initscr()
noecho()
curs_set(0)

let screenWidth = getmaxx(stdscr)
let screenHeight = getmaxy(stdscr)
var d: Deck = Deck()
var e: Deck = Deck(full: false)
var posx: Int32 = 0
var posy: Int32 = 0

let simple: Bool = false
let w: Int = simple ? 4 : 11
let h: Int = simple ? 3 : 8

clear()

while true {
	clear()
	// d.shuffle()

	posx = Int32(getRandom(min: 0, max: Int(screenWidth)-w))
	posy = Int32(getRandom(min: 0, max: Int(screenHeight)-h))
	d.draw(x: 2, y: 2, visible: true, number: true)
	e.draw(x: 16, y: 2, visible: true, number: true)
	// d.cards[0].flip(visible: false).draw(x: posx, y: posy, simple: simple)
	// posx = Int32(getRandom(min: 0, max: Int(screenWidth)-w))
	// posy = Int32(getRandom(min: 0, max: Int(screenHeight)-h))
	// d.cards[1].draw(x: posx, y: posy, simple: simple)
	refresh()

	if getch() == 113 {
		break
	}
	if let card = d.popCard() {
		e.addCard(card)
	} else {
		d = e
		e = Deck(full: false)
	}
}

echo()
endwin()
exit(EX_OK)
