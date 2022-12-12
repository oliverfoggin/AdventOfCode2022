import Foundation
import Parsing

private struct Monkey {
	let id: Int
	var items: [Int]
	let function: OpType
	let functionValue: OpValue
	let predicateValue: Int
	let ifTrue: Int
	let ifFalse: Int

	var itemsInspected = 0

	init(id: Int, items: [Int], function: (OpType, OpValue), predicateValue: Int, ifTrue: Int, ifFalse: Int) {
		self.id = id
		self.items = items
		self.function = function.0
		self.functionValue = function.1
		self.predicateValue = predicateValue
		self.ifTrue = ifTrue
		self.ifFalse = ifFalse
	}

	mutating func throwItem(divideByThree: Bool = true) -> Int {
		var item = items.remove(at: 0)

		switch (function, functionValue) {
		case (.add, .number(let value)):
			item += value
		case (.add, .old):
			item += item
		case (.multiply, .number(let value)):
			item *= value
		case (.multiply, .old):
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

/*
 Monkey 1:
 Starting items: 54, 65, 75, 74
 Operation: new = old + 6
 Test: divisible by 19
 If true: throw to monkey 2
 If false: throw to monkey 0
 */

enum OpType {
	case add, multiply
}

enum OpValue {
	case number(Int)
	case old
}

private enum Parsers {
	static let items = Many(1...) {
		Int.parser(of: Substring.self)
	} separator: {
		", "
	}

	static let function = Parse {
		Skip { "new = old " }
		OneOf {
			"+".map { OpType.add }
			"*".map { OpType.multiply }
		}
		Skip { " " }
		OneOf {
			Int.parser().map { OpValue.number($0) }
			"old".map { OpValue.old }
		}
	}

	static let monkey = Parse(Monkey.init) {
		Skip { "Monkey " }
		Int.parser()
		Skip { PrefixThrough("items: ") }
		items
		Skip { PrefixThrough("Operation: ") }
		function
		Skip { PrefixThrough("divisible by ") }
		Int.parser()
		Skip { PrefixThrough("throw to monkey ") }
		Int.parser()
		Skip { PrefixThrough("throw to monkey ") }
		Int.parser()
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
			print(round)
		}
		.map(\.itemsInspected)
		.sorted(by: >)
		.prefix(2)
		.reduce(1, *)

		print(output)

		return output
	}
}
