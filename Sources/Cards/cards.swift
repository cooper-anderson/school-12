import Foundation
import UIKit

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
	static let back:UIImage = UIImage(named: "card_back.png")!
	public let suit: Suit
	public let rank: Rank
	public var visible: Bool
	public var description: String {return "<\(self.getPrint())>"}
	public let imageView:UIImageView
    public let image:UIImage

	public init(suit: Suit, rank: Rank, visible: Bool=true) {
		self.suit = suit
		self.rank = rank
		self.visible = visible
		self.imageView = UIImageView(frame: CGRect(x: 50, y: 50, width: 80, height: 116))
        self.image = UIImage(named: ((self.rank.value == 10) ? ("10") : (self.rank.value <= 9) ? (String(self.rank.rank)) : (self.rank.name.lowercased())) + "_of_" + self.suit.name.lowercased() + ".png")!
        self.imageView.image = self.image
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
    
    @discardableResult public func draw(_ view:UIView) -> Card {
        view.addSubview(self.imageView)
        return self
    }
    
    @discardableResult public func move(x:CGFloat, y:CGFloat) -> Card {
        self.imageView.center.x = x
        self.imageView.center.y = y
        return self
    }
    
    @discardableResult public func move(_ waypoint:UIImageView) -> Card {
        self.move(x: waypoint.center.x, y: waypoint.center.y)
        return self
    }
    
    @discardableResult public func animate(x:CGFloat, y:CGFloat) -> Card {
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.move(x: x, y: y)
        })
        return self
    }
    
    @discardableResult public func animate(_ waypoint:UIImageView) -> Card {
        self.animate(x: waypoint.center.x, y: waypoint.center.y)
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
	public var count: Int {
		return self.cards.count
	}
	public var description: String {
		return "<\(self.getPrint())>"
	}

	public init(full: Bool=true, shuffle: Bool=false, visible: Bool=false, cards: Array<Card>?=nil) {
		if full {
			self.cards = Card.cards
		} else if let c = cards {
			self.cards = c
		} else {
			self.cards = []
		}
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

	@discardableResult public func popCards(count: Int=2) -> Array<Card>? {
		if count > self.cards.count {
			return nil
		}
		var list: Array<Card> = []
		for _ in 1...count {
			list.append(self.popCard()!)
		}
		return list
	}

	@discardableResult public func addCard(_ card: Card) -> Deck {
		self.cards.insert(card, at: 0)
		return self
	}

	@discardableResult public func addCards(_ cards: Array<Card>) -> Deck {
		for c in cards {
			self.addCard(c)
		}
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

