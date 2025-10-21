//
//  NotificationManager.swift
//  to do app
//
//  Created by Macbook Air on 21.10.2025.
//

import Foundation
import UserNotifications
import AppKit
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "NotificationsEnabled")
            if notificationsEnabled {
                scheduleAllNotifications()
            } else {
                cancelAllNotifications()
            }
        }
    }
    
    @Published var morningReportEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(morningReportEnabled, forKey: "MorningReportEnabled")
            if morningReportEnabled {
                scheduleMorningReport()
            } else {
                cancelNotification(identifier: "morning-report")
            }
        }
    }
    
    @Published var eveningReportEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(eveningReportEnabled, forKey: "EveningReportEnabled")
            if eveningReportEnabled {
                scheduleEveningReport()
            } else {
                cancelNotification(identifier: "evening-report")
            }
        }
    }
    
    @Published var deadlineRemindersEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(deadlineRemindersEnabled, forKey: "DeadlineRemindersEnabled")
        }
    }
    
    @Published var morningReportTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0))! {
        didSet {
            UserDefaults.standard.set(morningReportTime, forKey: "MorningReportTime")
            if morningReportEnabled {
                scheduleMorningReport()
            }
        }
    }
    
    @Published var eveningReportTime: Date = Calendar.current.date(from: DateComponents(hour: 20, minute: 0))! {
        didSet {
            UserDefaults.standard.set(eveningReportTime, forKey: "EveningReportTime")
            if eveningReportEnabled {
                scheduleEveningReport()
            }
        }
    }
    
    private let center = UNUserNotificationCenter.current()
    
    private override init() {
        super.init()
        center.delegate = self
        loadSettings()
        requestAuthorization()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ Bildirim izni verildi")
                DispatchQueue.main.async {
                    self.scheduleAllNotifications()
                }
            } else if let error = error {
                print("❌ Bildirim izni hatası: \(error.localizedDescription)")
            } else {
                print("⚠️ Bildirim izni reddedildi")
            }
        }
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        notificationsEnabled = UserDefaults.standard.object(forKey: "NotificationsEnabled") as? Bool ?? true
        morningReportEnabled = UserDefaults.standard.object(forKey: "MorningReportEnabled") as? Bool ?? true
        eveningReportEnabled = UserDefaults.standard.object(forKey: "EveningReportEnabled") as? Bool ?? true
        deadlineRemindersEnabled = UserDefaults.standard.object(forKey: "DeadlineRemindersEnabled") as? Bool ?? true
        
        if let morningTime = UserDefaults.standard.object(forKey: "MorningReportTime") as? Date {
            morningReportTime = morningTime
        }
        if let eveningTime = UserDefaults.standard.object(forKey: "EveningReportTime") as? Date {
            eveningReportTime = eveningTime
        }
    }
    
    // MARK: - Schedule All
    
    func scheduleAllNotifications() {
        guard notificationsEnabled else { return }
        
        if morningReportEnabled {
            scheduleMorningReport()
        }
        if eveningReportEnabled {
            scheduleEveningReport()
        }
    }
    
    // MARK: - Morning Report (Sabah Günlük Özet)
    
    func scheduleMorningReport() {
        guard notificationsEnabled && morningReportEnabled else { return }
        
        // Önce eski bildirimi iptal et
        cancelNotification(identifier: "morning-report")
        
        let content = UNMutableNotificationContent()
        content.title = "🌅 Günaydın!"
        content.body = "Bugünün görevlerine göz atın ve harika bir gün geçirin!"
        content.sound = .default
        content.categoryIdentifier = "MORNING_REPORT"
        
        // Sabah saatini al
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: morningReportTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "morning-report", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Sabah raporu bildirimi eklenemedi: \(error.localizedDescription)")
            } else {
                print("✅ Sabah raporu bildirimi zamanlandı: \(components.hour ?? 9):\(components.minute ?? 0)")
            }
        }
    }
    
    // MARK: - Evening Report (Akşam Tamamlanmayanlar Özeti)
    
    func scheduleEveningReport() {
        guard notificationsEnabled && eveningReportEnabled else { return }
        
        // Önce eski bildirimi iptal et
        cancelNotification(identifier: "evening-report")
        
        let content = UNMutableNotificationContent()
        content.title = "🌙 Gün Sonu Özeti"
        content.body = "Bugün tamamlanmayan görevlerinizi kontrol edin"
        content.sound = .default
        content.categoryIdentifier = "EVENING_REPORT"
        
        // Akşam saatini al
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: eveningReportTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = components.hour
        dateComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "evening-report", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Akşam raporu bildirimi eklenemedi: \(error.localizedDescription)")
            } else {
                print("✅ Akşam raporu bildirimi zamanlandı: \(components.hour ?? 20):\(components.minute ?? 0)")
            }
        }
    }
    
    // MARK: - Deadline Reminders (Son Tarih Uyarıları)
    
    func scheduleDeadlineReminder(for project: Project) {
        guard notificationsEnabled && deadlineRemindersEnabled else { return }
        guard let deadline = project.deadline else { return }
        guard !project.isCompleted else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Deadline geçmişse bildirim gönderme
        guard deadline > now else { return }
        
        // 1 gün önce uyarı
        if let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: deadline),
           oneDayBefore > now {
            scheduleDeadlineNotification(
                for: project,
                at: oneDayBefore,
                message: "Yarın son gün!",
                identifier: "deadline-1day-\(project.id.uuidString)"
            )
        }
        
        // 3 saat önce uyarı
        if let threeHoursBefore = calendar.date(byAdding: .hour, value: -3, to: deadline),
           threeHoursBefore > now {
            scheduleDeadlineNotification(
                for: project,
                at: threeHoursBefore,
                message: "3 saat kaldı!",
                identifier: "deadline-3hours-\(project.id.uuidString)"
            )
        }
        
        // 1 saat önce uyarı
        if let oneHourBefore = calendar.date(byAdding: .hour, value: -1, to: deadline),
           oneHourBefore > now {
            scheduleDeadlineNotification(
                for: project,
                at: oneHourBefore,
                message: "1 saat kaldı!",
                identifier: "deadline-1hour-\(project.id.uuidString)"
            )
        }
    }
    
    private func scheduleDeadlineNotification(for project: Project, at date: Date, message: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "⏰ \(project.title)"
        content.body = message
        content.sound = .default
        content.categoryIdentifier = "DEADLINE_REMINDER"
        content.userInfo = ["projectId": project.id.uuidString]
        
        // Priority badge
        switch project.priority {
        case .high:
            content.subtitle = "🔴 Yüksek Öncelik"
        case .medium:
            content.subtitle = "🟠 Orta Öncelik"
        case .low:
            content.subtitle = "🟢 Düşük Öncelik"
        }
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Deadline bildirimi eklenemedi: \(error.localizedDescription)")
            } else {
                print("✅ Deadline bildirimi zamanlandı: \(project.title) - \(message)")
            }
        }
    }
    
    func cancelDeadlineReminders(for projectId: UUID) {
        let identifiers = [
            "deadline-1day-\(projectId.uuidString)",
            "deadline-3hours-\(projectId.uuidString)",
            "deadline-1hour-\(projectId.uuidString)"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Deadline bildirimleri iptal edildi: \(projectId)")
    }
    
    // MARK: - Cancel Notifications
    
    func cancelNotification(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Bildirim iptal edildi: \(identifier)")
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        print("🗑️ Tüm bildirimler iptal edildi")
    }
    
    // MARK: - Pending Notifications
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    // Uygulama açıkken bildirimleri göster
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // Bildirime tıklandığında
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Proje ID'si varsa uygulamayı aç
        if let projectIdString = userInfo["projectId"] as? String,
           let projectId = UUID(uuidString: projectIdString) {
            print("📱 Bildirime tıklandı - Proje ID: \(projectId)")
            // Burada uygulamayı açıp ilgili projeye gidebiliriz
        }
        
        completionHandler()
    }
}
