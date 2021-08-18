//
//  Task.swift
//  AsyncStore
//
//  Created by Jackson Utsch on 8/17/21.
//

#if compiler(>=5.5)
import Foundation

internal var cancellationDictionary: [AnyHashable: Int] = [:]

@available(macOS 12, *)
extension Task {
	/*
	 Reducer {
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
