#!/usr/bin/swift

import Foundation
// import Darwin.ncurses
// setlocale(LC_ALL, "")
// initscr()
// noecho()

extension Double {
	/// Rounds the double to decimal places value
	func rounded(toPlaces places:Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return (self * divisor).rounded() / divisor
	}
}

class Vector : CustomStringConvertible {
	var x: Double = 0
	var y: Double = 0
	var magnitude: Double {
		get {
			return (pow(self.x, 2) + pow(self.y, 2)).squareRoot()
		}
	}
	var normalized: Vector {
		if self.magnitude != 0 {
			return Vector(self.x / self.magnitude, self.y / self.magnitude)
		} else {
			return Vector()
		}
	}
	var description: String {
		return "(x: \(self.x.rounded(toPlaces: 4)), y: \(self.y.rounded(toPlaces: 4)))"
	}

	init(x: Double=0, y: Double=0) {
		self.x = x
		self.y = y
	}

	init(_ x: Double=0, _ y: Double=0) {
		self.x = x
		self.y = y
	}
}

func getRandom(min:Int, max:Int) -> Int {
	let x = Int(arc4random_uniform(UInt32(max - min + 1)) + UInt32(min))
	return x
}

func rollDice(count: Int = 1, sides: Int = 6) -> Int {
	var value:Int = 0
	for _ in 0...count-1 {
		value += getRandom(min: 1, max: 6)
	}
	return value
}

class Weapon : CustomStringConvertible {
	let name: String
	let damageMin: Int
	let damageMax: Int
	var description: String {
		return "\(self.name) (\(self.damageMin) - \(self.damageMax))"
	}

	init(name: String = "", damageMin: Int = 0, damageMax: Int = 0) {
		self.name = name
		self.damageMin = damageMin
		self.damageMax = damageMax
	}

	func getDamage() -> Int {
		return getRandom(min: self.damageMin, max: self.damageMax)
	}

	static func getRandomName() -> String {
		let modifiers = ["Broken", "Average", "Rare", "Mythical", "Legendary", "Sublime", "Unreal", "Rusty", "Large"]
		let weapons = ["Spork", "Sword", "Axe", "Hammer", "Chainsaw", "Wooden Spoon", "Mace", "Nunchucks", "Chair"]
		return modifiers[getRandom(min: 1, max: modifiers.count) - 1] + " " + weapons[getRandom(min: 1, max: weapons.count) - 1]
	}
}

class Armor : CustomStringConvertible {
	let name: String
	let defense: Int
	var durability: Int
	var description: String {
		return "\(self.name) (def: \(self.defense), dur: \(self.durability))"
	}

	init(name: String = "", defense: Int = 0, durability: Int = 0) {
		self.name = name
		self.defense = defense
		self.durability = durability
	}

	func getDefense(target: Monster, damage: Int) -> Int {
		if getRandom(min: 0, max: 10) <= 2 && self.durability >= 0 {
			let defended = self.defense > damage ? damage : self.defense
			self.durability -= 1
			print("\(target.name) readies their \(self.name) and blocks for \(defended)")
			return defended
		}
		return 0
	}

	static func getRandomName() -> String {
		let modifiers = ["Broken", "Average", "Rare", "Mythical", "Legendary", "Sublime", "Unreal", "Rusty", "Large"]
		let weapons = ["Shirt", "Chestplate", "Hauberk", "Leggings", "Greaves", "Helm", "Shield", "Gauntlets", "Thing"]
		return modifiers[getRandom(min: 1, max: modifiers.count) - 1] + " " + weapons[getRandom(min: 1, max: weapons.count) - 1]
	}
}

class Monster : CustomStringConvertible {
	let name: String
	let dexterity: Int
	var health: Int
	let healthMax: Int
	var weapon: Weapon
	var armor: Armor
	var description: String {
		return "\(name):\n  weapon: \(self.weapon)\n  armor: \(self.armor)\n  dexterity: \(self.dexterity)\n  health: \(self.health)/\(self.healthMax)"
	}

	init(name: String = "") {
		self.name = name
		self.dexterity = rollDice(count: 3)
		self.healthMax = rollDice(count: 10)
		self.health = self.healthMax
		let damageMin = rollDice(count: 2)
		self.weapon = Weapon(name: Weapon.getRandomName(), damageMin: damageMin, damageMax: damageMin + rollDice(count: 1))
		self.armor = Armor(name: Armor.getRandomName(), defense: rollDice(count: 2), durability: rollDice(count: 3, sides: 2) - 3)
	}

	func attack(target: Monster) {
		if self.health < 0 {
			return
		} else if getRandom(min: 0, max: 19) < self.dexterity {
			var damage = self.weapon.getDamage()
			damage -= target.armor.getDefense(target: target, damage: damage)
			print("\(self.name) dealt \(damage) damage with \(self.weapon.name)!")
			target.health -= damage
		} else {
			print("\(self.name) missed!")
		}
	}
}

print("Enter the first name: ", terminator: "")
let name1 = readLine()!
print("Enter the second name: ", terminator: "")
let name2 = readLine()!

var mon1 = Monster(name: name1)
var mon2 = Monster(name: name2)
var turn: Int = 0

print("\n\(mon1)\n\n\(mon2)")

while mon1.health > 0 && mon2.health > 0 {
	print("\nTurn: \(turn)")
	mon1.attack(target: mon2)
	mon2.attack(target: mon1)
	turn += 1
}

if mon1.health > 0 {
	print("\n\(mon1.name) wins with \(mon1.health) out of \(mon1.healthMax) health left.")
} else {
	print("\n\(mon2.name) wins with \(mon2.health) out of \(mon2.healthMax) health left.")
}

