//
//  RoutinesPanel.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import SwiftUI

struct RoutinesPanel: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var newRoutineTitle = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("⚡")
                        .font(.system(size: 32))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Günlük Rutinler")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Her gün tekrar eden alışkanlıklar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 12) {
                    // Add Input
                    HStack {
                        TextField("Yeni rutin ekle...", text: $newRoutineTitle)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: addRoutine) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        .disabled(newRoutineTitle.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    // Routines List veya Empty State
                    if viewModel.routines.isEmpty {
                        // Empty State
                        EmptyRoutinesView()
                            .padding(.horizontal)
                            .padding(.top, 20)
                    } else {
                        // Routines List
                        ForEach(viewModel.routines) { routine in
                            RoutineCard(routine: routine, viewModel: viewModel)
                        }
                        .padding(.horizontal)
                        
                        // Stats Card
                        StatsCard(viewModel: viewModel)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
        }
        .background(Color(NSColor.windowBackgroundColor).opacity(0.3))
    }
    
    private func addRoutine() {
        guard !newRoutineTitle.isEmpty else { return }
        viewModel.addRoutine(title: newRoutineTitle)
        newRoutineTitle = ""
    }
}

struct RoutineCard: View {
    let routine: Routine
    @ObservedObject var viewModel: TodoViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { viewModel.toggleRoutine(routine) }) {
                Image(systemName: routine.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(routine.isCompleted ? .blue : .gray)
            }
            .buttonStyle(.plain)
            
            // Title
            Text(routine.title)
                .font(.body)
                .strikethrough(routine.isCompleted)
                .foregroundColor(routine.isCompleted ? .secondary : .primary)
            
            Spacer()
            
            // Delete Button
            Button(action: { showingDeleteAlert = true }) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .confirmationDialog(
            "Bu rutini silmek istediğinizden emin misiniz?",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive) {
                viewModel.deleteRoutine(routine)
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("\(routine.title) kalıcı olarak silinecek.")
        }
    }
}

struct EmptyRoutinesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 50))
                .foregroundColor(.blue.opacity(0.4))
            
            VStack(spacing: 6) {
                Text("Henüz Rutin Yok")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Yukarıdaki alana yazarak günlük rutinlerinizi ekleyin")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct StatsCard: View {
    @ObservedObject var viewModel: TodoViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("📊 Bugünün İstatistiği")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Text("Tamamlanan:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.completedRoutinesCount) / \(viewModel.routines.count)")
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.completionPercentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}
