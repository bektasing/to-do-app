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
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Aydınlık"
        case .dark:
            return "Karanlık"
        case .system:
            return "Sistem"
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
        
        // Ana thread'de çalıştır
        DispatchQueue.main.async {
            switch self.currentTheme {
            case .light:
                NSApp.appearance = NSAppearance(named: .aqua)
                print("☀️ Manuel aydınlık tema uygulandı")
            case .dark:
                NSApp.appearance = NSAppearance(named: .darkAqua)
                print("🌙 Manuel karanlık tema uygulandı")
            case .system:
                NSApp.appearance = nil // Sistem temasını kullan
                print("💻 Sistem teması uygulandı")
            }
            
            // Tüm pencereleri güncelle
            for window in NSApp.windows {
                window.invalidateShadow()
            }
            
            // UI'ı zorla güncelle
            self.objectWillChange.send()
        }
    }
    
    var isLightMode: Bool {
        if currentTheme == .system {
            // Sistem teması kullanılıyorsa, gerçek sistem temasını kontrol et
            let appearance = NSApp.effectiveAppearance
            return !appearance.name.rawValue.contains("dark")
        }
        return currentTheme == .light
    }
    
    
}

// Color extensions for theme support
extension Color {
    // Dinamik renkler - Tema değiştiğinde otomatik güncellenir
    static var adaptiveCardBackground: Color {
        Color(NSColor.controlBackgroundColor)
    }
    
    static var adaptiveWindowBackground: Color {
        Color(NSColor.windowBackgroundColor)
    }
    
    static var adaptiveSecondaryText: Color {
        Color.secondary
    }
}

