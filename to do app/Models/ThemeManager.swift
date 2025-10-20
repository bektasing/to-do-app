//
//  ThemeManager.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//

import SwiftUI
import AppKit
import Combine

enum AppTheme: String, CaseIterable, Codable {
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .light:
            return "Aydınlık"
        case .dark:
            return "Karanlık"
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .light {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "AppTheme")
            applyTheme()
        }
    }
    
    private init() {
        loadTheme()
        applyTheme()
    }
    
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: "AppTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
        applyTheme()
    }
    
    private func applyTheme() {
        print("🎨 applyTheme çağrıldı, currentTheme: \(currentTheme.rawValue)")
        
        switch currentTheme {
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
            print("☀️ Manuel aydınlık tema uygulandı")
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
            print("🌙 Manuel karanlık tema uygulandı")
        }
        
        // UI'ı zorla güncelle
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    var isLightMode: Bool {
        return currentTheme == .light
    }
    
    
}

// Color extensions for theme support
extension Color {
    static func adaptiveBackground(_ light: Color, dark: Color) -> Color {
        if ThemeManager.shared.isLightMode {
            return light
        } else {
            return dark
        }
    }
    
    static func adaptiveText(_ light: Color, dark: Color) -> Color {
        if ThemeManager.shared.isLightMode {
            return light
        } else {
            return dark
        }
    }
    
    // Theme-aware colors
    static let adaptiveCardBackground = Color.adaptiveBackground(
        Color.white.opacity(0.8),
        dark: Color(NSColor.controlBackgroundColor)
    )
    
    static let adaptiveWindowBackground = Color.adaptiveBackground(
        Color(NSColor.windowBackgroundColor).opacity(0.3),
        dark: Color(NSColor.windowBackgroundColor).opacity(0.5)
    )
    
    static let adaptiveSecondaryText = Color.adaptiveText(
        Color.secondary,
        dark: Color.secondary
    )
}

