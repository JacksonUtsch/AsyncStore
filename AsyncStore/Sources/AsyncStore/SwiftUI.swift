//
//  SwiftUI.swift
//  AsyncStore
//
//  Created by Jackson Utsch on 8/3/21.
//

#if compiler(>=5.5)
import SwiftUI
import Combine

@available(iOS 15, macOS 12, watchOS 8, tvOS 15, *)
public class ViewStore<State: Equatable, Action>: ObservableObject {
	private let store: Store<State, Action>
	@Published public private(set) var state: State? = nil
	
	public init(
		_ store: Store<State, Action>
	) {
		self.store = store
		store.insertObserver(with: 0) { newState in
			DispatchQueue.main.async { [weak self] in
				self?.state = newState
			}
		}
	}
	
	deinit { store.removeObserver(with: 0) }
	
	public func send(_ action: Action) {
		store.send(action)
	}
}

@available(iOS 15, macOS 12, *)
public struct WithViewStore<State: Equatable, Action, Content: View>: View {
	@ObservedObject private var viewStore: ViewStore<State, Action>
	private let content: (ViewStore<State, Action>) -> Content
	
	public init(
		_ store: Store<State, Action>,
		@ViewBuilder content: @escaping (ViewStore<State, Action>) -> Content
	) {
		self.viewStore = ViewStore(store)
		self.content = content
	}
	
	public var body: some View { content(viewStore) }
}
#endif
