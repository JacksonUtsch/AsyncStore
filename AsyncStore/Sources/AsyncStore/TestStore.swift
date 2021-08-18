//
//  TestStore.swift
//  AsyncStore
//
//  Created by Jackson Utsch on 8/18/21.
//

#if compiler(>=5.5)
import Foundation

/// Thread detach is not allowed in a test store.
@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public actor TestStore<State: Equatable, Action> {
	public private(set) var state: State { didSet { updateObservers() } }
	internal var observers: [AnyHashable: (State) -> ()] = [:]
	internal let reducer: (inout State, Action) -> [Task<Action, Never>]
	
	public init<Environment>(
		initialState: State,
		reducer: Reducer<State, Action, Environment>,
		environment: Environment
	) {
		self.state = initialState
		self.reducer = { state, action in reducer.run(&state, action, environment) }
	}
	
	internal func send(_ action: Action) async throws {
		for effect in reducer(&state, action) {
			try Task.checkCancellation()
			let action = await effect.value
			try Task.checkCancellation()
			try await send(action)
		}
	}
	
//	// MARK: Side-Effects
//
//	private func addTask(hash: Int, _ task: @escaping () async throws -> (Action)) {
//		flights[hash] = Task { [weak self] in
//			_ = try await task()
//			await self?.removeFlight(hash)
//		}
//	}
//
//	private func removeFlight(_ hash: Int) {
//		flights.removeValue(forKey: hash)
//	}
//
//	internal func cancel(by anyHashable: AnyHashable) {
//		guard let hashValue = cancellationDictionary[anyHashable] else { return }
//		flights
//			.filter({ $0.key == hashValue })
//			.forEach {
//				$0.value.cancel()
//				flights.removeValue(forKey: $0.key)
//		}
//	}
		
	// MARK: Observers
	
	private func updateObservers() {
		for observer in observers {
			observer.value(state)
		}
	}
	
	private func insertObserver(
		with anyHashable: AnyHashable,
		value: @escaping (State) -> ()
	) {
		observers[anyHashable] = value
	}
	
	private func removeObserver(with anyHashable: AnyHashable) {
		observers.removeValue(forKey: anyHashable)
	}
}
#endif
