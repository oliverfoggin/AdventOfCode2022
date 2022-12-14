import Foundation
import Parsing

enum Direction {
	case up, down, left, right
}

struct Movement {
	let direction: Direction
	let count: Int
}

private enum Parsers {
	static let move = OneOf {
		Parse { "R "; Int.parser() }.map { Movement(direction: .right, count: $0) }
		Parse { "L "; Int.parser() }.map { Movement(direction: .left, count: $0) }
		Parse { "U "; Int.parser() }.map { Movement(direction: .up, count: $0) }
		Parse { "D "; Int.parser() }.map { Movement(direction: .down, count: $0) }
	}

	static let input = Many {
		move
	} separator: {
		Whitespace(1, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Point: Hashable {
	let x: Int
	let y: Int

	static var zero: Self {
		.init(x: 0, y: 0)
	}

	func move(dir: Direction) -> Self {
		switch dir {
		case .right: return .init(x: x+1, y: y)
		case .left: return .init(x: x-1, y: y)
		case .up: return .init(x: x, y: y+1)
		case .down: return .init(x: x, y: y-1)
		}
	}

	func isTouching(other: Point) -> Bool {
		abs(x - other.x) <= 1 && abs(y - other.y) <= 1
	}

	func chase(other: Point) -> Self {
		if isTouching(other: other) {
			return self
		}

		switch (x == other.x, y == other.y) {
		case (true, true):
			return self
		case (false, true):
			return .init(
				x: x - (x - other.x)/abs(x - other.x),
				y: y
			)
		case (true, false):
			return .init(
				x: x,
				y: y - (y - other.y)/abs(y - other.y)
			)
		case (false, false):
			return .init(
				x: x - (x - other.x)/abs(x - other.x),
				y: y - (y - other.y)/abs(y - other.y)
			)
		}
	}
}

struct Board: CustomDebugStringConvertible {
	var visited: Set<Point> = []
	var ropePositions: [Point]

	var debugDescription: String {
		let minX =
	}

	init(ropeLength: Int) {
		ropePositions = Array(repeating: .zero, count: ropeLength)
	}

	var tail: Point {
		ropePositions.last ?? .zero
	}

	mutating func moveHead(direction: Direction) {
		ropePositions[0] = ropePositions[0].move(dir: direction)

		for i in 1..<ropePositions.count {
			ropePositions[i] = ropePositions[i].chase(other: ropePositions[i-1])
		}

		visited.insert(tail)
	}
}

struct Day9: Day {
	let movements: [Movement]

	init() {
		guard let path = Bundle.main.path(forResource: "day9", ofType: "txt") else {
			movements = []
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)
			movements =  try Parsers.input.parse(file)

		} catch {
			print(error)
			movements = []
		}
	}

	var part1: Int {
		movements.reduce(into: Board(ropeLength: 2)) { board, move in
			for _ in 0..<move.count {
				board.moveHead(direction: move.direction)
			}
		}.visited.count
	}

	var part2: Int {
		movements.reduce(into: Board(ropeLength: 10)) { board, move in
			for _ in 0..<move.count {
				board.moveHead(direction: move.direction)
			}
		}.visited.count
	}
}
