import SwiftUI

enum Route: CaseIterable {
	case day1, day2, day3, day4, day5, day6, day7

	var title: String {
		switch self {
		case .day1: return "Day 1: Calorie Counting"
		case .day2: return "Day 2: Rock Paper Scissors"
		case .day3: return "Day 3: Rucksack Reorganization"
		case .day4: return "Day 4: Camp Cleanup"
		case .day5: return "Day 5: Supply Stacks"
		case .day6: return "Day 6: Tuning Trouble"
		case .day7: return "Day 7: No Space Left On Device"
		}
	}

	var source: any Day {
		switch self {
		case .day1: return Day1()
		case .day2: return Day2()
		case .day3: return Day3()
		case .day4: return Day4()
		case .day5: return Day5()
		case .day6: return Day6()
		case .day7: return Day7()
		}
	}

	@ViewBuilder var view: some View {
		DayView(title: title, source: source)
	}
}

struct ContentView: View {
	@State var destination: Route?

	var body: some View {
		NavigationStack {
			List {
				ForEach(Route.allCases, id: \.self) { day in
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
			.navigationTitle("Advent of Code 2022")
			.navigationDestination(isPresented: $destination.isPresent()) {
				switch destination {
				case .none:
					EmptyView()
				case .some(let day):
					day.view
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
