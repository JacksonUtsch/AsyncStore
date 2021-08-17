//
//  SwiftUI.swift
//  AsyncStore
//
//  Created by Jackson Utsch on 8/3/21.
//

import SwiftUI
import Combine

@available(iOS 15, macOS 12, *)
public class ViewStore<State: Equatable, Action, Environment>: ObservableObject {
	private let store: Store<State, Action, Environment>
	@Published public private(set) var state: State? = nil
//	private var cancellable: AnyCancellable?
	
	public init(
		_ store: Store<State, Action, Environment>
	) {
		self.store = store
//		Task { await observe() }
		store.setCallback(key: 0) { print("callback"); self.state = $0 }
//		store.stateCallbacks[0] = {
//			self.state = $0
//		}
	}
	
	deinit { store.removeCallback(key: 0) }
	
	public func send(_ action: Action) {
		store.send(action)
	}
	
//	func observe() async {
//		cancellable = await store.state
//			.receive(on: DispatchQueue.main)
//			.sink { [weak self] value in
//				self?.state = value
//			}
//	}
}

@available(iOS 15, macOS 12, *)
public struct WithViewStore<State: Equatable, Action, Environment, Content: View>: View {
	@ObservedObject private var viewStore: ViewStore<State, Action, Environment>
	private let content: (ViewStore<State, Action, Environment>) -> Content
	
	public init(
		_ store: Store<State, Action, Environment>,
		@ViewBuilder content: @escaping (ViewStore<State, Action, Environment>) -> Content
	) {
		self.viewStore = ViewStore(store)
		self.content = content
	}
	
	public var body: some View { content(viewStore) }
}

