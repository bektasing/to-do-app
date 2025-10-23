//
//  LocalizationManager.swift
//  to do app
//
//  Dil yönetimi ve çeviri sistemi
//

import Foundation
import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable {
    case turkish = "tr"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .turkish: return "Türkçe"
        case .english: return "English"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage = .turkish {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "AppLanguage")
        }
    }
    
    private init() {
        loadLanguage()
    }
    
    private func loadLanguage() {
        if let savedLanguage = UserDefaults.standard.string(forKey: "AppLanguage"),
           let language = AppLanguage(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
    
    func localized(_ key: String) -> String {
        return translations[currentLanguage]?[key] ?? key
    }
    
    // Çeviri sözlüğü
    private let translations: [AppLanguage: [String: String]] = [
        .turkish: [
            // Ana Başlıklar
            "projects_title": "Projeler & Büyük Görevler",
            "projects_subtitle": "Uzun vadeli hedefleriniz ve büyük projeleriniz",
            "routines_title": "Günlük Rutinler",
            "routines_subtitle": "Her gün tekrar eden alışkanlıklar",
            
            // Butonlar
            "new_project": "Yeni Proje",
            "new_day": "Yeni Gün",
            "confirm": "Onayla",
            "completed_exclamation": "Tamamlandı!",
            "used_today": "Bugün Kullanıldı",
            "add": "Ekle",
            "cancel": "İptal",
            "save": "Kaydet",
            "delete": "Sil",
            "edit": "Düzenle",
            "close": "Kapat",
            
            // Form Alanları
            "project_title": "Proje Başlığı",
            "description": "Açıklama",
            "priority": "Öncelik",
            "add_deadline": "Son Tarih Ekle",
            "deadline": "Son Tarih",
            "duration": "Süre (örn: 2 hafta)",
            
            // Öncelikler
            "priority_high": "Yüksek",
            "priority_medium": "Orta",
            "priority_low": "Düşük",
            
            // Empty State
            "no_projects": "Henüz Proje Yok",
            "no_projects_desc": "Yukarıdaki butona tıklayarak ilk projenizi ekleyin",
            "no_routines": "Henüz Rutin Yok",
            "no_routines_desc": "Yukarıdaki alana yazarak günlük rutinlerinizi ekleyin",
            
            // İstatistikler
            "stats_title": "Bugünün İstatistiği",
            "completed_count": "Tamamlanan:",
            "completed_word": "tamamlandı",
            
            // Onay Mesajları
            "delete_project_title": "Bu projeyi silmek istediğinizden emin misiniz?",
            "delete_project_message": "kalıcı olarak silinecek.",
            "delete_routine_title": "Bu rutini silmek istediğinizden emin misiniz?",
            "delete_routine_message": "kalıcı olarak silinecek.",
            
            // Toolbar
            "statistics": "İstatistikler",
            "settings": "Ayarlar",
            
            // Placeholder
            "add_routine_placeholder": "Yeni rutin ekle...",
            
            // Ayarlar
            "settings_title": "Ayarlar",
            "appearance": "Görünüm",
            "theme": "Tema",
            "system_theme": "Sistem",
            "light_theme": "Aydınlık",
            "dark_theme": "Karanlık",
            "sound": "Ses",
            "sound_effects": "Ses Efektleri",
            "language": "Dil",
            "select_language": "Dil Seçin",
            "notifications": "Bildirimler",
            "enable_notifications": "Bildirimleri Etkinleştir",
            "morning_summary": "Sabah Günlük Özet",
            "evening_incomplete": "Akşam Tamamlanmayanlar",
            "deadline_reminders": "Son Tarih Uyarıları",
            "data": "Veri",
            "export_data": "Verileri Dışa Aktar",
            "import_data": "Verileri İçe Aktar",
            "clear_all_data": "Tüm Verileri Temizle",
            "about": "Hakkında",
            "about_app": "Uygulama Hakkında",
            "version": "Versiyon",
            "theme_follows_system": "Sistem seçeneği macOS tema ayarlarınızı takip eder",
            "language_change_instant": "Dil değişikliği anında uygulanır",
            "haptic_feedback": "Dokunma Geri Bildirimi",
            "on": "Açık",
            
            // Proje Düzenleme
            "edit_project_info": "Proje Bilgilerini Düzenle",
            "save_changes": "Değişiklikleri Kaydet",
            "add_new_project": "Yeni Proje Ekle",
            "edit_project": "Projeyi Düzenle",
            "project_details": "Proje Detayları",
            "notes": "Notlar",
            "links": "Linkler",
            "tags": "Etiketler",
            "category": "Kategori",
            "recurring": "Tekrar Eden",
            "recurring_task": "Tekrar Eden Görev",
            "subtasks": "Alt Görevler",
            "files": "Dosyalar",
            "file_attachments": "Dosya Eklentileri",
            "select_icon": "İkon Seç",
            "existing_categories": "Mevcut Kategoriler:",
            "tag_examples": "Örnekler: #iş #kişisel #önemli #hızlı",
            "recurring_description": "Görev tamamlandığında, seçilen sıklıkta otomatik olarak yeni bir kopya oluşturulacak.",
            
            // Form Detayları
            "recurrence_type": "Tekrar Türü",
            "recurrence_none": "Yok",
            "recurrence_daily": "Günlük",
            "recurrence_weekly": "Haftalık",
            "recurrence_monthly": "Aylık",
            "recurrence_yearly": "Yıllık",
            "add_new_subtask_placeholder": "Yeni alt görev ekle...",
            "add_file": "Dosya Ekle",
            "set_end_date": "Bitiş Tarihi Belirle",
            "end_date": "Bitiş Tarihi",
            "category_placeholder": "Kategori adı (örn: İş, Kişisel)",
            "save_notes": "Notları Kaydet",
            "file_tip": "💡 İpucu: Dosyalar Documents klasöründe saklanacak",
            "info": "ℹ️ Bilgi",
            
            // İstatistikler
            "statistics_analytics": "İstatistikler ve Analitik",
            "current_streak": "Güncel Seri",
            "days_in_row": "gün üst üste",
            "longest_streak": "En Uzun Seri",
            "days": "gün",
            "completion": "Tamamlama",
            "tasks": "görev",
            "active_days": "Aktif Günler",
            "total": "toplam",
            "weekly_completion_chart": "Haftalık Tamamlama Grafiği",
            "no_data_yet": "Henüz veri yok. Görevleri tamamladıkça burada görünecek.",
            "monthly_productivity_chart": "Aylık Verimlilik Grafiği",
            "hourly_productivity": "Saatlik Verimlilik",
            "productivity_score": "Verimlilik Skoru",
            "good": "İyi",
            "current_level": "Mevcut seviyeniz",
            "most_productive_hour": "En Üretken Saat",
            "most_productive_day": "En Üretken Gün",
            "tasks_completed": "görev tamamlandı",
            "day": "Gün",
            "completed": "Tamamlanan",
            "month": "Ay",
            "hour": "Saat",
            "task": "Görev",
            "priority_distribution_pie": "Öncelik Dağılımı (Pasta Grafiği)",
            "no_projects_yet": "Henüz proje yok",
            "number": "Sayı",
            "priority_label": "Öncelik",
            "total_tasks": "Toplam Görev",
            "completed_tasks": "Tamamlanan",
            "active_tasks": "Aktif",
            "average_completion_time": "Ortalama Tamamlanma Süresi",
            "average_time": "Ortalama süre",
            "achievements": "Başarı Rozetleri",
            "completion_points": "Tamamlama: 50 puan",
            "streak_points": "Streak: 30 puan",
            "activity_points": "Aktivite: 20 puan",
            
            // Başarı İsimleri
            "achievement_first_step": "İlk Adım",
            "achievement_first_step_desc": "İlk görevini tamamla",
            "achievement_beginner": "Başlangıç",
            "achievement_beginner_desc": "10 görev tamamla",
            "achievement_productive": "Üretken",
            "achievement_productive_desc": "50 görev tamamla",
            "achievement_expert": "Uzman",
            "achievement_expert_desc": "100 görev tamamla",
            "achievement_legend": "Efsane",
            "achievement_legend_desc": "500 görev tamamla",
            "achievement_determined": "Kararlı",
            "achievement_determined_desc": "7 gün streak",
            "achievement_disciplined": "Disiplinli",
            "achievement_disciplined_desc": "30 gün streak",
            "achievement_unstoppable": "Unstoppable",
            "achievement_unstoppable_desc": "100 gün streak",
            
            // Level İsimleri
            "level_legend": "🏆 Efsane",
            "level_great": "⭐ Harika",
            "level_good": "✨ İyi",
            "level_improving": "📈 Gelişiyor",
            "level_beginner": "🌱 Başlangıç",
            
            // Gün İsimleri
            "monday": "Pazartesi",
            "tuesday": "Salı",
            "wednesday": "Çarşamba",
            "thursday": "Perşembe",
            "friday": "Cuma",
            "saturday": "Cumartesi",
            "sunday": "Pazar",
            
            // Kısa Gün İsimleri
            "mon": "Pzt",
            "tue": "Sal",
            "wed": "Çar",
            "thu": "Per",
            "fri": "Cum",
            "sat": "Cmt",
            "sun": "Paz",
        ],
        .english: [
            // Main Titles
            "projects_title": "Projects & Big Tasks",
            "projects_subtitle": "Your long-term goals and major projects",
            "routines_title": "Daily Routines",
            "routines_subtitle": "Habits that repeat every day",
            
            // Buttons
            "new_project": "New Project",
            "new_day": "New Day",
            "confirm": "Confirm",
            "completed_exclamation": "Completed!",
            "used_today": "Used Today",
            "add": "Add",
            "cancel": "Cancel",
            "save": "Save",
            "delete": "Delete",
            "edit": "Edit",
            "close": "Close",
            
            // Form Fields
            "project_title": "Project Title",
            "description": "Description",
            "priority": "Priority",
            "add_deadline": "Add Deadline",
            "deadline": "Deadline",
            "duration": "Duration (e.g. 2 weeks)",
            
            // Priorities
            "priority_high": "High",
            "priority_medium": "Medium",
            "priority_low": "Low",
            
            // Empty State
            "no_projects": "No Projects Yet",
            "no_projects_desc": "Click the button above to add your first project",
            "no_routines": "No Routines Yet",
            "no_routines_desc": "Type above to add your daily routines",
            
            // Statistics
            "stats_title": "Today's Statistics",
            "completed_count": "Completed:",
            "completed_word": "completed",
            
            // Confirmation Messages
            "delete_project_title": "Are you sure you want to delete this project?",
            "delete_project_message": "will be permanently deleted.",
            "delete_routine_title": "Are you sure you want to delete this routine?",
            "delete_routine_message": "will be permanently deleted.",
            
            // Toolbar
            "statistics": "Statistics",
            "settings": "Settings",
            
            // Placeholder
            "add_routine_placeholder": "Add new routine...",
            
            // Settings
            "settings_title": "Settings",
            "appearance": "Appearance",
            "theme": "Theme",
            "system_theme": "System",
            "light_theme": "Light",
            "dark_theme": "Dark",
            "sound": "Sound",
            "sound_effects": "Sound Effects",
            "language": "Language",
            "select_language": "Select Language",
            "notifications": "Notifications",
            "enable_notifications": "Enable Notifications",
            "morning_summary": "Morning Daily Summary",
            "evening_incomplete": "Evening Incomplete Tasks",
            "deadline_reminders": "Deadline Reminders",
            "data": "Data",
            "export_data": "Export Data",
            "import_data": "Import Data",
            "clear_all_data": "Clear All Data",
            "about": "About",
            "about_app": "About App",
            "version": "Version",
            "theme_follows_system": "System option follows your macOS theme settings",
            "language_change_instant": "Language change applies instantly",
            "haptic_feedback": "Haptic Feedback",
            "on": "On",
            
            // Project Edit
            "edit_project_info": "Edit Project Information",
            "save_changes": "Save Changes",
            "add_new_project": "Add New Project",
            "edit_project": "Edit Project",
            "project_details": "Project Details",
            "notes": "Notes",
            "links": "Links",
            "tags": "Tags",
            "category": "Category",
            "recurring": "Recurring",
            "recurring_task": "Recurring Task",
            "subtasks": "Subtasks",
            "files": "Files",
            "file_attachments": "File Attachments",
            "select_icon": "Select Icon",
            "existing_categories": "Existing Categories:",
            "tag_examples": "Examples: #work #personal #important #quick",
            "recurring_description": "When the task is completed, a new copy will be automatically created at the selected frequency.",
            
            // Form Details
            "recurrence_type": "Recurrence Type",
            "recurrence_none": "None",
            "recurrence_daily": "Daily",
            "recurrence_weekly": "Weekly",
            "recurrence_monthly": "Monthly",
            "recurrence_yearly": "Yearly",
            "add_new_subtask_placeholder": "Add new subtask...",
            "add_file": "Add File",
            "set_end_date": "Set End Date",
            "end_date": "End Date",
            "category_placeholder": "Category name (e.g. Work, Personal)",
            "save_notes": "Save Notes",
            "file_tip": "💡 Tip: Files will be stored in Documents folder",
            "info": "ℹ️ Info",
            
            // Statistics
            "statistics_analytics": "Statistics & Analytics",
            "current_streak": "Current Streak",
            "days_in_row": "days in a row",
            "longest_streak": "Longest Streak",
            "days": "days",
            "completion": "Completion",
            "tasks": "tasks",
            "active_days": "Active Days",
            "total": "total",
            "weekly_completion_chart": "Weekly Completion Chart",
            "no_data_yet": "No data yet. It will appear here as you complete tasks.",
            "monthly_productivity_chart": "Monthly Productivity Chart",
            "hourly_productivity": "Hourly Productivity",
            "productivity_score": "Productivity Score",
            "good": "Good",
            "current_level": "Current level",
            "most_productive_hour": "Most Productive Hour",
            "most_productive_day": "Most Productive Day",
            "tasks_completed": "tasks completed",
            "day": "Day",
            "completed": "Completed",
            "month": "Month",
            "hour": "Hour",
            "task": "Task",
            "priority_distribution_pie": "Priority Distribution (Pie Chart)",
            "no_projects_yet": "No projects yet",
            "number": "Number",
            "priority_label": "Priority",
            "total_tasks": "Total Tasks",
            "completed_tasks": "Completed",
            "active_tasks": "Active",
            "average_completion_time": "Average Completion Time",
            "average_time": "Average time",
            "achievements": "Achievements",
            "completion_points": "Completion: 50 points",
            "streak_points": "Streak: 30 points",
            "activity_points": "Activity: 20 points",
            
            // Achievement Names
            "achievement_first_step": "First Step",
            "achievement_first_step_desc": "Complete your first task",
            "achievement_beginner": "Beginner",
            "achievement_beginner_desc": "Complete 10 tasks",
            "achievement_productive": "Productive",
            "achievement_productive_desc": "Complete 50 tasks",
            "achievement_expert": "Expert",
            "achievement_expert_desc": "Complete 100 tasks",
            "achievement_legend": "Legend",
            "achievement_legend_desc": "Complete 500 tasks",
            "achievement_determined": "Determined",
            "achievement_determined_desc": "7 day streak",
            "achievement_disciplined": "Disciplined",
            "achievement_disciplined_desc": "30 day streak",
            "achievement_unstoppable": "Unstoppable",
            "achievement_unstoppable_desc": "100 day streak",
            
            // Level Names
            "level_legend": "🏆 Legend",
            "level_great": "⭐ Great",
            "level_good": "✨ Good",
            "level_improving": "📈 Improving",
            "level_beginner": "🌱 Beginner",
            
            // Day Names
            "monday": "Monday",
            "tuesday": "Tuesday",
            "wednesday": "Wednesday",
            "thursday": "Thursday",
            "friday": "Friday",
            "saturday": "Saturday",
            "sunday": "Sunday",
            
            // Short Day Names
            "mon": "Mon",
            "tue": "Tue",
            "wed": "Wed",
            "thu": "Thu",
            "fri": "Fri",
            "sat": "Sat",
            "sun": "Sun",
        ]
    ]
}

// View extension for easy access
extension View {
    func localized(_ key: String) -> String {
        LocalizationManager.shared.localized(key)
    }
}

