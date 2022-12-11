import Foundation
import Parsing

typealias Crate = String

private struct Instruction {
	let count: Int
	let source: Int
	let dest: Int
}

private enum Parsers {
	static let crate = Parse(Crate.init) { "["; Prefix(1); "]" }
	static let noCrate = Parse { "   " }.map { Crate() }

	static let row = Many {
		OneOf { crate; noCrate }
	} separator: {
		" "
	} terminator: {
		Whitespace(1, .vertical)
	}

	static let instruction = Parse(Instruction.init) {
		"move "; Int.parser(); " from "; Int.parser(); " to "; Int.parser()
	}

	static let input = Parse {
		Many { row }
		Skip { PrefixUpTo("move") }
		Many {
			instruction
		} separator: {
			Whitespace(1, .vertical)
		} terminator: {
			Whitespace(1, .vertical)
		}
	}
}

private struct Storage {
	var stacks: [[Crate]]

	mutating func move(from source: Int, to dest: Int) {
		guard let crate =	stacks[source - 1].popLast() else {
			return
		}

		stacks[dest - 1].append(crate)
	}

	mutating func move(count: Int, from source: Int, to dest: Int) {
		let crates = stacks[source - 1].suffix(count)

		stacks[source - 1].removeLast(count)

		stacks[dest - 1].append(contentsOf: crates)
	}

	mutating func add(crate: String, to stack: Int) {
		if stack >= stacks.count {
			for _ in stacks.count...stack {
				stacks.append([])
			}
		}
		stacks[stack].insert(crate, at: 0)
	}

	var topRow: String {
		stacks.reduce(into: "") { partialResult, stack in
			partialResult.append(stack.last ?? "")
		}
	}
}

struct Day5: Day {
	private var storage: Storage
	private let instructions: [Instruction]

	init() {
		guard let path = Bundle.main.path(forResource: "day5", ofType: "txt") else {
			storage = Storage(stacks: [])
			instructions = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)
			let (stacks, instructions) = try Parsers.input.parse(file)

			storage = stacks.reduce(into: Storage(stacks: [])) { partialResult, row in
				row.enumerated()
					.filter { !$0.element.isEmpty }
					.forEach {
						partialResult.add(crate: $0.element, to: $0.offset)
					}
			}

			self.instructions = instructions
		} catch {
			print(error)
			storage = Storage(stacks: [])
			instructions = []
		}
	}

	var part1: String {
		instructions.reduce(into: storage) { partialResult, instruction in
			for _ in 0..<instruction.count {
				partialResult.move(from: instruction.source, to: instruction.dest)
			}
		}.topRow
	}

	var part2: String {
		instructions.reduce(into: storage) { partialResult, instruction in
			partialResult.move(count: instruction.count, from: instruction.source, to: instruction.dest)
		}.topRow
	}
}
