import SwiftUI

private let allDays: [DayModel] = [
	.init(id: 1, title: "Day 1: Calorie Counting", source: Day1.init),
	.init(id: 2, title: "Day 2: Rock Paper Scissors", source: Day2.init),
	.init(id: 3, title: "Day 3: Rucksack Reorganization", source: Day3.init),
	.init(id: 4, title: "Day 4: Camp Cleanup", source: Day4.init),
	.init(id: 5, title: "Day 5: Supply Stacks", source: Day5.init),
	.init(id: 6, title: "Day 6: Tuning Trouble", source: Day6.init),
	.init(id: 7, title: "Day 7: No Space Left On Device", source: Day7.init),
	.init(id: 8, title: "Day 8: Treetop Tree House", source: Day8.init),
	.init(id: 9, title: "Day 9: Rope Bridge", source: Day9.init),
	.init(id: 10, title: "Day 10: Cathode-Ray Tube", source: Day10.init),
	.init(id: 11, title: "Day 11: Monkey in the Middle", source: Day11.init),
	.init(id: 12, title: "Day 12: Hill Climbing Algorithm", source: Day12.init),
]

struct ContentView: View {
	let days: [DayModel] = allDays

	@State var destination: DayModel?

	var body: some View {
		NavigationStack {
			List {
				ForEach(days) { day in
					Button {
						destination = day
					} label: {
						HStack {
							Text(day.title)
							Spacer()
							Image(systemName: "chevron.forward")
						}
					}
				}
			}
			.listStyle(.plain)
			.navigationTitle("Advent of Code 2022")
			.navigationDestination(isPresented: $destination.isPresent()) {
				switch destination {
				case .none:
					EmptyView()
				case .some(let day):
					DayView(day: day)
				}
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
