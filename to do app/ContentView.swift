//
//  ContentView.swift
//  to do app
//
//  Created by Macbook Air on 18.10.2025.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TodoViewModel()
    
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
    }
}

#Preview {
    ContentView()
}
