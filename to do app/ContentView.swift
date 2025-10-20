//
//  ContentView.swift
//  to do app
//
//  Created by Macbook Air on 18.10.2025.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingSettings = false
    @State private var showingStatistics = false
    
    var body: some View {
        HStack(spacing: 0) {
            // SOL PANEL - PROJELER (70%)
            ProjectsPanel(viewModel: viewModel)
                .frame(maxWidth: .infinity)
            
            Divider()
            
            // SAĞ PANEL - RUTİNLER (30%)
            RoutinesPanel(viewModel: viewModel)
                .frame(width: 400)
        }
        .frame(minWidth: 1200, minHeight: 700)
        .background(Color.adaptiveWindowBackground)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    // İstatistik butonu
                    Button(action: {
                        showingStatistics = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .help("İstatistikler")
                    
                    // Ayarlar butonu
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .help("Ayarlar")
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
                .environmentObject(themeManager)
                .frame(width: 500, height: 600)
        }
        .sheet(isPresented: $showingStatistics) {
            StatisticsView(viewModel: viewModel, statsManager: viewModel.statisticsManager)
                .environmentObject(themeManager)
                .frame(minWidth: 900, minHeight: 700)
        }
    }
}

#Preview {
    ContentView()
}
