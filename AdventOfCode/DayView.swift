import SwiftUI

struct DayView: View {
	let title: String
	let source: any Day

	var body: some View {
		VStack {
			Text("Part 1: \(source.part1.description)")
			Text("Part 2: \(source.part2.description)")
		}
		.navigationTitle(title)
	}
}