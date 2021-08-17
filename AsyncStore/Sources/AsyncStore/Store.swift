//
//  Store.swift
//  AsyncMacOS
//
//  Created by Jackson Utsch on 8/1/21.
//

import Foundation
import Combine

#if compiler(>=5.5)
@available(macOS 12, *)
public actor Store<State: Equatable, Action, Environment> {
	public private(set) var state: CurrentValueSubject<State, Never> { didSet { updateCallbacks() } }
	internal var stateCallbacks: [Int: (State) -> ()] = [:]
	private let environment: Environment
	private let reducer: (inout State, Action, Environment) -> [Task<Action, Never>]
	internal var flights: [Int: Task<Void, Error>] = [:]
//	{
//		didSet {
//			print("flights: \(flights.count)")
//		}
//	}
	
	internal enum CancellationError: Error { case cancelled }
	
	internal func updateCallbacks() {
		for callback in stateCallbacks {
			callback.value(state.value)
		}
	}
	
	internal nonisolated func setCallback(key: Int, value: @escaping (State) -> ()) {
		Task.detached {
			await self._setCallback(key: key, value: value)
		}
	}
	
	internal func _setCallback(key: Int, value: @escaping (State) -> ()) {
		stateCallbacks[key] = value
	}
	
	internal nonisolated func removeCallback(key: Int) {
		Task.detached {
			await self._removeCallback(key: key)
		}
	}
	
	internal func _removeCallback(key: Int) {
		stateCallbacks.removeValue(forKey: key)
	}
	
	public init(
		initialState: State,
		reducer: @escaping (inout State, Action, Environment) -> [Task<Action, Never>],
		environment: Environment
	) {
		self.state = .init(initialState)
		self.reducer = reducer
		self.environment = environment
	}
	
	private func _send(_ action: Action) async -> [Task<Action, Never>] {
		return reducer(&state.value, action, environment)
	}
	
	public nonisolated func send(_ action: Action) {
		Task.detached { [self] in
			for effect in await self._send(action) {
				await addTask(hash: effect.hashValue) {
					try Task.checkCancellation()
					let action = await effect.value
					try Task.checkCancellation()
					send(action)
					return action
				}
			}
		}
	}
	
	private func addTask(hash: Int, _ task: @escaping () async throws -> (Action)) {
		flights[hash] = Task.detached(priority: nil, operation: {
			_ = try await task()
			await self._removeFlight(hash)
		})
	}
	
	private func _removeFlight(_ hash: Int) {
		flights.removeValue(forKey: hash)
	}
	
	internal func _cancel(by hashValue: Int) {
		flights
			.filter({ $0.key == hashValue })
			.forEach {
				$0.value.cancel()
				flights.removeValue(forKey: $0.key)
		}
	}
	
	public nonisolated func cancel(by anyHashable: AnyHashable) {
		if let int = cancellationDictionary[anyHashable] {
			Task.detached {
				await self._cancel(by: int)
			}
		}
	}
}

internal var cancellationDictionary: [AnyHashable: Int] = [:]

@available(macOS 12, *)
extension Task {
	/*
	 REDUCER {
		Task {
			some logic here...
		}.cancellable(someHashValue)
	 }
	 
	 store.send(.someAction)
	 store.cancel(someHashValue)
	 */
	public func cancellable(by token: AnyHashable) -> Self {
		cancellationDictionary[token] = self.hashValue
		return self
	}
}
#endif

//@available(iOS 15, macOS 12, *)
//public actor AStore<State: Equatable, Action, Environment> {
//	private var cancelables: Set<AnyHashable> = []
//[(State) -> ()]
//	private var _state: State
//	public private(set) var state: State {
//		get { _state }
//		set { _state = newValue }
//	}
//	private let environment: Environment
//	private let reducer: (inout State, Action, Environment) async -> Action
//
//	public init(
//		initialState: State,
//		reducer: @escaping (inout State, Action, Environment) async -> Action,
//		environment: Environment
//	) {
//		self._state = initialState
//		self.reducer = reducer
//		self.environment = environment
//	}
//
//	func observe() {
//		cancelables.insert()
//	}
//
////	private func _send(_ action: Action) async -> Action {
////		// awaiting a reducer holds?
////		return await reducer(&state, action, environment)
////	}
////
////	nonisolated public func send(_ action: Action) {
////		Task.detached { [self] in
////			for effect in await self._send(action) {
////				Task.detached {
////					let action = await effect.value
////					send(action)
////				}
////			}
////		}
////	}
//}
