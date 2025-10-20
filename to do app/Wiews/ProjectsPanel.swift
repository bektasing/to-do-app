//
//  ProjectsPanel.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import SwiftUI
import UniformTypeIdentifiers

struct ProjectsPanel: View {
    @ObservedObject var viewModel: TodoViewModel
    @EnvironmentObject var themeManager: ThemeManager
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
            .background(Color.adaptiveCardBackground)
            
            Divider()
            
            // Action Buttons (Fixed)
            HStack(spacing: 12) {
                // Add Button
                Button(action: { showingAddSheet = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Yeni Proje")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.adaptiveWindowBackground)
            
            // Projects List veya Empty State (Scrollable)
            if viewModel.projects.isEmpty {
                // Empty State
                EmptyProjectsView()
                    .padding(.horizontal)
                    .padding(.top, 40)
                    .frame(maxHeight: .infinity)
            } else {
                // Projects List with Drag & Drop
                List {
                    ForEach(viewModel.projects) { project in
                        ProjectCard(projectId: project.id, viewModel: viewModel)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                    }
                    .onMove(perform: viewModel.moveProject)
                }
                .listStyle(.plain)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddProjectSheet(viewModel: viewModel, isPresented: $showingAddSheet)
        }
    }
}

struct ProjectCard: View {
    let projectId: UUID
    @ObservedObject var viewModel: TodoViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var isExpanded = false
    @State private var showingDetailSheet = false
    
    // Real-time project data
    private var project: Project {
        viewModel.projects.first(where: { $0.id == projectId }) ?? Project(
            title: "Bulunamadı",
            description: "",
            priority: .medium,
            deadline: nil,
            duration: ""
        )
    }
    
    var priorityColor: Color {
        switch project.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card Content
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
                
                    HStack(spacing: 12) {
                    if let deadline = project.deadline {
                        Label(project.deadlineString, systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Label(project.duration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                        // Subtask count badge
                        if !project.subtasks.isEmpty {
                            Label("\(project.completedSubtasksCount)/\(project.subtasks.count)", systemImage: "checklist")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        // Tag count badge
                        if !project.tags.isEmpty {
                            Label("\(project.tags.count)", systemImage: "tag")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }
                        
                        // Link count badge
                        if !project.links.isEmpty {
                            Label("\(project.links.count)", systemImage: "link")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Expand/Collapse Button
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                
                // Edit Button
                Button(action: { showingDetailSheet = true }) {
                    Image(systemName: "ellipsis.circle")
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
            
            // Expanded Details
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    // Category
                    if let category = project.category {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.purple)
                            Text(category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Tags
                    if !project.tags.isEmpty {
                        HStack(alignment: .top) {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.purple)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(project.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Subtasks
                    if !project.subtasks.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "checklist")
                                    .foregroundColor(.blue)
                                Text("Alt Görevler (\(project.completedSubtasksCount)/\(project.subtasks.count))")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            ForEach(project.subtasks) { subtask in
                                HStack(spacing: 8) {
                                    Button(action: {
                                        viewModel.toggleSubtask(in: project, subtask: subtask)
                                    }) {
                                        Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                            .foregroundColor(subtask.isCompleted ? .green : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Text(subtask.title)
                                        .font(.caption)
                                        .strikethrough(subtask.isCompleted)
                                        .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                                }
                            }
                        }
                    }
                    
                    // Links
                    if !project.links.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "link")
                                    .foregroundColor(.orange)
                                Text("Linkler")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            ForEach(project.links, id: \.self) { link in
                                Button(action: {
                                    if let url = URL(string: link) {
                                        NSWorkspace.shared.open(url)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.right.square")
                                            .font(.caption)
                                        Text(link)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Notes Preview
                    if !project.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.green)
                                Text("Notlar")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text(project.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.adaptiveCardBackground)
                .shadow(
                    color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear,
                    radius: themeManager.isLightMode ? 4 : 0,
                    x: 0,
                    y: themeManager.isLightMode ? 2 : 0
                )
        )
        .overlay(
            Rectangle()
                .fill(priorityColor)
                .frame(width: 4)
                .cornerRadius(2),
            alignment: .leading
        )
        .sheet(isPresented: $showingDetailSheet) {
            ProjectDetailSheet(project: project, viewModel: viewModel, isPresented: $showingDetailSheet)
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

// MARK: - Project Detail Sheet (Detaylı Düzenleme)
struct ProjectDetailSheet: View {
    let projectId: UUID
    @ObservedObject var viewModel: TodoViewModel
    @Binding var isPresented: Bool
    
    @State private var notes: String
    @State private var newLink = ""
    @State private var newTag = ""
    @State private var newSubtask = ""
    @State private var category: String
    @State private var selectedTab = 0
    @State private var recurrenceType: RecurrenceType
    @State private var recurrenceEndDate: Date
    @State private var hasRecurrenceEnd = false
    @State private var selectedDependency: Project?
    @State private var showingFilePicker = false
    @State private var showMarkdownHelp = false
    
    // ViewModelden real-time project alıyoruz
    private var project: Project {
        viewModel.projects.first(where: { $0.id == projectId }) ?? Project(
            title: "Bulunamadı",
            description: "",
            priority: .medium,
            deadline: nil,
            duration: ""
        )
    }
    
    init(project: Project, viewModel: TodoViewModel, isPresented: Binding<Bool>) {
        self.projectId = project.id
        self.viewModel = viewModel
        self._isPresented = isPresented
        _notes = State(initialValue: project.notes)
        _category = State(initialValue: project.category ?? "")
        _recurrenceType = State(initialValue: project.recurrenceType)
        _recurrenceEndDate = State(initialValue: project.recurrenceEndDate ?? Date())
        _hasRecurrenceEnd = State(initialValue: project.recurrenceEndDate != nil)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(project.icon)
                    .font(.system(size: 40))
                Text("Proje Detayları")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // Tab Selection (2 rows of tabs)
            VStack(spacing: 8) {
                Picker("", selection: $selectedTab) {
                    Text("Alt Görevler").tag(0)
                    Text("Notlar").tag(1)
                    Text("Linkler").tag(2)
                    Text("Etiketler").tag(3)
                }
                .pickerStyle(.segmented)
                
                Picker("", selection: $selectedTab) {
                    Text("Kategori").tag(4)
                    Text("Tekrar Eden").tag(5)
                    Text("Bağımlılıklar").tag(6)
                    Text("Dosyalar").tag(7)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                // Tab 0: Subtasks
                VStack(alignment: .leading, spacing: 12) {
                    Text("Alt Görevler")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(project.subtasks) { subtask in
                                HStack {
                                    Button(action: {
                                        viewModel.toggleSubtask(in: project, subtask: subtask)
                                    }) {
                                        Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                            .foregroundColor(subtask.isCompleted ? .green : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Text(subtask.title)
                                        .strikethrough(subtask.isCompleted)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.deleteSubtask(from: project, subtask: subtask)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        TextField("Yeni alt görev ekle...", text: $newSubtask)
                        Button("Ekle") {
                            if !newSubtask.isEmpty {
                                viewModel.addSubtask(to: project, title: newSubtask)
                                newSubtask = ""
                            }
                        }
                        .disabled(newSubtask.isEmpty)
                    }
                }
                .padding()
                .tag(0)
                
                // Tab 1: Notes (with Markdown Support)
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Notlar")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showMarkdownHelp.toggle()
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("Markdown yardımını göster")
                    }
                    
                    // Markdown Help
                    if showMarkdownHelp {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("📝 Markdown Desteği:")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("**kalın**, *italik*, `kod`, [link](url)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("# Başlık, - Liste, > Alıntı")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    
                    // Editor ve Preview yan yana
                    HStack(spacing: 12) {
                        // Editor
                        VStack(alignment: .leading) {
                            Text("Düzenle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextEditor(text: $notes)
                                .font(.body)
                                .frame(maxHeight: .infinity)
                                .border(Color.gray.opacity(0.3), width: 1)
                        }
                        
                        // Preview
                        VStack(alignment: .leading) {
                            Text("Önizleme")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ScrollView {
                                if #available(macOS 12.0, *) {
                                    Text(try! AttributedString(markdown: notes.isEmpty ? "*Markdown önizlemesi burada görünecek*" : notes))
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                } else {
                                    Text(notes.isEmpty ? "Markdown önizlemesi burada görünecek" : notes)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(8)
                                }
                            }
                            .frame(maxHeight: .infinity)
                            .background(Color.gray.opacity(0.05))
                            .border(Color.gray.opacity(0.3), width: 1)
                        }
                    }
                    
                    Button("Notları Kaydet") {
                        viewModel.updateNotes(for: project, notes: notes)
                    }
                }
                .padding()
                .tag(1)
                
                // Tab 2: Links
                VStack(alignment: .leading, spacing: 12) {
                    Text("Linkler")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(project.links, id: \.self) { link in
                                HStack {
                                    Button(action: {
                                        if let url = URL(string: link) {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.up.right.square")
                                            Text(link)
                                                .foregroundColor(.blue)
                                                .lineLimit(1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.deleteLink(from: project, link: link)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        TextField("https://example.com", text: $newLink)
                        Button("Ekle") {
                            if !newLink.isEmpty {
                                viewModel.addLink(to: project, link: newLink)
                                newLink = ""
                            }
                        }
                        .disabled(newLink.isEmpty)
                    }
                }
                .padding()
                .tag(2)
                
                // Tab 3: Tags
                VStack(alignment: .leading, spacing: 12) {
                    Text("Etiketler")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(project.tags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(12)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.deleteTag(from: project, tag: tag)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        TextField("#etiket", text: $newTag)
                        Button("Ekle") {
                            if !newTag.isEmpty {
                                viewModel.addTag(to: project, tag: newTag)
                                newTag = ""
                            }
                        }
                        .disabled(newTag.isEmpty)
                    }
                    
                    Text("Örnekler: #iş #kişisel #önemli #hızlı")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .tag(3)
                
                // Tab 4: Category
                VStack(alignment: .leading, spacing: 12) {
                    Text("Kategori")
                        .font(.headline)
                    
                    TextField("Kategori adı (örn: İş, Kişisel)", text: $category)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Kaydet") {
                        viewModel.updateCategory(for: project, category: category.isEmpty ? nil : category)
                    }
                    
                    Divider()
                    
                    if !viewModel.allCategories.isEmpty {
                        Text("Mevcut Kategoriler:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(viewModel.allCategories, id: \.self) { cat in
                                Button(action: {
                                    category = cat
                                    viewModel.updateCategory(for: project, category: cat)
                                }) {
                                    HStack {
                                        Image(systemName: "folder")
                                        Text(cat)
                                        Spacer()
                                        if project.category == cat {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.green)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .tag(4)
                
                // Tab 5: Recurring Tasks
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tekrar Eden Görev")
                        .font(.headline)
                    
                    Picker("Tekrar Türü", selection: $recurrenceType) {
                        ForEach(RecurrenceType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if recurrenceType != .none {
                        Toggle("Bitiş Tarihi Belirle", isOn: $hasRecurrenceEnd)
                        
                        if hasRecurrenceEnd {
                            DatePicker("Bitiş Tarihi", selection: $recurrenceEndDate, displayedComponents: .date)
                        }
                        
                        Button("Kaydet") {
                            viewModel.updateRecurrence(
                                for: project,
                                type: recurrenceType,
                                endDate: hasRecurrenceEnd ? recurrenceEndDate : nil
                            )
                        }
                        
                        Divider()
                        
                        Text("ℹ️ Bilgi")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Görev tamamlandığında, seçilen sıklıkta otomatik olarak yeni bir kopya oluşturulacak.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .tag(5)
                
                // Tab 6: Dependencies
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bağımlılıklar")
                        .font(.headline)
                    
                    if !project.dependsOn.isEmpty {
                        Text("Bu görev şunlara bağlı:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(viewModel.getDependencies(for: project)) { dependency in
                                    HStack {
                                        Text(dependency.icon)
                                        Text(dependency.title)
                                            .font(.subheadline)
                                        
                                        if dependency.isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.orange)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            viewModel.removeDependency(from: project, dependencyId: dependency.id)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    Text("Yeni Bağımlılık Ekle:")
                        .font(.subheadline)
                    
                    Picker("Bağlı Görev", selection: $selectedDependency) {
                        Text("Seç").tag(nil as Project?)
                        ForEach(viewModel.projects.filter { $0.id != project.id }) { otherProject in
                            HStack {
                                Text(otherProject.icon)
                                Text(otherProject.title)
                            }.tag(otherProject as Project?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Button("Ekle") {
                        if let selected = selectedDependency {
                            viewModel.addDependency(to: project, dependsOn: selected)
                            selectedDependency = nil
                        }
                    }
                    .disabled(selectedDependency == nil)
                    
                    Divider()
                    
                    HStack(spacing: 8) {
                        if viewModel.areDependenciesCompleted(for: project) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Tüm bağımlılıklar tamamlandı!")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("Bazı bağımlılıklar henüz tamamlanmadı")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .tag(6)
                
                // Tab 7: File Attachments
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dosya Eklentileri")
                        .font(.headline)
                    
                    if !project.attachments.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(project.attachments) { attachment in
                                    HStack {
                                        Image(systemName: attachment.fileType == "pdf" ? "doc.fill" : attachment.fileType == "image" ? "photo" : "doc")
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading) {
                                            Text(attachment.fileName)
                                                .font(.subheadline)
                                            Text(attachment.addedDate.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            let url = URL(fileURLWithPath: attachment.filePath)
                                            NSWorkspace.shared.open(url)
                                        }) {
                                            Image(systemName: "arrow.up.right.square")
                                                .foregroundColor(.blue)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        Button(action: {
                                            viewModel.deleteAttachment(from: project, attachment: attachment)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    Button("Dosya Ekle") {
                        showingFilePicker = true
                    }
                    
                    Text("💡 İpucu: Dosyalar Documents klasöründe saklanacak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .tag(7)
            }
            .tabViewStyle(.automatic)
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.pdf, .png, .jpeg, .plainText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        let fileName = url.lastPathComponent
                        let fileType = url.pathExtension.lowercased()
                        viewModel.addAttachment(to: project, fileName: fileName, filePath: url.path, fileType: fileType)
                    }
                case .failure(let error):
                    print("File picker error: \(error)")
                }
            }
            
            // Close Button
            HStack {
                Spacer()
                Button("Kapat") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
            }
            .padding(.horizontal)
        }
        .frame(width: 550, height: 500)
        .padding()
    }
}

// MARK: - Template Sheet (Kaldırıldı)
// Şablon sistemi kaldırıldı
