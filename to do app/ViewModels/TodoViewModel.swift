//
//  TodoViewModel.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import Foundation
import SwiftUI
import Combine

// Notification names
extension Notification.Name {
    static let showConfetti = Notification.Name("showConfetti")
}

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
    
    // Şablon sistemi kaldırıldı
    
    @Published var soundEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "SoundEnabled")
        }
    }
    
    // Yeni Gün butonu için son kullanım tarihi
    @Published var lastResetDate: Date? {
        didSet {
            if let date = lastResetDate {
                UserDefaults.standard.set(date, forKey: "LastResetDate")
            }
        }
    }
    
    // StatisticsManager instance
    let statisticsManager = StatisticsManager()
    
    // DataManager instance
    private let dataManager = DataManager.shared
    
    // UserDefaults anahtarları (yedek sistem)
    private let projectsKey = "SavedProjects"
    private let routinesKey = "SavedRoutines"
    // templatesKey kaldırıldı
    
    init() {
        loadData()
        checkRecurringTasks()
        loadSettings()
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
        playSoundIfEnabled { SoundManager.shared.playTaskAddSound() }
        SoundManager.shared.playHapticFeedback()
    }
    
    func updateProject(_ project: Project, title: String, description: String, priority: Priority, deadline: Date?, duration: String, icon: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].title = title
            projects[index].description = description
            projects[index].priority = priority
            projects[index].deadline = deadline
            projects[index].duration = duration
            projects[index].icon = icon
            playSoundIfEnabled { SoundManager.shared.playTaskAddSound() }
        }
    }
    
    func toggleProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].isCompleted.toggle()
            SoundManager.shared.playHapticFeedback()
            // Her checkbox tıklamasında ses çal
            playSoundIfEnabled { SoundManager.shared.playTaskCompleteSound() }
            
            // Streak güncelle (görev tamamlandıysa)
            if projects[index].isCompleted {
                statisticsManager.updateStreak(taskCompleted: true)
            }
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        playSoundIfEnabled { SoundManager.shared.playTaskDeleteSound() }
    }
    
    func moveProject(from source: IndexSet, to destination: Int) {
        projects.move(fromOffsets: source, toOffset: destination)
    }
    
    // MARK: - Subtask Methods (Alt Görevler)
    
    func addSubtask(to project: Project, title: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            let newSubtask = Subtask(title: title)
            projects[index].subtasks.append(newSubtask)
            playSoundIfEnabled { SoundManager.shared.playTaskAddSound() }
        }
    }
    
    func toggleSubtask(in project: Project, subtask: Subtask) {
        if let projectIndex = projects.firstIndex(where: { $0.id == project.id }),
           let subtaskIndex = projects[projectIndex].subtasks.firstIndex(where: { $0.id == subtask.id }) {
            projects[projectIndex].subtasks[subtaskIndex].isCompleted.toggle()
            SoundManager.shared.playHapticFeedback()
            // Her checkbox tıklamasında ses çal
            playSoundIfEnabled { SoundManager.shared.playTaskCompleteSound() }
        }
    }
    
    func deleteSubtask(from project: Project, subtask: Subtask) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].subtasks.removeAll { $0.id == subtask.id }
            playSoundIfEnabled { SoundManager.shared.playTaskDeleteSound() }
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
            playSoundIfEnabled { SoundManager.shared.playTaskAddSound() }
        }
    }
    
    func deleteLink(from project: Project, link: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].links.removeAll { $0 == link }
            playSoundIfEnabled { SoundManager.shared.playTaskDeleteSound() }
        }
    }
    
    // MARK: - Tags Methods (Etiketler)
    
    func addTag(to project: Project, tag: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            // # işaretini otomatik ekle
            let formattedTag = tag.hasPrefix("#") ? tag : "#\(tag)"
            if !projects[index].tags.contains(formattedTag) {
                projects[index].tags.append(formattedTag)
                playSoundIfEnabled { SoundManager.shared.playTaskAddSound() }
            }
        }
    }
    
    func deleteTag(from project: Project, tag: String) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].tags.removeAll { $0 == tag }
            playSoundIfEnabled { SoundManager.shared.playTaskDeleteSound() }
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
    
    // MARK: - Template Methods (Kaldırıldı)
    // Şablon sistemi kaldırıldı
    
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
            playSoundIfEnabled { SoundManager.shared.playTaskAddSound() }
        }
    }
    
    func deleteAttachment(from project: Project, attachment: FileAttachment) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].attachments.removeAll { $0.id == attachment.id }
            playSoundIfEnabled { SoundManager.shared.playTaskDeleteSound() }
        }
    }
    
    // MARK: - Routine Methods
    func addRoutine(title: String) {
        let newRoutine = Routine(title: title)
        routines.append(newRoutine)
        playSoundIfEnabled { SoundManager.shared.playTaskAddSound() }
    }
    
    func toggleRoutine(_ routine: Routine) {
        if let index = routines.firstIndex(where: { $0.id == routine.id }) {
            routines[index].isCompleted.toggle()
            SoundManager.shared.playHapticFeedback()
            
            // Her checkbox tıklamasında ses çal
            playSoundIfEnabled { SoundManager.shared.playTaskCompleteSound() }
            
            // Tamamlandıysa bugünün tarihini kaydet
            if routines[index].isCompleted {
                routines[index].lastCompletedDate = Date()
                
                // Streak güncelle
                statisticsManager.updateStreak(taskCompleted: true)
                
                // Tüm rutinler tamamlandıysa özel ses ve konfeti! 🎉
                if routines.count > 0 && completedRoutinesCount == routines.count {
                    playSoundIfEnabled { SoundManager.shared.playAllRoutinesCompleteSound() }
                    // Konfeti animasyonu için notification gönder
                    NotificationCenter.default.post(name: .showConfetti, object: nil)
                }
            } else {
                routines[index].lastCompletedDate = nil
            }
        }
    }
    
    func deleteRoutine(_ routine: Routine) {
        routines.removeAll { $0.id == routine.id }
        playSoundIfEnabled { SoundManager.shared.playTaskDeleteSound() }
    }
    
    func moveRoutine(from source: IndexSet, to destination: Int) {
        routines.move(fromOffsets: source, toOffset: destination)
    }
    
    /// Tüm rutinleri sıfırla (Yeni Gün) - Günde 1 kere kullanılabilir
    func resetAllRoutines() {
        for index in routines.indices {
            routines[index].isCompleted = false
            routines[index].lastCompletedDate = nil
        }
        // Son sıfırlama tarihini kaydet
        lastResetDate = Date()
        // didSet otomatik olarak saveData() çağırır
        playSoundIfEnabled { SoundManager.shared.playSuccessSound() }
    }
    
    /// Bugün zaten sıfırlandı mı?
    func canResetToday() -> Bool {
        guard let lastReset = lastResetDate else { return true }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastResetDay = calendar.startOfDay(for: lastReset)
        
        return today > lastResetDay
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
    
    // saveTemplates ve loadTemplates kaldırıldı - şablon sistemi artık yok
    
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
    
    // MARK: - Settings Methods
    
    /// Ayarları yükle
    private func loadSettings() {
        soundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
        lastResetDate = UserDefaults.standard.object(forKey: "LastResetDate") as? Date
    }
    
    /// Ses çal (ayar kontrolü ile)
    private func playSoundIfEnabled(_ soundAction: () -> Void) {
        if soundEnabled {
            soundAction()
        }
    }
}
