// swift-tools-version:4.0

import PackageDescription

let package = Package(
	name: "school",
	products: [
		.executable(name: "Fizzbuzz", targets: ["Fizzbuzz"]),
		.executable(name: "Decaguesser", targets: ["Decaguesser"]),
		.executable(name: "Hangman", targets: ["Hangman"]),
		.executable(name: "Battlemon", targets: ["Battlemon"]),
		.executable(name: "War", targets: ["War", "Cards", "DrawCards"]),
	],
	dependencies: [
		.package(url: "https://github.com/Bouke/CNCurses", from: "3.0.3")
	],
	targets: [
		.target(name: "Fizzbuzz"),
		.target(name: "Decaguesser"),
		.target(name: "Hangman"),
		.target(name: "Battlemon"),
		.target(name: "Cards"),
		.target(name: "DrawCards", dependencies: ["Cards"]),
		.target(name: "War", dependencies: ["Cards", "DrawCards"]),
	]
)
