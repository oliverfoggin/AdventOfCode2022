import Foundation
import Parsing

private struct Monkey {
	let id: Int
	var items: [Int]
	let function: Command
	let predicateValue: Int
	let ifTrue: Int
	let ifFalse: Int

	var itemsInspected = 0

	init(id: Int, items: [Int], function: Command, predicateValue: Int, ifTrue: Int, ifFalse: Int) {
		self.id = id
		self.items = items
		self.function = function
		self.predicateValue = predicateValue
		self.ifTrue = ifTrue
		self.ifFalse = ifFalse
	}

	mutating func throwItem(divideByThree: Bool = true) -> Int {
		var item = items.remove(at: 0)

		switch function {
		case .add(let number):
			item += number
		case .multiply(let number):
			item *= number
		case .square:
			item *= item
		}

		if divideByThree {
			item /= 3
		}

		itemsInspected += 1

		return item
	}

	func testItem(_ item: Int) -> Bool {
		item % predicateValue == 0
	}

	mutating func catchItem(_ item: Int) {
		items.append(item)
	}
}

enum Command {
	case add(Int)
	case multiply(Int)
	case square
}

private enum Parsers {
	static let items = Many(1...) {
		Int.parser(of: Substring.self)
	} separator: {
		", "
	}

	static let function = Parse {
		"new = old "
		OneOf {
			Parse { "+ "; Int.parser() }.map { Command.add($0) }
			Parse { "* "; Int.parser() }.map { Command.multiply($0) }
			"* old".map { Command.square }
		}
	}

	/*
	 Monkey 1:
	 Starting items: 54, 65, 75, 74
	 Operation: new = old + 6
	 Test: divisible by 19
	 If true: throw to monkey 2
	 If false: throw to monkey 0
	 */

	static let monkey = Parse(Monkey.init) {
		"Monkey "; Int.parser(); ":\n"
		"  Starting items: "; items; "\n"
		"  Operation: "; function; "\n"
		"  Test: divisible by "; Int.parser(); "\n"
		"    If true: throw to monkey "; Int.parser(); "\n"
		"    If false: throw to monkey "; Int.parser();
	}

	static let input = Many {
		monkey
	} separator: {
		Whitespace(2, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Day11: Day {
	private var monkeys: [Monkey]

	init() {
		guard let path = Bundle.main.path(forResource: "day11", ofType: "txt") else {
			monkeys = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)
			monkeys = try Parsers.input.parse(file)
		} catch {
			print(error)
			monkeys = []
		}
	}

	var part1: Int {
		(0..<20).reduce(into: monkeys) { monkeys, _ in
			for i in 0..<monkeys.count {
				while !monkeys[i].items.isEmpty {
					let item = monkeys[i].throwItem()

					if monkeys[i].testItem(item) {
						monkeys[monkeys[i].ifTrue].catchItem(item)
					} else {
						monkeys[monkeys[i].ifFalse].catchItem(item)
					}
				}
			}
		}
		.map(\.itemsInspected)
		.sorted(by: >)
		.prefix(2)
		.reduce(1, *)
	}

	var part2: Int {
		let totalDivider = monkeys.map(\.predicateValue).reduce(1, *)

		let output = (0..<10000).reduce(into: monkeys) { monkeys, round in
			for i in 0..<monkeys.count {
				while !monkeys[i].items.isEmpty {
					var item = monkeys[i].throwItem(divideByThree: false)

					item %= totalDivider

					if monkeys[i].testItem(item) {
						monkeys[monkeys[i].ifTrue].catchItem(item)
					} else {
						monkeys[monkeys[i].ifFalse].catchItem(item)
					}
				}
			}
		}
		.map(\.itemsInspected)
		.sorted(by: >)
		.prefix(2)
		.reduce(1, *)

		print(output)

		return output
	}
}
