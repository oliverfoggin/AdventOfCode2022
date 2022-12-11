import Foundation
import Parsing

private enum Parsers {
	static let calories = Parse {
		Many {
			Int.parser(of: Substring.self)
		} separator: {
			Whitespace(1, .vertical)
		}
	}

	static let input = Many {
		calories
	} separator: {
		Whitespace(2, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Day1: Day {
	let input: [Int]

	init() {
		guard let path = Bundle.main.path(forResource: "day1", ofType: "txt") else {
			input = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)

			input = try Parsers.input.parse(file).map { $0.reduce(0, +) }
		} catch {
			input = []
		}
	}

	var part1: Int {
		input.max() ?? 0
	}

	var part2: Int {
		input.sorted(by: >).prefix(upTo: 3).reduce(0, +)
	}
}
