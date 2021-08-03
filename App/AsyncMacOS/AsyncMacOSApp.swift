//
//  AsyncMacOSApp.swift
//  AsyncMacOS
//
//  Created by Jackson Utsch on 8/1/21.
//

import SwiftUI

@main
struct AsyncMacOSApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView(store: .shared)
		}
	}
}
