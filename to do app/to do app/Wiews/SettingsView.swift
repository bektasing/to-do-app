//
//  SettingsView.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    @ObservedObject var viewModel: TodoViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingAbout = false
    
    init(viewModel: TodoViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Text(localizationManager.localized("settings_title"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.adaptiveCardBackground)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Appearance Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.purple)
                            Text(localizationManager.localized("theme"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Picker(localizationManager.localized("theme"), selection: $themeManager.currentTheme) {
                            Text(localizationManager.localized("system_theme")).tag(AppTheme.system)
                            Text(localizationManager.localized("light_theme")).tag(AppTheme.light)
                            Text(localizationManager.localized("dark_theme")).tag(AppTheme.dark)
                        }
                        .pickerStyle(.segmented)
                        
                        Text(localizationManager.localized("theme_follows_system"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                    }
                    .padding()
                    .background(Color.adaptiveCardBackground)
                    .cornerRadius(8)
                    
                    // Language Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                            Text(localizationManager.localized("language"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Picker(localizationManager.localized("language"), selection: $localizationManager.currentLanguage) {
                            ForEach(AppLanguage.allCases, id: \.self) { language in
                                Text(language.displayName)
                                    .tag(language)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(localizationManager.localized("language_change_instant"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.adaptiveCardBackground)
                    .cornerRadius(8)
                    
                    // Sound Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.green)
                            Text(localizationManager.localized("sound"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text(localizationManager.localized("sound_effects"))
                            Spacer()
                            Toggle("", isOn: $viewModel.soundEnabled)
                                .toggleStyle(.switch)
                        }
                        
                        HStack {
                            Image(systemName: "hand.tap")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text(localizationManager.localized("haptic_feedback"))
                            Spacer()
                            Text(localizationManager.localized("on"))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.adaptiveCardBackground)
                    .cornerRadius(8)
                    
                    // Notifications Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.orange)
                            Text(localizationManager.localized("notifications"))
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        // Ana bildirim toggle
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            Text(localizationManager.localized("enable_notifications"))
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.notificationManager.notificationsEnabled },
                                set: { viewModel.notificationManager.notificationsEnabled = $0 }
                            ))
                                .toggleStyle(.switch)
                        }
                        
                        Divider()
                        
                        // Sabah raporu
                        HStack {
                            Image(systemName: "sunrise.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localizationManager.localized("morning_summary"))
                                    .font(.subheadline)
                                DatePicker("", selection: Binding(
                                    get: { viewModel.notificationManager.morningReportTime },
                                    set: { viewModel.notificationManager.morningReportTime = $0 }
                                ), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .disabled(!viewModel.notificationManager.morningReportEnabled)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.notificationManager.morningReportEnabled },
                                set: { viewModel.notificationManager.morningReportEnabled = $0 }
                            ))
                                .toggleStyle(.switch)
                                .disabled(!viewModel.notificationManager.notificationsEnabled)
                        }
                        
                        // Akşam raporu
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.indigo)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localizationManager.localized("evening_incomplete"))
                                    .font(.subheadline)
                                DatePicker("", selection: Binding(
                                    get: { viewModel.notificationManager.eveningReportTime },
                                    set: { viewModel.notificationManager.eveningReportTime = $0 }
                                ), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .disabled(!viewModel.notificationManager.eveningReportEnabled)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.notificationManager.eveningReportEnabled },
                                set: { viewModel.notificationManager.eveningReportEnabled = $0 }
                            ))
                                .toggleStyle(.switch)
                                .disabled(!viewModel.notificationManager.notificationsEnabled)
                        }
                        
                        Divider()
                        
                        // Deadline uyarıları
                        HStack {
                            Image(systemName: "alarm")
                                .foregroundColor(.red)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(localizationManager.localized("deadline_reminders"))
                                    .font(.subheadline)
                                Text(localizationManager.currentLanguage == .turkish 
                                     ? "1 gün, 3 saat ve 1 saat önce"
                                     : "1 day, 3 hours and 1 hour before")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { viewModel.notificationManager.deadlineRemindersEnabled },
                                set: { viewModel.notificationManager.deadlineRemindersEnabled = $0 }
                            ))
                                .toggleStyle(.switch)
                                .disabled(!viewModel.notificationManager.notificationsEnabled)
                        }
                    }
                    .padding()
                    .background(Color.adaptiveCardBackground)
                    .cornerRadius(8)
                    
                    // Data Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(localizationManager.localized("data"))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            // Export data functionality
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text(localizationManager.localized("export_data"))
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            // Import data functionality
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                    .foregroundColor(.green)
                                    .frame(width: 20)
                                Text(localizationManager.localized("import_data"))
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: {
                            // Clear data functionality
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .frame(width: 20)
                                Text(localizationManager.localized("clear_all_data"))
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding()
                    .background(Color.adaptiveCardBackground)
                    .cornerRadius(8)
                    
                    // About Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(localizationManager.localized("about"))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            showingAbout = true
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text(localizationManager.localized("about_app"))
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                                .frame(width: 20)
                            Text(localizationManager.localized("version"))
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.adaptiveCardBackground)
                    .cornerRadius(8)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Text("Hakkında")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.adaptiveCardBackground)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                // App Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 8) {
                    Text("To-Do App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Versiyon 1.0.0")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    Text("Gelişmiş görev yönetimi ve rutin takibi için tasarlanmış modern bir uygulama.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Text("Özellikler:")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        FeatureRow(icon: "list.bullet", text: "Proje ve görev yönetimi")
                        FeatureRow(icon: "repeat", text: "Günlük rutin takibi")
                        FeatureRow(icon: "sparkles", text: "Konfeti animasyonları")
                        FeatureRow(icon: "speaker.wave.2", text: "Ses efektleri")
                        FeatureRow(icon: "paintbrush", text: "Aydınlık/karanlık tema")
                    }
                }
                
                Spacer()
                
                    Text("© 2025 To-Do App. Tüm hakları saklıdır.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}

#Preview {
    SettingsView(viewModel: TodoViewModel())
        .environmentObject(ThemeManager.shared)
}
