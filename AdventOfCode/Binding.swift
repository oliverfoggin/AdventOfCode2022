import SwiftUI

public extension Binding {
	func isPresent<Wrapped>() -> Binding<Bool>
	where Value == Wrapped? {
		.init(
			get: { self.wrappedValue != nil },
			set: { isPresented in
				if !isPresented {
					self.wrappedValue = nil
				}
			}
		)
	}
}
