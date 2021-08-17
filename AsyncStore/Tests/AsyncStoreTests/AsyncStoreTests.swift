import XCTest
@testable import AsyncStore

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
final class AsyncStoreTests: XCTestCase {
	func testSimple() async {
		let store = Store.init(
			initialState: 10,
			reducer: Reducer<Int, Void, Void> { s, a, e in
				s += 1
				return []
			},
			environment: ()
		)
		store.send(())
		// how to advance this scheduler??
		Thread.sleep(until: .now + 0.2)
		let state = await store.state
		XCTAssertEqual(11, state)
	}
}
