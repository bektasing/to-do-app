//
//  to_do_appApp.swift
//  to do app
//
//  Created by Macbook Air on 18.10.2025.
//

import SwiftUI

@main
struct to_do_appApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
        }
    }
}
