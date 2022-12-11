import Foundation
import Parsing

typealias Assignment = ClosedRange<Int>

private enum Parsers {
	static let assignment = Parse(Assignment.init(uncheckedBounds:)) {
		Int.parser()
		"-"
		Int.parser()
	}

	static let assignmentPair = Parse {
		assignment
		","
		assignment
	}

	static let input = Many {
		assignmentPair
	} separator: {
		Whitespace(1, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Day4: Day {
	let assignments: [(Assignment, Assignment)]

	init() {
		guard let path = Bundle.main.path(forResource: "day4", ofType: "txt") else {
			assignments = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)

			assignments = try Parsers.input.parse(file)
		} catch {
			print(error)
			assignments = []
		}
	}

	var part1: Int {
		assignments.filter { (a, b) in
			a.surrounds(other: b) || b.surrounds(other: a)
		}
		.count
	}

	var part2: Int {
		assignments.filter { (a, b) in
			a.overlaps(b)
		}
		.count
	}
}

extension ClosedRange {
	func surrounds(other: ClosedRange) -> Bool {
		return lowerBound <= other.lowerBound && other.upperBound <= upperBound
	}
}
