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
                Text("Ayarlar")
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
                            Text("Tema")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        Picker("Tema", selection: $themeManager.currentTheme) {
                            Text("Sistem").tag(AppTheme.system)
                            Text("Aydınlık").tag(AppTheme.light)
                            Text("Karanlık").tag(AppTheme.dark)
                        }
                        .pickerStyle(.segmented)
                        
                        Text("Sistem seçeneği macOS tema ayarlarınızı takip eder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                    }
                    .padding()
                    .background(Color.adaptiveCardBackground)
                    .cornerRadius(8)
                    
                    // Sound Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ses Ayarları")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Image(systemName: "speaker.wave.2")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Ses Efektleri")
                            Spacer()
                            Toggle("", isOn: $viewModel.soundEnabled)
                                .toggleStyle(.switch)
                        }
                        
                        HStack {
                            Image(systemName: "hand.tap")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text("Dokunma Geri Bildirimi")
                            Spacer()
                            Text("Açık")
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
                            Text("Bildirimler")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        
                        // Ana bildirim toggle
                        HStack {
                            Image(systemName: "bell.badge")
                                .foregroundColor(.orange)
                                .frame(width: 20)
                            Text("Bildirimleri Etkinleştir")
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
                                Text("Sabah Günlük Özet")
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
                                Text("Akşam Tamamlanmayanlar")
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
                                Text("Son Tarih Uyarıları")
                                    .font(.subheadline)
                                Text("1 gün, 3 saat ve 1 saat önce")
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
                        Text("Veri")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            // Export data functionality
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text("Verileri Dışa Aktar")
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
                                Text("Verileri İçe Aktar")
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
                                Text("Tüm Verileri Temizle")
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
                        Text("Hakkında")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: {
                            showingAbout = true
                        }) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                Text("Uygulama Hakkında")
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                                .frame(width: 20)
                            Text("Versiyon")
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
