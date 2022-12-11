import Foundation
import Parsing

private enum Parsers {
	static let row = Many(1...) {
		Digits(1)
	} separator: {
		""
	}

	static let input = Many {
		row
	} separator: {
		Whitespace(1, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Day8: Day {
	let forest: [[Int]]

	init() {
		guard let path = Bundle.main.path(forResource: "day8", ofType: "txt") else {
			forest = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)

			forest = try Parsers.input.parse(file)
		} catch {
			print(error)
			forest = []
		}
	}

	var part1: Int {
		forest.enumerated().reduce(0) { p, row in
			row.element.enumerated().reduce(into: p) { r, col in
				if isVisible(row: row.offset, col: col.offset) {
					r += 1
				}
			}
		}
	}

	var part2: Int {
		forest.enumerated().reduce(0) { p, row in
			row.element.enumerated().reduce(into: p) { r, col in
				let s = [
					scenicScoreNorth(row: row.offset, col: col.offset),
					scenicScoreSouth(row: row.offset, col: col.offset),
					scenicScoreEast(row: row.offset, col: col.offset),
					scenicScoreWest(row: row.offset, col: col.offset),
				].reduce(1, *)
				r = max(r, s)
			}
		}
	}

	func isVisible(row: Int, col: Int) -> Bool {
		return [
			visibleFromNorth(row: row, col: col),
			visibleFromSouth(row: row, col: col),
			visibleFromEast(row: row, col: col),
			visibleFromWest(row: row, col: col),
		].contains(true)
	}

	func visibleFromNorth(row: Int, col: Int) -> Bool {
		!(0..<row).contains {
			forest[$0][col] >= forest[row][col]
		}
	}

	func visibleFromSouth(row: Int, col: Int) -> Bool {
		!(row+1..<forest.count).contains {
			forest[$0][col] >= forest[row][col]
		}
	}

	func visibleFromWest(row: Int, col: Int) -> Bool {
		!(0..<col).contains {
			forest[row][$0] >= forest[row][col]
		}
	}

	func visibleFromEast(row: Int, col: Int) -> Bool {
		!(col+1..<forest[row].count).contains {
			forest[row][$0] >= forest[row][col]
		}
	}

	func scenicScoreNorth(row: Int, col: Int) -> Int {
		var sight = 0
		for n in stride(from: row-1, through: 0, by: -1) {
			sight += 1
			if forest[n][col] >= forest[row][col] {
				break
			}
		}
		return sight
	}

	func scenicScoreSouth(row: Int, col: Int) -> Int {
		var sight = 0
		for n in stride(from: row+1, to: forest.count, by: 1) {
			sight += 1
			if forest[n][col] >= forest[row][col] {
				break
			}
		}
		return sight
	}

	func scenicScoreWest(row: Int, col: Int) -> Int {
		var sight = 0
		for n in stride(from: col-1, through: 0, by: -1) {
			sight += 1
			if forest[row][n] >= forest[row][col] {
				break
			}
		}
		return sight
	}

	func scenicScoreEast(row: Int, col: Int) -> Int {
		var sight = 0
		for n in stride(from: col+1, to: forest[row].count, by: 1) {
			sight += 1
			if forest[row][n] >= forest[row][col] {
				break
			}
		}
		return sight
	}
}
