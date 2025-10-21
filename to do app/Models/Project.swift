//
//  Project.swift
//  to do app
//
//  Created by Macbook Air on 19.10.2025.
//
import Foundation

enum Priority: String, Codable, CaseIterable {
    case high = "Yüksek Öncelik"
    case medium = "Orta Öncelik"
    case low = "Düşük Öncelik"
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}

// Alt görev modeli
struct Subtask: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var isCompleted: Bool = false
}

// Tekrar türü (Recurring)
enum RecurrenceType: String, Codable, CaseIterable {
    case none = "Yok"
    case daily = "Günlük"
    case weekly = "Haftalık"
    case monthly = "Aylık"
    case yearly = "Yıllık"
}

// Şablon sistemi kaldırıldı

// Dosya eklentisi
struct FileAttachment: Identifiable, Codable, Hashable {
    var id = UUID()
    var fileName: String
    var filePath: String
    var fileType: String // "pdf", "image", "other"
    var addedDate: Date = Date()
}

struct Project: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var description: String
    var priority: Priority
    var deadline: Date?
    var duration: String
    var isCompleted: Bool = false
    var icon: String = "📋" // Varsayılan emoji
    
    // Hashable conformance (id ile karşılaştırma yeterli)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        lhs.id == rhs.id
    }
    
    // 🆕 YENİ: Görev Yönetimi Özellikleri
    var notes: String = "" // Detaylı notlar
    var links: [String] = [] // Web linkleri
    var subtasks: [Subtask] = [] // Alt görevler
    var tags: [String] = [] // Etiketler (#iş, #kişisel)
    var category: String? = nil // Kategori (opsiyonel)
    
    // 🆕 İLERİ SEVİYE: Tekrar Eden Görevler & Dosya Eklentileri
    var recurrenceType: RecurrenceType = .none // Tekrar türü
    var lastRecurredDate: Date? = nil // Son tekrar tarihi
    var recurrenceEndDate: Date? = nil // Tekrar bitiş tarihi
    var attachments: [FileAttachment] = [] // Dosya eklentileri
    
    var deadlineString: String {
        guard let deadline = deadline else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: deadline)
    }
    
    // Alt görev ilerleme yüzdesi
    var subtaskProgress: Double {
        guard !subtasks.isEmpty else { return 0 }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }
    
    // Tamamlanan alt görev sayısı
    var completedSubtasksCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }
    
    // Tekrar eden görevin yeni kopyasını oluştur
    func createRecurringCopy() -> Project {
        var newProject = self
        newProject.id = UUID()
        newProject.isCompleted = false
        newProject.lastRecurredDate = Date()
        newProject.subtasks = subtasks.map { subtask in
            var newSubtask = subtask
            newSubtask.id = UUID()
            newSubtask.isCompleted = false
            return newSubtask
        }
        
        // Deadline'ı tekrar türüne göre ayarla
        if let deadline = deadline {
            switch recurrenceType {
            case .daily:
                newProject.deadline = Calendar.current.date(byAdding: .day, value: 1, to: deadline)
            case .weekly:
                newProject.deadline = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: deadline)
            case .monthly:
                newProject.deadline = Calendar.current.date(byAdding: .month, value: 1, to: deadline)
            case .yearly:
                newProject.deadline = Calendar.current.date(byAdding: .year, value: 1, to: deadline)
            case .none:
                break
            }
        }
        
        return newProject
    }
    
    // Tekrar etmesi gerekiyor mu?
    func shouldRecur() -> Bool {
        guard recurrenceType != .none else { return false }
        guard isCompleted else { return false }
        
        // Bitiş tarihi kontrolü
        if let endDate = recurrenceEndDate, Date() > endDate {
            return false
        }
        
        // Son tekrar tarihinden beri yeterli zaman geçti mi?
        guard let lastDate = lastRecurredDate else { return true }
        
        let calendar = Calendar.current
        let now = Date()
        
        switch recurrenceType {
        case .daily:
            return !calendar.isDate(lastDate, inSameDayAs: now)
        case .weekly:
            let weeksPassed = calendar.dateComponents([.weekOfYear], from: lastDate, to: now).weekOfYear ?? 0
            return weeksPassed >= 1
        case .monthly:
            let monthsPassed = calendar.dateComponents([.month], from: lastDate, to: now).month ?? 0
            return monthsPassed >= 1
        case .yearly:
            let yearsPassed = calendar.dateComponents([.year], from: lastDate, to: now).year ?? 0
            return yearsPassed >= 1
        case .none:
            return false
        }
    }
}
