import Foundation

struct Day6: Day {
	let data: String

	init() {
		guard let path = Bundle.main.path(forResource: "day6", ofType: "txt") else {
			data = ""
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)
			data = file.components(separatedBy: .whitespacesAndNewlines).first ?? ""
		} catch {
			data = ""
		}
	}

	var part1: Int {
		processData(withLength: 4)
	}

	var part2: Int {
		processData(withLength: 14)
	}

	func processData(withLength length: Int) -> Int {
		var offset = 0

		while offset < data.count - (length - 1) {
			let start = data.index(data.startIndex, offsetBy: offset)
			let end = data.index(start, offsetBy: (length - 1))

			let word = data[start...end]

			if Set(word).count == length {
				break
			}

			offset += 1
		}

		return offset + length
	}
}
