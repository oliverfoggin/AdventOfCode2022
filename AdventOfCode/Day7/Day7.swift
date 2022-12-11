import Foundation
import Parsing

enum Log {
	case cdRoot
	case cdParent
	case cdChild(dir: String)
	case fileSize(Int)
	case unknown
}

private enum Parsers {
	static let log = OneOf {
		"$ cd /".map { Log.cdRoot }
		"$ cd ..".map { Log.cdParent }
		Parse { "$ cd "; PrefixUpTo("\n") }.map { Log.cdChild(dir: String($0)) }
		Parse { Int.parser(); Skip { PrefixUpTo("\n") } }.map { Log.fileSize($0) }
		"$ ls".map { Log.unknown }
		Parse { "dir"; Skip { PrefixUpTo("\n") } }.map { Log.unknown }
	}

	static let input = Many {
		log
	} separator: {
		Whitespace(1, .vertical)
	} terminator: {
		Whitespace(1, .vertical)
	}
}

struct Day7: Day {
	let logs: [Log]
	let directorySizes: [String: Int]

	init() {
		guard let path = Bundle.main.path(forResource: "day7", ofType: "txt") else {
			logs = []
			directorySizes = [:]
			return
		}

		do {
			let file = try String(contentsOfFile: path, encoding: .utf8)

			logs = try Parsers.input.parse(file)

			var stack: [String] = []
			directorySizes = logs.reduce(into: [:]) { partialResult, log in
				switch log {
				case .cdRoot:
					stack = ["/"]
				case .cdChild(dir: let dir):
					stack.append(dir)
				case .cdParent:
					stack.removeLast()
				case .fileSize(let size):
					var path = ""
					for dir in stack {
						path.append(dir)
						partialResult[path] = (partialResult[path] ?? 0) + size
					}
				case .unknown:
					break
				}
			}

			print(logs)
		} catch {
			print(error)
			logs = []
			directorySizes = [:]
		}
	}

	var part1: Int {
		directorySizes.reduce(into: 0) { partialResult, data in
			if data.1 < 100000 {
				partialResult += data.1
			}
		}
	}

	var part2: Int {
		let diskSize = 70000000
		let reqSize = 30000000

		let usedSpace = directorySizes["/"] ?? 0
		let unusedSpace = diskSize - usedSpace

		let neededSpace = reqSize - unusedSpace
		
		return directorySizes.reduce(into: Int.max) { size, data in
			if neededSpace <= data.1, data.1 < size {
				size = data.1
			}
		}
	}
}
