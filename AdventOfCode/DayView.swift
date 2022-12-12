import SwiftUI

struct DayView: View {
	let day: DayModel
	let source: any Day

	init(day: DayModel) {
		self.day = day
		source = day.source()
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			Link(day.title, destination: day.url)
				.padding()
				.background(Color(white: 0.94))
				.cornerRadius(12)
				.padding()
				.frame(maxWidth: .infinity)
			Group {
				Text("Part 1: \(source.part1.description)")
				Text("Part 2: \(source.part2.description)")
			}
				.font(.footnote)
			Spacer()
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding()
		.monospaced()
		.navigationTitle(day.pageTitle)
	}
}
