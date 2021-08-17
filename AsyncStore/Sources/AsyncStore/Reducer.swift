//
//  Reducer.swift
//  AsyncStore
//
//  Created by Jackson Utsch on 8/17/21.
//

#if compiler(>=5.5)
import Foundation

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public struct Reducer<State, Action, Environment> {
	private let reducer: (inout State, Action, Environment) -> [Task<Action, Never>]
	
	public init(_ reducer: @escaping (inout State, Action, Environment) -> [Task<Action, Never>]) {
		self.reducer = reducer
	}
	
	public func run(
		_ state: inout State,
		_ action: Action,
		_ environment: Environment
	) -> [Task<Action, Never>] {
		self.reducer(&state, action, environment)
	}
}
#endif
