//
//  Redux.swift
//  AsyncMacOS
//
//  Created by Jackson Utsch on 8/3/21.
//

import AsyncStore

typealias ContentStore = Store<Content.State, Content.Action>

extension ContentStore {
	static let shared = ContentStore.init(
		initialState: Content.State.init(),
		reducer: Content.reducer,
		environment: ()
	)
}

//extension Task {
//	func ccc() -> Self {
//		self.cancel()
//
//		return self
//	}
//}

enum Content {
	static let reducer = Reducer<State, Action, Void> { state, action, environment in
		switch action {
		case .inc:
			state.count += 1
			return []
		case .delayedInc:
			return [
				Task {
					await withTaskCancellationHandler {
						do {
							_ = try await fiboncacci(nth: 10, progress: nil)
							return Action.inc
						} catch {
							return Action.dec
						}
					} onCancel: {
						print("onCancel")
					}
				}.cancellable(by: 101)
			]
		case .dec:
			state.count -= 1
			return []
		}
	}
	
	struct State: Equatable {
		var count: Int = 0
		var cancelTokens: [AnyHashable: Int] = [:]
	}
	
	enum Action {
		case inc
		case delayedInc
		case dec
	}
}
