import Foundation
import Parsing

private enum Instruction {
	case addx(Int)
	case noop

	var cycles: Int {
		switch self {
		case .addx: return 2
		case .noop: return 1
		}
	}
}

private enum Parsers {
	static let instruction = OneOf {
		Parse { "addx "; Int.parser() }.map { Instruction.addx($0) }
		"noop".map { Instruction.noop }
	}

	static let input = Many {
		instruction
	} separator: {
		Whitespace(1, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Cycle {
	let start: Int
	let end: Int
}

struct Day10: Day {
	private let instructions: [Instruction]
	private let cycles: [Cycle]

	init() {
		guard let path = Bundle.main.path(forResource: "day10", ofType: "txt") else {
			instructions = []
			cycles = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)
			instructions = try Parsers.input.parse(file)

			cycles = instructions.reduce(into: []) { acc, instruction in
				let prev = acc.last ?? Cycle(start: 1, end: 1)
				acc.append(.init(start: prev.end, end: prev.end))
				switch instruction {
				case .noop: break
				case .addx(let value):
					acc.append(Cycle(start: prev.end, end: prev.end + value))
				}
			}
		} catch {
			instructions = []
			cycles = []
			print(error)
		}
	}

	var part1: String {
		String(stride(from: 19, to: cycles.count, by: 40).reduce(into: 0) { acc, index in
			acc += cycles[index].start * (index + 1)
		})
	}

	var part2: String {
		let output = cycles.enumerated().reduce(into: "") { partialResult, cycle in
			if cycle.offset % 40 == 0 {
				partialResult.append("\n")
			}

			if abs((cycle.offset % 40) - cycle.element.start) <= 1 {
				partialResult.append("#")
			} else {
				partialResult.append(".")
			}
		}

		print(output)

		return output
	}
}
