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
	public private(set) var state: CurrentValueSubject<State, Never>
	private let environment: Environment
	private let reducer: (inout State, Action, Environment) -> [Task<Action, Never>]
	private var flights: [Int: Task<Void, Never>] = [:] {
		didSet {
			print("flights: \(flights.count)")
		}
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
	
//	func ssend(_ action: Action) {
//		reducer(&state.value, action, environment).forEach({
//			flights.insert($0)
//		})
//	}
	
	nonisolated public func send(_ action: Action) {
//		withTaskCancellationHandler {
//
//		} operation: {
//
//		}
		
		var hash: Int!
		let task = Task.detached { [self, hash] in
			for effect in await self._send(action) {
				
//				await withTaskCancellationHandler {
					await addTask(hash: effect.hashValue) {
						let action = await effect.value
						send(action)
						return action
					}
//				} onCancel: {
//					print("onCancel")
//					_cancel(by: hash!)
//				}
			}
		}
		hash = task.hashValue
	}
	
	func addTask(hash: Int, _ task: @escaping () async -> (Action)) {
		flights[hash] = Task.detached(priority: nil, operation: {
			
			await withTaskCancellationHandler {
				
			} onCancel: {
				print("onCancel")
			}

//			do {
				await task()
//			} catch {
//
//			}
		})
	}
	
	nonisolated func _cancel(by hash: Int) {
		Task.detached {
			await self.cancel(by: hash)
		}
	}
	
	public func cancel(by hash: Int) {
		flights.forEach { $0.value.cancel() }
//		print("cancel. \(hash)")
////		print(flights.map { $0.hashValue })
//		flights.filter { $0.key == hash }.forEach { $0.value.cancel(); print("cancelling..") }
//		flights = flights.filter { $0.key != hash }
	}
}

@available(macOS 12, *)
extension Task {
	public func cancellable(by token: AnyHashable, in storage: inout [AnyHashable: Int]) -> Self {
		storage[token] = self.hashValue
		return self
	}
	
//	public func cancel(_ hash: AnyHashable) {
//		self.cancel()
//	}
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
