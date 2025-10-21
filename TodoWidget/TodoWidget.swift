//
//  TodoWidget.swift
//  TodoWidget
//
//  Created by Macbook Air on 21.10.2025.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct RoutineEntry: TimelineEntry {
    let date: Date
    let completedCount: Int
    let totalCount: Int
    let percentage: Double
    let routines: [RoutineItem]
}

// MARK: - Routine Item (Widget için basitleştirilmiş)
struct RoutineItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - Timeline Provider
struct RoutineProvider: TimelineProvider {
    typealias Entry = RoutineEntry
    
    func placeholder(in context: Context) -> RoutineEntry {
        RoutineEntry(
            date: Date(),
            completedCount: 3,
            totalCount: 5,
            percentage: 60.0,
            routines: [
                RoutineItem(title: "Sabah Sporu", isCompleted: true),
                RoutineItem(title: "Kitap Oku", isCompleted: false),
                RoutineItem(title: "Su İç", isCompleted: true),
                RoutineItem(title: "Meditasyon", isCompleted: false),
                RoutineItem(title: "Günlük Yaz", isCompleted: true)
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (RoutineEntry) -> Void) {
        let entry = createEntry()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RoutineEntry>) -> Void) {
        let entry = createEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func createEntry() -> RoutineEntry {
        print("🔍 Widget: Veri yükleniyor...")
        
        // Önce App Group dene
        var defaults = UserDefaults(suiteName: "group.todoapp.shared")
        var data: Data? = defaults?.data(forKey: "SavedRoutines")
        
        if data == nil {
            print("⚠️ Widget: App Group'ta veri yok, standard UserDefaults deneniyor...")
            defaults = UserDefaults.standard
            data = defaults?.data(forKey: "SavedRoutines")
        }
        
        if let data = data {
            print("✅ Widget: SavedRoutines verisi bulundu, boyut: \(data.count) bytes")
            
            // RoutineModel kullanarak decode et
            if let routines = try? JSONDecoder().decode([RoutineModel].self, from: data) {
                print("✅ Widget: \(routines.count) rutin decode edildi")
                
                let items = routines.map { routine in
                    RoutineItem(
                        id: routine.id,
                        title: routine.title,
                        isCompleted: routine.isCompleted
                    )
                }
                
                let total = items.count
                let completed = items.filter { $0.isCompleted }.count
                let percentage = total > 0 ? Double(completed) / Double(total) * 100 : 0
                
                print("📊 Widget: \(completed)/\(total) tamamlandı (\(Int(percentage))%)")
                
                return RoutineEntry(
                    date: Date(),
                    completedCount: completed,
                    totalCount: total,
                    percentage: percentage,
                    routines: items
                )
            } else {
                print("❌ Widget: Decode hatası")
                
                // Ham veriyi yazdır
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 Widget: Ham JSON: \(jsonString.prefix(200))...")
                }
            }
        } else {
            print("❌ Widget: SavedRoutines verisi bulunamadı")
            print("📋 Widget: App Group ve Standard UserDefaults kontrol edildi")
        }
        
        // Varsayılan boş entry
        print("⚠️ Widget: Boş entry döndürülüyor")
        return RoutineEntry(
            date: Date(),
            completedCount: 0,
            totalCount: 0,
            percentage: 0,
            routines: []
        )
    }
}

// MARK: - Widget View
struct RoutineWidgetView: View {
    let entry: RoutineEntry
    
    var body: some View {
        HStack(spacing: 0) {
            // Sol Panel - İlerleme
            leftPanel
                .frame(maxWidth: .infinity)
            
            Divider()
                .padding(.vertical, 8)
            
            // Sağ Panel - Rutinler
            rightPanel
                .frame(maxWidth: .infinity)
        }
        .padding(12)
    }
    
    // MARK: - Sol Panel
    private var leftPanel: some View {
        VStack(spacing: 10) {
            // Başlık
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Günlük Rutinler")
                    .font(.system(size: 13, weight: .semibold))
            }
            
            Spacer()
            
            // Dairesel İlerleme
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: entry.percentage / 100)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(entry.percentage))%")
                    .font(.system(size: 22, weight: .bold))
            }
            
            Spacer()
            
            // Sayaç
            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    Text("\(entry.completedCount)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                    Text("/")
                        .foregroundColor(.secondary)
                    Text("\(entry.totalCount)")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                Text("tamamlandı")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Motivasyon
            Text(motivationMessage)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }
    
    // MARK: - Sağ Panel
    private var rightPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Rutinler")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            
            if entry.routines.isEmpty {
                emptyState
            } else {
                routineList
            }
        }
    }
    
    // MARK: - Boş Durum
    private var emptyState: some View {
        VStack(spacing: 6) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 30))
                .foregroundColor(.secondary.opacity(0.4))
            Text("Henüz rutin yok")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Rutin Listesi
    private var routineList: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(entry.routines.prefix(7)) { routine in
                HStack(spacing: 6) {
                    Image(systemName: routine.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 10))
                        .foregroundColor(routine.isCompleted ? .green : .gray)
                    
                    Text(routine.title)
                        .font(.system(size: 11))
                        .strikethrough(routine.isCompleted)
                        .foregroundColor(routine.isCompleted ? .secondary : .primary)
                        .lineLimit(1)
                }
            }
            
            if entry.routines.count > 7 {
                Text("+\(entry.routines.count - 7) daha...")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var progressColor: Color {
        switch entry.percentage {
        case 100: return .green
        case 75..<100: return .blue
        case 50..<75: return .orange
        default: return .red
        }
    }
    
    private var motivationMessage: String {
        switch entry.percentage {
        case 100: return "🎉 Mükemmel!"
        case 75..<100: return "💪 Harika!"
        case 50..<75: return "✨ Devam et!"
        case 25..<50: return "🚀 Başlangıç!"
        case 1..<25: return "🌱 İyi başlangıç!"
        default: return "📝 Başla!"
        }
    }
}

// MARK: - Widget Configuration
@main
struct GunlukRutinlerWidget: Widget {
    let kind: String = "GunlukRutinlerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RoutineProvider()) { entry in
            RoutineWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(nsColor: .windowBackgroundColor)
                }
        }
        .configurationDisplayName("Günlük Rutinler")
        .description("Bugünün rutin tamamlanma yüzdesini gösterir")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    GunlukRutinlerWidget()
} timeline: {
    RoutineEntry(
        date: Date(),
        completedCount: 3,
        totalCount: 5,
        percentage: 60,
        routines: [
            RoutineItem(title: "Sabah Sporu", isCompleted: true),
            RoutineItem(title: "Kitap Oku", isCompleted: false),
            RoutineItem(title: "Su İç", isCompleted: true),
            RoutineItem(title: "Meditasyon", isCompleted: false),
            RoutineItem(title: "Günlük Yaz", isCompleted: true)
        ]
    )
    RoutineEntry(
        date: Date(),
        completedCount: 5,
        totalCount: 5,
        percentage: 100,
        routines: [
            RoutineItem(title: "Sabah Sporu", isCompleted: true),
            RoutineItem(title: "Kitap Oku", isCompleted: true),
            RoutineItem(title: "Su İç", isCompleted: true),
            RoutineItem(title: "Meditasyon", isCompleted: true),
            RoutineItem(title: "Günlük Yaz", isCompleted: true)
        ]
    )
    RoutineEntry(
        date: Date(),
        completedCount: 0,
        totalCount: 0,
        percentage: 0,
        routines: []
    )
}
