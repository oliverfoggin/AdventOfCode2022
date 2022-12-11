import Foundation
import Parsing

///
/// A/X = rock = 1 point
/// B/Y = paper = 2 points
/// C/Z = scissors = 3 points
///
/// win = 6
/// draw = 3
/// lose = 0

private enum RPS: Int {
	case rock = 1
	case paper = 2
	case scissors = 3

	init(string: String) {
		switch string {
		case "A", "X": self = .rock
		case "B", "Y": self = .paper
		default: self = .scissors
		}
	}

	func play(for outcome: Outcome) -> RPS {
		switch (self, outcome) {
		case (_, .draw): return self
		case (.rock, .lose), (.paper, .win): return .scissors
		case (.paper, .lose), (.scissors, .win): return .rock
		case (.scissors, .lose), (.rock, .win): return .paper
		}
	}
}

enum Outcome: Int {
	case win = 6
	case lose = 0
	case draw = 3

	fileprivate init(other: RPS, mine: RPS) {
		switch (other, mine) {
		case (.rock, .rock), (.paper, .paper), (.scissors, .scissors):
			self = .draw
		case (.rock, .paper), (.paper, .scissors), (.scissors, .rock):
			self = .win
		default:
			self = .lose
		}
	}
}

private struct PlayedGame {
	let other: RPS
	let myPlay: RPS

	var score: Int {
		Outcome(other: other, mine: myPlay).rawValue + myPlay.rawValue
	}
}

private struct DesiredGame {
	let other: RPS
	let desiredOutcome: Outcome

	var score: Int {
		desiredOutcome.rawValue + other.play(for: desiredOutcome).rawValue
	}
}

private enum Parsers {
	static let play = OneOf {
		"A".map { RPS.rock }
		"B".map { RPS.paper }
		"C".map { RPS.scissors }
		"X".map { RPS.rock }
		"Y".map { RPS.paper }
		"Z".map { RPS.scissors }
	}

	static let outcome = OneOf {
		"X".map { Outcome.lose }
		"Y".map { Outcome.draw }
		"Z".map { Outcome.win }
	}

	static let game = Parse(PlayedGame.init) {
		play
		" "
		play
	}

	static let desiredGame = Parse(DesiredGame.init) {
		play
		" "
		outcome
	}

	static let input1 = Parse {
		Many {
			game
		} separator: {
			Whitespace(1, .vertical)
		} terminator: {
			Whitespace(1, .vertical)
		}
	}

	static let input2 = Parse {
		Many {
			desiredGame
		} separator: {
			Whitespace(1, .vertical)
		} terminator: {
			Whitespace(1, .vertical)
		}
	}
}

struct Day2: Day {
	var part1: Int {
		guard let path = Bundle.main.path(forResource: "day2", ofType: "txt") else {
			print("no")
			return 0
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)

			let blah = try Parsers.input1.parse(file)

			return blah.map(\.score).reduce(0, +)
		} catch {
			print(error)
			return 0
		}
	}

	var part2: Int {
		guard let path = Bundle.main.path(forResource: "day2", ofType: "txt") else {
			print("no")
			return 0
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)

			let blah = try Parsers.input2.parse(file)

			return blah.map(\.score).reduce(0, +)
		} catch {
			print(error)
			return 0
		}
	}
}
