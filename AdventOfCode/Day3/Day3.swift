import Parsing
import Foundation

extension Character {
	var score: Int {
		guard let asciiValue else {
			return 0
		}

		let score = Int(asciiValue)

		switch score {
		case 65...90: return score - 38
		case 97...122: return score - 96
		default: return 0
		}
	}
}

private enum Parsers {
	static let contents = Parse(Rucksack.init) {
		PrefixUpTo("\n").map(String.init)
	}

	static let input = Many {
		contents
	} separator: {
		Whitespace(1, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Rucksack {
	let left: String
	let right: String

	init(contents: String) {
		left = String(contents.prefix(contents.count / 2))
		right = String(contents.suffix(contents.count / 2))
	}

	var commonItem: Character? {
		guard let common = Set(left).intersection(right).first else {
			return nil
		}

		return Character(String(common))
	}

	var allItems: Set<Character> {
		Set(left + right)
	}

	static func commonItem(between bags: [Rucksack]) -> Character? {
		var bags = bags

		let first = bags.removeFirst()

		return bags.reduce(into: first.allItems) { partialResult, sack in
			partialResult = partialResult.intersection(sack.allItems)
		}.first
	}

	var score: Int {
		commonItem?.score ?? 0
	}
}

struct Day3: Day {
	let bags: [Rucksack]

	init() {
		guard let path = Bundle.main.path(forResource: "day3", ofType: "txt") else {
			bags = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)

			bags = try Parsers.input.parse(file)
		} catch {
			print(error)
			bags = []
		}
	}

	var part1: Int {
		bags.map(\.score).reduce(0, +)
	}

	var part2: Int {
		stride(from: 0, to: bags.count, by: 3).map {
			Array(bags[$0..<min($0+3, bags.count)])
		}
		.compactMap { Rucksack.commonItem(between: $0) }
		.map(\.score)
		.reduce(0, +)
	}
}
