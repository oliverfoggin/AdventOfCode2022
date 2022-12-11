protocol Day {
	associatedtype Output: CustomStringConvertible

	var part1: Output { get }
	var part2: Output { get }
}
