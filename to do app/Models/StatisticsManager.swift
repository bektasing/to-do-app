//
//  StatisticsManager.swift
//  to do app
//
//  Created by Macbook Air on 21.10.2025.
//

import Foundation
import SwiftUI
import Combine

// İstatistik veri modelleri
struct DailyStats: Identifiable {
    let id = UUID()
    let date: Date
    let completedTasks: Int
    let totalTasks: Int
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct WeeklyStats: Identifiable {
    let id = UUID()
    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let completedTasks: Int
    let totalTasks: Int
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
}

struct MonthlyStats: Identifiable {
    let id = UUID()
    let month: String
    let year: Int
    let completedTasks: Int
    let totalTasks: Int
    let completedRoutines: Int
    let totalRoutines: Int
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
}

struct HourlyProductivity: Identifiable {
    let id = UUID()
    let hour: Int
    let tasksCompleted: Int
    
    var hourLabel: String {
        return String(format: "%02d:00", hour)
    }
}

struct StreakData: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletionDate: Date?
    var totalDaysActive: Int = 0
}

// Başarı Rozeti
struct Achievement: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let icon: String
    let requirement: Int
    var isUnlocked: Bool
    var progress: Int
    
    var progressPercentage: Double {
        guard requirement > 0 else { return 0 }
        return min(Double(progress) / Double(requirement) * 100, 100)
    }
}

// Verimlilik Skoru
struct ProductivityScore {
    let score: Int // 0-100
    let level: String
    let color: String
    
    static func calculate(completedTasks: Int, totalTasks: Int, streak: Int) -> ProductivityScore {
        var score = 0
        
        // Tamamlama oranı (50 puan)
        if totalTasks > 0 {
            let completionRate = Double(completedTasks) / Double(totalTasks)
            score += Int(completionRate * 50)
        }
        
        // Streak bonusu (30 puan)
        score += min(streak * 3, 30)
        
        // Aktivite bonusu (20 puan)
        if completedTasks > 0 {
            score += min(completedTasks * 2, 20)
        }
        
        // Level belirleme
        let level: String
        let color: String
        switch score {
        case 90...100:
            level = "🏆 Efsane"
            color = "gold"
        case 75..<90:
            level = "⭐ Harika"
            color = "blue"
        case 60..<75:
            level = "✨ İyi"
            color = "green"
        case 40..<60:
            level = "📈 Gelişiyor"
            color = "orange"
        default:
            level = "🌱 Başlangıç"
            color = "gray"
        }
        
        return ProductivityScore(score: min(score, 100), level: level, color: color)
    }
}

class StatisticsManager: ObservableObject {
    @Published var streakData: StreakData = StreakData()
    
    private let streakKey = "StreakData"
    
    init() {
        loadStreak()
    }
    
    // MARK: - Haftalık Tamamlama Grafiği
    
    func getWeeklyStats(from projects: [Project]) -> [DailyStats] {
        let calendar = Calendar.current
        let today = Date()
        var stats: [DailyStats] = []
        
        // Son 7 gün için istatistik
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            // O gün tamamlanan görevler
            let completedOnDay = projects.filter { project in
                guard project.isCompleted else { return false }
                // Eğer deadline varsa ve o gün içindeyse
                if let deadline = project.deadline {
                    return deadline >= startOfDay && deadline < endOfDay
                }
                return false
            }.count
            
            // O gün için toplam görev (deadline'ı o gün olan)
            let totalOnDay = projects.filter { project in
                if let deadline = project.deadline {
                    return deadline >= startOfDay && deadline < endOfDay
                }
                return false
            }.count
            
            stats.append(DailyStats(
                date: date,
                completedTasks: completedOnDay,
                totalTasks: max(totalOnDay, 1) // En az 1 göster
            ))
        }
        
        return stats
    }
    
    // MARK: - Aylık Verimlilik Grafiği
    
    func getMonthlyStats(from projects: [Project], routines: [Routine]) -> [MonthlyStats] {
        var stats: [MonthlyStats] = []
        
        // Son 6 ay için istatistik
        for monthOffset in (0..<6).reversed() {
            guard let date = Calendar.current.date(byAdding: .month, value: -monthOffset, to: Date()) else { continue }
            
            let components = Calendar.current.dateComponents([.year, .month], from: date)
            guard let year = components.year else { continue }
            
            // Ay başı ve sonu
            let startOfMonth = Calendar.current.date(from: components)!
            let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
            
            // O ay tamamlanan projeler
            let completedProjects = projects.filter { project in
                guard project.isCompleted else { return false }
                if let deadline = project.deadline {
                    return deadline >= startOfMonth && deadline <= endOfMonth
                }
                return false
            }.count
            
            // O ay için toplam proje
            let totalProjects = projects.filter { project in
                if let deadline = project.deadline {
                    return deadline >= startOfMonth && deadline <= endOfMonth
                }
                return false
            }.count
            
            // Rutin istatistikleri (basitleştirilmiş)
            let completedRoutines = routines.filter { $0.isCompletedToday }.count
            let totalRoutines = routines.count
            
            // Ay ismini al
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "tr_TR")
            dateFormatter.dateFormat = "MMMM"
            let monthName = dateFormatter.string(from: date)
            
            stats.append(MonthlyStats(
                month: monthName,
                year: year,
                completedTasks: completedProjects,
                totalTasks: max(totalProjects, 1),
                completedRoutines: completedRoutines,
                totalRoutines: totalRoutines
            ))
        }
        
        return stats
    }
    
    // MARK: - En Üretken Gün Analizi
    
    func getMostProductiveDay(from projects: [Project]) -> (day: String, count: Int) {
        var dayCounts: [String: Int] = [:]
        
        // Tamamlanan projelerin günlerini say
        for project in projects where project.isCompleted {
            if let deadline = project.deadline {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "tr_TR")
                dateFormatter.dateFormat = "EEEE"
                let dayName = dateFormatter.string(from: deadline)
                dayCounts[dayName, default: 0] += 1
            }
        }
        
        // En yüksek sayıyı bul
        if let mostProductive = dayCounts.max(by: { $0.value < $1.value }) {
            return (mostProductive.key, mostProductive.value)
        }
        
        return ("Pazartesi", 0)
    }
    
    // MARK: - Saatlik Verimlilik Analizi
    
    func getHourlyProductivity(from projects: [Project]) -> [HourlyProductivity] {
        var hourCounts: [Int: Int] = [:]
        
        // Tamamlanan projelerin saatlerini say
        for project in projects where project.isCompleted {
            if let deadline = project.deadline {
                let hour = Calendar.current.component(.hour, from: deadline)
                hourCounts[hour, default: 0] += 1
            }
        }
        
        // 24 saat için veri oluştur
        return (0..<24).map { hour in
            HourlyProductivity(hour: hour, tasksCompleted: hourCounts[hour] ?? 0)
        }
    }
    
    func getMostProductiveHour(from projects: [Project]) -> (hour: Int, count: Int) {
        let hourlyData = getHourlyProductivity(from: projects)
        
        if let mostProductive = hourlyData.max(by: { $0.tasksCompleted < $1.tasksCompleted }) {
            return (mostProductive.hour, mostProductive.tasksCompleted)
        }
        
        return (9, 0) // Varsayılan: 09:00
    }
    
    // MARK: - Streak Takibi
    
    func updateStreak(taskCompleted: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if taskCompleted {
            // Bugün görev tamamlandı
            if let lastDate = streakData.lastCompletionDate {
                let lastDay = calendar.startOfDay(for: lastDate)
                
                if calendar.isDate(lastDay, inSameDayAs: today) {
                    // Bugün zaten tamamlanmış, streak'i koru
                    return
                } else if let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day,
                          daysBetween == 1 {
                    // Dün tamamlanmış, streak devam ediyor
                    streakData.currentStreak += 1
                    streakData.totalDaysActive += 1
                } else {
                    // Streak kırıldı, yeniden başla
                    streakData.currentStreak = 1
                    streakData.totalDaysActive += 1
                }
            } else {
                // İlk görev
                streakData.currentStreak = 1
                streakData.totalDaysActive = 1
            }
            
            streakData.lastCompletionDate = today
            
            // Longest streak'i güncelle
            if streakData.currentStreak > streakData.longestStreak {
                streakData.longestStreak = streakData.currentStreak
            }
            
            saveStreak()
        }
    }
    
    func checkStreakStatus() {
        guard let lastDate = streakData.lastCompletionDate else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        
        if let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day,
           daysBetween > 1 {
            // Streak kırıldı
            streakData.currentStreak = 0
            saveStreak()
        }
    }
    
    // MARK: - Hedef vs Gerçekleşen
    
    func getGoalComparison(from projects: [Project], routines: [Routine]) -> (completed: Int, total: Int, percentage: Double) {
        // Tamamlanan görevler
        let completedProjects = projects.filter { $0.isCompleted }.count
        let completedRoutines = routines.filter { $0.isCompletedToday }.count
        let totalCompleted = completedProjects + completedRoutines
        
        // Toplam görevler
        let totalTasks = projects.count + routines.count
        
        // Yüzde hesapla
        let percentage = totalTasks > 0 ? Double(totalCompleted) / Double(totalTasks) * 100 : 0
        
        return (totalCompleted, totalTasks, percentage)
    }
    
    // Öncelik dağılımı
    func getPriorityDistribution(from projects: [Project]) -> [String: Int] {
        var distribution: [String: Int] = [
            "Yüksek": 0,
            "Orta": 0,
            "Düşük": 0
        ]
        
        for project in projects {
            switch project.priority {
            case .high:
                distribution["Yüksek"]! += 1
            case .medium:
                distribution["Orta"]! += 1
            case .low:
                distribution["Düşük"]! += 1
            }
        }
        
        return distribution
    }
    
    // MARK: - Ortalama Tamamlanma Süresi
    
    func getAverageCompletionTime(from projects: [Project]) -> Double {
        let completedProjects = projects.filter { $0.isCompleted && $0.deadline != nil }
        guard !completedProjects.isEmpty else { return 0 }
        
        var totalDays = 0.0
        for project in completedProjects {
            if let deadline = project.deadline {
                // Deadline ile bugün arasındaki fark (basitleştirilmiş)
                let days = Calendar.current.dateComponents([.day], from: deadline, to: Date()).day ?? 0
                totalDays += abs(Double(days))
            }
        }
        
        return totalDays / Double(completedProjects.count)
    }
    
    // MARK: - Toplam Sayaçlar
    
    func getTotalCounts(from projects: [Project], routines: [Routine]) -> (total: Int, completed: Int, active: Int) {
        let totalProjects = projects.count
        let totalRoutines = routines.count
        let total = totalProjects + totalRoutines
        
        let completedProjects = projects.filter { $0.isCompleted }.count
        let completedRoutines = routines.filter { $0.isCompletedToday }.count
        let completed = completedProjects + completedRoutines
        
        let active = total - completed
        
        return (total, completed, active)
    }
    
    // MARK: - Verimlilik Skoru
    
    func getProductivityScore(from projects: [Project], routines: [Routine]) -> ProductivityScore {
        // SADECE PROJELER - Rutinler her gün sıfırlandığı için dahil edilmez
        let completedProjects = projects.filter { $0.isCompleted }.count
        let totalProjects = projects.count
        
        return ProductivityScore.calculate(
            completedTasks: completedProjects,
            totalTasks: totalProjects,
            streak: streakData.currentStreak
        )
    }
    
    // MARK: - Başarı Rozetleri
    
    func getAchievements(from projects: [Project], routines: [Routine]) -> [Achievement] {
        // SADECE PROJELER - Rutinler her gün sıfırlandığı için dahil edilmez
        let completedProjects = projects.filter { $0.isCompleted }.count
        let totalCompleted = completedProjects
        
        var achievements: [Achievement] = []
        
        // İlk Adım
        achievements.append(Achievement(
            title: "İlk Adım",
            description: "İlk görevini tamamla",
            icon: "🌱",
            requirement: 1,
            isUnlocked: totalCompleted >= 1,
            progress: min(totalCompleted, 1)
        ))
        
        // Başlangıç
        achievements.append(Achievement(
            title: "Başlangıç",
            description: "10 görev tamamla",
            icon: "⭐",
            requirement: 10,
            isUnlocked: totalCompleted >= 10,
            progress: min(totalCompleted, 10)
        ))
        
        // Üretken
        achievements.append(Achievement(
            title: "Üretken",
            description: "50 görev tamamla",
            icon: "🚀",
            requirement: 50,
            isUnlocked: totalCompleted >= 50,
            progress: min(totalCompleted, 50)
        ))
        
        // Uzman
        achievements.append(Achievement(
            title: "Uzman",
            description: "100 görev tamamla",
            icon: "💎",
            requirement: 100,
            isUnlocked: totalCompleted >= 100,
            progress: min(totalCompleted, 100)
        ))
        
        // Efsane
        achievements.append(Achievement(
            title: "Efsane",
            description: "500 görev tamamla",
            icon: "👑",
            requirement: 500,
            isUnlocked: totalCompleted >= 500,
            progress: min(totalCompleted, 500)
        ))
        
        // Streak Rozetleri
        achievements.append(Achievement(
            title: "Kararlı",
            description: "7 gün streak",
            icon: "🔥",
            requirement: 7,
            isUnlocked: streakData.longestStreak >= 7,
            progress: min(streakData.longestStreak, 7)
        ))
        
        achievements.append(Achievement(
            title: "Disiplinli",
            description: "30 gün streak",
            icon: "💪",
            requirement: 30,
            isUnlocked: streakData.longestStreak >= 30,
            progress: min(streakData.longestStreak, 30)
        ))
        
        achievements.append(Achievement(
            title: "Unstoppable",
            description: "100 gün streak",
            icon: "🏆",
            requirement: 100,
            isUnlocked: streakData.longestStreak >= 100,
            progress: min(streakData.longestStreak, 100)
        ))
        
        return achievements
    }
    
    // MARK: - Persistence
    
    private func saveStreak() {
        if let encoded = try? JSONEncoder().encode(streakData) {
            UserDefaults.standard.set(encoded, forKey: streakKey)
        }
    }
    
    private func loadStreak() {
        if let data = UserDefaults.standard.data(forKey: streakKey),
           let decoded = try? JSONDecoder().decode(StreakData.self, from: data) {
            streakData = decoded
        }
        
        // Streak durumunu kontrol et
        checkStreakStatus()
    }
}
