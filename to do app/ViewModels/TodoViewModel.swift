//
//  TodoViewModel.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import Foundation
import SwiftUI
import Combine

class TodoViewModel: ObservableObject {
    @Published var projects: [Project] = [] {
        didSet {
            saveData()
        }
    }
    
    @Published var routines: [Routine] = [] {
        didSet {
            saveData()
        }
    }
    
    @Published var templates: [ProjectTemplate] = [] {
        didSet {
            saveTemplates()
        }
    }
    
    // DataManager instance
    private let dataManager = DataManager.shared
    
    // UserDefaults anahtarları (yedek sistem)
    private let projectsKey = "SavedProjects"
    private let routinesKey = "SavedRoutines"
    private let templatesKey = "SavedTemplates"
    
    init() {
        loadData()
        loadTemplates()
        checkRecurringTasks()
    }
    
    // MARK: - Project Methods
    func addProject(title: String, description: String, priority: Priority, deadline: Date?, duration: String, icon: String = "📋") {
        let newProject = Project(
            title: title,
            description: description,
            priority: priority,
            deadline: deadline,
            duration: duration,
            icon: icon
        )
        projects.append(newProject)
        SoundManager.shared.playTaskAddSound()
    }
    
    func updateProject(_ project: Project, title: String, description: String, priority: Priority, deadline: Date?, duration: String, icon: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].title = title
            projects[index].description = description
            projects[index].priority = priority
            projects[index].deadline = deadline
            projects[index].duration = duration
            projects[index].icon = icon
            SoundManager.shared.playTaskAddSound()
        }
    }
    
    func toggleProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].isCompleted.toggle()
            SoundManager.shared.playTaskCompleteSound()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        SoundManager.shared.playTaskDeleteSound()
    }
    
    func moveProject(from source: IndexSet, to destination: Int) {
        projects.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Subtask Methods (Alt Görevler)
    
    func addSubtask(to project: Project, title: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            let newSubtask = Subtask(title: title)
            projects[index].subtasks.append(newSubtask)
            SoundManager.shared.playTaskAddSound()
        }
    }
    
    func toggleSubtask(in project: Project, subtask: Subtask) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
           let subtaskIndex = projects[projectIndex].subtasks.firstIndex(where: { $0.id == subtask.id }) {
            projects[projectIndex].subtasks[subtaskIndex].isCompleted.toggle()
            SoundManager.shared.playTaskCompleteSound()
        }
    }
    
    func deleteSubtask(from project: Project, subtask: Subtask) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].subtasks.removeAll { $0.id == subtask.id }
            SoundManager.shared.playTaskDeleteSound()
        }
    }
    
    // MARK: - Notes Methods (Notlar)
    
    func updateNotes(for project: Project, notes: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].notes = notes
        }
    }
    
    // MARK: - Links Methods (Linkler)
    
    func addLink(to project: Project, link: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].links.append(link)
            SoundManager.shared.playTaskAddSound()
        }
    }
    
    func deleteLink(from project: Project, link: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].links.removeAll { $0 == link }
            SoundManager.shared.playTaskDeleteSound()
        }
    }
    
    // MARK: - Tags Methods (Etiketler)
    
    func addTag(to project: Project, tag: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            // # işaretini otomatik ekle
            let formattedTag = tag.hasPrefix("#") ? tag : "#\(tag)"
            if !projects[index].tags.contains(formattedTag) {
                projects[index].tags.append(formattedTag)
                SoundManager.shared.playTaskAddSound()
            }
        }
    }
    
    func deleteTag(from project: Project, tag: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].tags.removeAll { $0 == tag }
            SoundManager.shared.playTaskDeleteSound()
        }
    }
    
    // MARK: - Category Methods (Kategori)
    
    func updateCategory(for project: Project, category: String?) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].category = category
        }
    }
    
    // Tüm kategorileri getir (unique)
    var allCategories: [String] {
        let categories = projects.compactMap { $0.category }
        return Array(Set(categories)).sorted()
    }
    
    // MARK: - Template Methods (Şablonlar)
    
    func saveAsTemplate(from project: Project, name: String) {
        let template = ProjectTemplate(
            name: name,
            description: project.description,
            priority: project.priority,
            duration: project.duration,
            icon: project.icon,
            tags: project.tags,
            category: project.category,
            subtasks: project.subtasks.map { $0.title }
        )
        templates.append(template)
        SoundManager.shared.playTaskAddSound()
    }
    
    func createProjectFromTemplate(_ template: ProjectTemplate) {
        let newProject = template.createProject()
        projects.append(newProject)
        SoundManager.shared.playTaskAddSound()
    }
    
    func deleteTemplate(_ template: ProjectTemplate) {
        templates.removeAll { $0.id == template.id }
        SoundManager.shared.playTaskDeleteSound()
    }
    
    // Önceden tanımlı şablonları yükle
    func loadDefaultTemplates() {
        if templates.isEmpty {
            templates = [
                ProjectTemplate(
                    name: "Geliştirme Projesi",
                    description: "Yazılım geliştirme projesi şablonu",
                    priority: .high,
                    duration: "2 hafta",
                    icon: "💻",
                    tags: ["#iş", "#geliştirme"],
                    category: "İş",
                    subtasks: ["Tasarım", "Geliştirme", "Test", "Deploy"]
                ),
                ProjectTemplate(
                    name: "Blog Yazısı",
                    description: "İçerik oluşturma şablonu",
                    priority: .medium,
                    duration: "3 gün",
                    icon: "📝",
                    tags: ["#içerik", "#blog"],
                    category: "Kişisel",
                    subtasks: ["Araştırma", "Taslak", "Düzenleme", "Yayınla"]
                ),
                ProjectTemplate(
                    name: "Etkinlik Planı",
                    description: "Etkinlik organizasyonu şablonu",
                    priority: .medium,
                    duration: "1 hafta",
                    icon: "🎉",
                    tags: ["#etkinlik", "#organizasyon"],
                    category: "Organizasyon",
                    subtasks: ["Mekan ayarla", "Davetiye gönder", "Catering", "Sunum hazırla"]
                )
            ]
        }
    }
    
    // MARK: - Recurring Tasks (Tekrar Eden Görevler)
    
    func updateRecurrence(for project: Project, type: RecurrenceType, endDate: Date?) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].recurrenceType = type
            projects[index].recurrenceEndDate = endDate
        }
    }
    
    // Tekrar eden görevleri kontrol et ve yeni kopyalar oluştur
    private func checkRecurringTasks() {
        var newProjects: [Project] = []
        
        for project in projects {
            if project.shouldRecur() {
                let newProject = project.createRecurringCopy()
                newProjects.append(newProject)
            }
        }
        
        // Yeni projeleri ekle (didSet tetiklenmemesi için manuel)
        if !newProjects.isEmpty {
            projects.append(contentsOf: newProjects)
            // Manuel kaydet
            dataManager.saveProjects(projects)
        }
    }
    
    // MARK: - Dependencies (Bağımlılıklar)
    
    func addDependency(to project: Project, dependsOn: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            if !projects[index].dependsOn.contains(dependsOn.id) {
                projects[index].dependsOn.append(dependsOn.id)
            }
        }
    }
    
    func removeDependency(from project: Project, dependencyId: UUID) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].dependsOn.removeAll { $0 == dependencyId }
        }
    }
    
    // Bağımlılıklar tamamlanmış mı?
    func areDependenciesCompleted(for project: Project) -> Bool {
        for dependencyId in project.dependsOn {
            if let dependency = projects.first(where: { $0.id == dependencyId }) {
                if !dependency.isCompleted {
                    return false
                }
            }
        }
        return true
    }
    
    // Bağımlı projeleri getir
    func getDependencies(for project: Project) -> [Project] {
        return project.dependsOn.compactMap { id in
            projects.first(where: { $0.id == id })
        }
    }
    
    // MARK: - File Attachments (Dosya Eklentileri)
    
    func addAttachment(to project: Project, fileName: String, filePath: String, fileType: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            let attachment = FileAttachment(fileName: fileName, filePath: filePath, fileType: fileType)
            projects[index].attachments.append(attachment)
            SoundManager.shared.playTaskAddSound()
        }
    }
    
    func deleteAttachment(from project: Project, attachment: FileAttachment) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].attachments.removeAll { $0.id == attachment.id }
            SoundManager.shared.playTaskDeleteSound()
        }
    }
    
    // MARK: - Routine Methods
    func addRoutine(title: String) {
        let newRoutine = Routine(title: title)
        routines.append(newRoutine)
        SoundManager.shared.playTaskAddSound()
    }
    
    func toggleRoutine(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].isCompleted.toggle()
            
            // Tamamlandıysa bugünün tarihini kaydet
            if routines[index].isCompleted {
                routines[index].lastCompletedDate = Date()
            } else {
                routines[index].lastCompletedDate = nil
            }
            
            SoundManager.shared.playTaskCompleteSound()
            
            // Tüm rutinler tamamlandıysa özel ses! 🎉
            if routines.count > 0 && completedRoutinesCount == routines.count {
                SoundManager.shared.playSuccessSound()
            }
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        SoundManager.shared.playTaskDeleteSound()
    }
    
    func moveRoutine(from source: IndexSet, to destination: Int) {
        routines.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Tüm rutinleri sıfırla (Yeni Gün)
    func resetAllRoutines() {
        for index in routines.indices {
            routines[index].isCompleted = false
            routines[index].lastCompletedDate = nil
        }
        // didSet otomatik olarak saveData() çağırır
        SoundManager.shared.playSuccessSound()
    }
    
    var completedRoutinesCount: Int {
        routines.filter { $0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard !routines.isEmpty else { return 0 }
        return Double(completedRoutinesCount) / Double(routines.count)
    }
    
    // MARK: - Persistence (Kalıcı Depolama)
    
    /// Verileri kaydet (Dosya + UserDefaults)
    private func saveData() {
        // 1. Dosya sistemine kaydet
        dataManager.saveProjects(projects)
        dataManager.saveRoutines(routines)
        
        // 2. UserDefaults'a da kaydet (yedek)
        saveToUserDefaults()
    }
    
    /// UserDefaults'a kaydet
    private func saveToUserDefaults() {
        // Projects'i UserDefaults'a kaydet
        if let projectsData = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(projectsData, forKey: projectsKey)
        }
        
        // Routines'i UserDefaults'a kaydet
        if let routinesData = try? JSONEncoder().encode(routines) {
            UserDefaults.standard.set(routinesData, forKey: routinesKey)
        }
    }
    
    /// Verileri yükle (Dosya + UserDefaults)
    private func loadData() {
        // 1. Önce dosya sisteminden yükle
        let fileProjects = dataManager.loadProjects()
        let fileRoutines = dataManager.loadRoutines()
        
        // 2. Eğer dosya boşsa, UserDefaults'tan yükle
        if fileProjects.isEmpty {
            projects = loadFromUserDefaults(key: projectsKey, type: [Project].self) ?? []
        } else {
            projects = fileProjects
        }
        
        if fileRoutines.isEmpty {
            routines = loadFromUserDefaults(key: routinesKey, type: [Routine].self) ?? []
        } else {
            routines = fileRoutines
        }
    }
    
    /// UserDefaults'tan yükle
    private func loadFromUserDefaults<T: Codable>(key: String, type: T.Type) -> T? {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(type, from: data) {
            return decoded
        }
        return nil
    }
    
    /// Günlük rutinleri kontrol et ve gerekirse sıfırla (Artık kullanılmıyor)
    private func checkAndResetDailyRoutines() {
        // Bu fonksiyon artık kullanılmıyor
        // Manuel sıfırlama için resetAllRoutines() kullanılıyor
    }
    
    /// Şablonları kaydet
    private func saveTemplates() {
        // 1. Dosya sistemine kaydet
        dataManager.saveTemplates(templates)
        
        // 2. UserDefaults'a da kaydet
        if let templatesData = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(templatesData, forKey: templatesKey)
        }
    }
    
    /// Şablonları yükle
    private func loadTemplates() {
        // 1. Önce dosya sisteminden yükle
        let fileTemplates = dataManager.loadTemplates()
        
        // 2. Eğer dosya boşsa, UserDefaults'tan yükle
        if fileTemplates.isEmpty {
            templates = loadFromUserDefaults(key: templatesKey, type: [ProjectTemplate].self) ?? []
        } else {
            templates = fileTemplates
        }
    }
    
    // MARK: - Debug Helper (Geliştirme için)
    
    /// Örnek veri yükle (sadece geliştirme/test için)
    func loadSampleData() {
        projects = [
            Project(
                title: "Website Yenileme Projesi",
                description: "Tasarım, geliştirme ve içerik güncellemeleri",
                priority: .high,
                deadline: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                duration: "2 hafta",
                icon: "💻"
            ),
            Project(
                title: "Müşteri Sunumu Hazırla",
                description: "Yeni ürün stratejisi sunumu için slaytlar hazırla",
                priority: .medium,
                deadline: Calendar.current.date(byAdding: .day, value: 12, to: Date()),
                duration: "2 gün",
                icon: "📊"
            )
        ]
        
        routines = [
            Routine(title: "Sabah egzersizi (30 dk)"),
            Routine(title: "Email kontrol et"),
            Routine(title: "Günlük planlama yap"),
            Routine(title: "Kitap oku (30 dk)")
        ]
    }
    
    /// Tüm verileri temizle (Debug için)
    func clearAllData() {
        projects = []
        routines = []
    }
}
