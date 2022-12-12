import Foundation

struct DayModel: Identifiable {
	let id: Int
	let title: String
	let source: () -> any Day

	var url: URL {
		URL(string: "https://adventofcode.com/2022/day/\(id)")!
	}
}

protocol Day {
	associatedtype Output: CustomStringConvertible

	var part1: Output { get }
	var part2: Output { get }
}
