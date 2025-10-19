//
//  ProjectsPanel.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import SwiftUI

struct ProjectsPanel: View {
    @ObservedObject var viewModel: TodoViewModel
    @State private var newProjectTitle = ""
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("🎯")
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Projeler & Büyük Görevler")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Uzun vadeli hedefleriniz ve büyük projeleriniz")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(spacing: 16) {
                    // Add Button
                    Button(action: { showingAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Yeni Proje Ekle")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    
                    // Projects List veya Empty State
                    if viewModel.projects.isEmpty {
                        // Empty State
                        EmptyProjectsView()
                            .padding(.horizontal)
                            .padding(.top, 40)
                    } else {
                        // Projects List
                        ForEach(viewModel.projects) { project in
                            ProjectCard(project: project, viewModel: viewModel)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddProjectSheet(viewModel: viewModel, isPresented: $showingAddSheet)
        }
    }
}

struct ProjectCard: View {
    let project: Project
    @ObservedObject var viewModel: TodoViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var priorityColor: Color {
        switch project.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { viewModel.toggleProject(project) }) {
                Image(systemName: project.isCompleted ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(project.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)
            
            // Icon/Emoji
            Text(project.icon)
                .font(.system(size: 32))
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(project.title)
                        .font(.headline)
                        .strikethrough(project.isCompleted)
                    
                    Spacer()
                    
                    Text(project.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor.opacity(0.2))
                        .foregroundColor(priorityColor)
                        .cornerRadius(12)
                }
                
                Text(project.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    if let deadline = project.deadline {
                        Label(project.deadlineString, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Label(project.duration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Edit Button
            Button(action: { showingEditSheet = true }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            // Delete Button
            Button(action: { showingDeleteAlert = true }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .cornerRadius(2),
            alignment: .leading
        )
        .sheet(isPresented: $showingEditSheet) {
            EditProjectSheet(project: project, viewModel: viewModel, isPresented: $showingEditSheet)
        }
        .confirmationDialog(
            "Bu projeyi silmek istediğinizden emin misiniz?",
            isPresented: $showingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive) {
                viewModel.deleteProject(project)
            }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("\(project.title) kalıcı olarak silinecek.")
        }
    }
}

struct EmptyProjectsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("Henüz Proje Yok")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text("Yukarıdaki butona tıklayarak ilk projenizi ekleyin")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    
    let emojis = ["📋", "💻", "📊", "📱", "🎯", "💼", "📝", "🎨", "🚀", "⚡", "🔥", "✨", 
                  "📚", "🎓", "💡", "🏆", "🎮", "🎵", "🏋️", "🏃", "🧘", "🍎", "☕️", "🌟"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("İkon Seç")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                ForEach(emojis, id: \.self) { emoji in
                    Button(action: { selectedEmoji = emoji }) {
                        Text(emoji)
                            .font(.system(size: 28))
                            .frame(width: 40, height: 40)
                            .background(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct AddProjectSheet: View {
    @ObservedObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var deadline = Date()
    @State private var duration = ""
    @State private var hasDeadline = false
    @State private var selectedIcon = "📋"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Yeni Proje Ekle")
                .font(.title)
                .fontWeight(.bold)
            
            Form {
                TextField("Proje Başlığı", text: $title)
                TextField("Açıklama", text: $description)
                
                EmojiPicker(selectedEmoji: $selectedIcon)
                    .padding(.vertical, 8)
                
                Picker("Öncelik", selection: $priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                
                Toggle("Son Tarih Ekle", isOn: $hasDeadline)
                
                if hasDeadline {
                    DatePicker("Son Tarih", selection: $deadline, displayedComponents: .date)
                }
                
                TextField("Süre (örn: 2 hafta)", text: $duration)
            }
            .padding()
            
            HStack {
                Button("İptal") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Ekle") {
                    viewModel.addProject(
                        title: title,
                        description: description,
                        priority: priority,
                        deadline: hasDeadline ? deadline : nil,
                        duration: duration,
                        icon: selectedIcon
                    )
                    isPresented = false
                }
                .keyboardShortcut(.return)
                .disabled(title.isEmpty)
            }
            .padding()
        }
        .frame(width: 450, height: 600)
        .padding()
    }
}

struct EditProjectSheet: View {
    let project: Project
    @ObservedObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool
    
    @State private var title: String
    @State private var description: String
    @State private var priority: Priority
    @State private var deadline: Date
    @State private var duration: String
    @State private var hasDeadline: Bool
    @State private var selectedIcon: String
    
    init(project: Project, viewModel: TodoViewModel, isPresented: Binding<Bool>) {
        self.project = project
        self.viewModel = viewModel
        self._isPresented = isPresented
        
        // Initialize state variables
        _title = State(initialValue: project.title)
        _description = State(initialValue: project.description)
        _priority = State(initialValue: project.priority)
        _deadline = State(initialValue: project.deadline ?? Date())
        _duration = State(initialValue: project.duration)
        _hasDeadline = State(initialValue: project.deadline != nil)
        _selectedIcon = State(initialValue: project.icon)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Projeyi Düzenle")
                .font(.title)
                .fontWeight(.bold)
            
            Form {
                TextField("Proje Başlığı", text: $title)
                TextField("Açıklama", text: $description)
                
                EmojiPicker(selectedEmoji: $selectedIcon)
                    .padding(.vertical, 8)
                
                Picker("Öncelik", selection: $priority) {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                
                Toggle("Son Tarih Ekle", isOn: $hasDeadline)
                
                if hasDeadline {
                    DatePicker("Son Tarih", selection: $deadline, displayedComponents: .date)
                }
                
                TextField("Süre (örn: 2 hafta)", text: $duration)
            }
            .padding()
            
            HStack {
                Button("İptal") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Kaydet") {
                    viewModel.updateProject(
                        project,
                        title: title,
                        description: description,
                        priority: priority,
                        deadline: hasDeadline ? deadline : nil,
                        duration: duration,
                        icon: selectedIcon
                    )
                    isPresented = false
                }
                .keyboardShortcut(.return)
                .disabled(title.isEmpty)
            }
            .padding()
        }
        .frame(width: 450, height: 600)
        .padding()
    }
}
