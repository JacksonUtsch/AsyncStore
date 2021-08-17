//
//  Store.swift
//  AsyncMacOS
//
//  Created by Jackson Utsch on 8/1/21.
//

#if compiler(>=5.5)
import Foundation

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public actor Store<State: Equatable, Action> {
	public private(set) var state: State { didSet { updateObservers() } }
	internal var observers: [AnyHashable: (State) -> ()] = [:]
	internal let reducer: (inout State, Action) -> [Task<Action, Never>]
	internal var flights: [Int: Task<Void, Error>] = [:]
	
	/// A type to represent a cancelled side-effect
	internal enum CancellationError: Error { case cancelled }
	
	public init<Environment>(
		initialState: State,
		reducer: Reducer<State, Action, Environment>,
		environment: Environment
	) {
		self.state = initialState
		self.reducer = { state, action in reducer.run(&state, action, environment) }
	}
	
	private func _send(_ action: Action) async -> [Task<Action, Never>] {
		return reducer(&state, action)
	}
	
	public nonisolated func send(_ action: Action) {
		Task.detached { [weak self] in
			guard let self = self else { return }
			for effect in await self._send(action) {
				await self._addTask(hash: effect.hashValue) { [weak self] in
					try Task.checkCancellation()
					let action = await effect.value
					try Task.checkCancellation()
					self?.send(action)
					return action
				}
			}
		}
	}
	
	// MARK: Side-Effects
	
	private func _addTask(hash: Int, _ task: @escaping () async throws -> (Action)) {
		flights[hash] = Task.detached(priority: nil, operation: { [weak self] in
			_ = try await task()
			await self?._removeFlight(hash)
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
		if let hashValue = cancellationDictionary[anyHashable] {
			Task.detached { [weak self] in
				await self?._cancel(by: hashValue)
			}
		}
	}
	
	// MARK: Observers
	
	private func updateObservers() {
		for observer in observers {
			observer.value(state)
		}
	}
	
	internal nonisolated func insertObserver(
		with anyHashable: AnyHashable,
		value: @escaping (State) -> ()
	) {
		Task.detached { [weak self] in
			await self?._insertObserver(with: anyHashable, value: value)
		}
	}
	
	private func _insertObserver(
		with anyHashable: AnyHashable,
		value: @escaping (State) -> ()
	) {
		observers[anyHashable] = value
	}
	
	internal nonisolated func removeObserver(with anyHashable: AnyHashable) {
		Task.detached { [weak self] in
			await self?._removeObserver(with: anyHashable)
		}
	}
	
	private func _removeObserver(with anyHashable: AnyHashable) {
		observers.removeValue(forKey: anyHashable)
	}
}
#endif
