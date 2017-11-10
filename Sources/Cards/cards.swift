import Foundation

// public func shuffleCards(array: Array<Any>, iterations: Int=1) -> Array<Any> {
// 	var new = array
// 	for _ in 1...iterations {
// 		var current: Array<Any> = []
// 		for _ in 1...new.count {
// 			current.append(new.remove(at: getRandom(min: 0, max: new.count-1)))
// 		}
// 		new = current
// 	}
// 	return new
// }
public extension Array {
	public func shuffle(iterations: Int=1) -> Array {
		var new = self
		for _ in 1...iterations {
			var current: Array = []
			for _ in 1...new.count {
				current.append(new.remove(at: getRandom(min: 0, max: new.count-1)))
			}
			new = current
		}
		return new
	}
}

public func getRandom(min:Int, max:Int) -> Int {
	return Int(arc4random_uniform(UInt32(max - min + 1)) + UInt32(min))
}

public class Suit {
	public let name: String
	public let letter: String

	public init(name: String, letter: String) {
		self.name = name
		self.letter = letter
	}

	public static let suits: Array<Suit> = [
		Suit(name: "Spades", letter: "♠"),
		Suit(name: "Hearts", letter: "♥"),
		Suit(name: "Clubs", letter: "♣"),
		Suit(name: "Diamonds", letter: "♦")
	]
}

public class Rank {
	public let name: String
	public let letter: String
	public let rank: Int
	public let value: Int

	public init(name: String, letter: String, rank: Int, value: Int) {
		self.name = name
		self.letter = letter
		self.rank = rank
		self.value = value
	}

	public static let ranks: Array<Rank> = [
		Rank(name: "Ace", letter: "A", rank: 14, value: 11),
		Rank(name: "Two", letter: "2", rank: 2, value: 2),
		Rank(name: "Three", letter: "3", rank: 3, value: 3),
		Rank(name: "Four", letter: "4", rank: 4, value: 4),
		Rank(name: "Five", letter: "5", rank: 5, value: 5),
		Rank(name: "Six", letter: "6", rank: 6, value: 6),
		Rank(name: "Seven", letter: "7", rank: 7, value: 7),
		Rank(name: "Eight", letter: "8", rank: 8, value: 8),
		Rank(name: "Nine", letter: "9", rank: 9, value: 9),
		Rank(name: "Ten", letter: "X", rank: 10, value: 10),
		Rank(name: "Jack", letter: "J", rank: 11, value: 10),
		Rank(name: "Queen", letter: "Q", rank: 12, value: 10),
		Rank(name: "King", letter: "K", rank: 13, value: 10)
	]
}

public class Card: CustomStringConvertible {
	public let suit: Suit
	public let rank: Rank
	public var visible: Bool
	public var description: String {
		return "<\(self.getPrint())>"
	}

	public init(suit: Suit, rank: Rank, visible: Bool=true) {
		self.suit = suit
		self.rank = rank
		self.visible = visible
	}

	public func getPrint(abbreviate: Bool=false) -> String {
		if abbreviate {
			return self.rank.letter + self.suit.letter
		}
		return "\(self.rank.name) of \(self.suit.name)"
	}

	@discardableResult public func flip(visible: Bool?=nil) -> Card {
		if let v = visible {
			self.visible = v
			return self
		}
		self.visible = !self.visible
		return self
	}

	public static var cards: Array<Card> {
		var cards: Array<Card> = []
		for suit in Suit.suits {
			for rank in Rank.ranks {
				cards.append(Card(suit: suit, rank: rank))
			}
		}
		return cards
	}
}

public class Deck: CustomStringConvertible {
	public var cards: Array<Card>
	public var description: String {
		return "<\(self.getPrint())>"
	}

	public init(full: Bool=true, shuffle: Bool=false, visible: Bool=false) {
		self.cards = full ? Card.cards : []
		if shuffle {
			self.shuffle()
		}
		self.setCardVisibility(visible: visible)
	}

	@discardableResult public func shuffle(iterations: Int=1) -> Deck {
		self.cards = self.cards.shuffle(iterations: iterations)
		return self
	}

	@discardableResult public func popCard(index: Int=0) -> Card? {
		if index == -1 {
			return self.cards.remove(at: -1)
		}
		return index < self.cards.count ? self.cards.remove(at: index) : nil
	}

	@discardableResult public func addCard(_ card: Card) -> Deck {
		self.cards.insert(card, at: 0)
		return self
	}

	@discardableResult public func setCardVisibility(visible: Bool) -> Deck {
		for c in self.cards {
			c.flip(visible: visible)
		}
		return self
	}

	@discardableResult public func reverse() -> Deck {
		self.cards = self.cards.reversed()
		return self
	}

	@discardableResult public func flip(visible: Bool?=nil) -> Deck {
		for c in self.cards {
			c.flip(visible: visible)
		}
		self.reverse()
		return self
	}

	public func getPrint(abbreviate: Bool=false, separator: String=", ") -> String {
		var array: Array<String> = []
		for c in self.cards {
			array.append(c.getPrint(abbreviate: abbreviate))
		}
		return array.joined(separator: separator)
	}
}

