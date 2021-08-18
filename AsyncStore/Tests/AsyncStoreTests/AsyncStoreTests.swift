import XCTest
@testable import AsyncStore

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
final class AsyncStoreTests: XCTestCase {
	func testAsyncMutation() async {
		let store = Store.init(
			initialState: 10,
			reducer: Reducer<Int, Void, Void> { s, a, e in
				s += 1
				return []
			},
			environment: ()
		)
		await store._send(())
		await store._send(())
		let state = await store.state
		XCTAssertEqual(12, state)
	}
	
	func testEffect() async throws {
		enum Action { case inc, indirect }
		let store = TestStore.init(
			initialState: 10,
			reducer: Reducer<Int, Action, Void> { s, a, e in
				switch a {
				case .inc:
					s += 1
					return []
				case .indirect:
					return [Task<Action, Never> {
						Thread.sleep(forTimeInterval: 2.0)
						return Action.inc
					}]
				}
			},
			environment: ()
		)
		
		try await store.send(.inc)
		let state1 = await store.state
		XCTAssertEqual(state1, 11)
		
		try await store.send(.indirect)
		let state2 = await store.state
		XCTAssertEqual(state2, 12)
	}
}
