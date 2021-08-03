//
//  ContentView.swift
//  AsyncMacOS
//
//  Created by Jackson Utsch on 8/1/21.
//

import SwiftUI
import AsyncStore

struct ContentView: View {
	let store: ContentStore
	
	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				Text(viewStore.state?.count == nil ? "nil" : String(describing: viewStore.state!.count)).onTapGesture {
					viewStore.send(.inc)
				}
				Text("Delayed Inc").onTapGesture {
					viewStore.send(.delayedInc)
				}
				Text("Cancel").onTapGesture {
					Task {
						await store.cancel(by: 5)
					}
				}
			}
		}
	}
}

