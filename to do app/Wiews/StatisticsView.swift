//
//  StatisticsView.swift
//  to do app
//
//  Created by Macbook Air on 21.10.2025.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Başlık ve Kapat Butonu
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("İstatistikler ve Analitik")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    
                    // Kapat butonu
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Kapat")
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Özet Kartlar
                SummaryCardsView(viewModel: viewModel, statsManager: statsManager)
                
                // Haftalık Tamamlama Grafiği
                WeeklyCompletionChart(viewModel: viewModel, statsManager: statsManager)
                
                // Aylık Verimlilik Grafiği
                MonthlyProductivityChart(viewModel: viewModel, statsManager: statsManager)
                
                // Saatlik Verimlilik
                HourlyProductivityChart(viewModel: viewModel, statsManager: statsManager)
                
                // Verimlilik Skoru (YENİ!)
                ProductivityScoreView(viewModel: viewModel, statsManager: statsManager)
                
                // Öncelik Dağılımı Pasta Grafiği (YENİ!)
                PriorityPieChartView(viewModel: viewModel, statsManager: statsManager)
                
                // Toplam Sayaçlar (YENİ!)
                TotalCountersView(viewModel: viewModel, statsManager: statsManager)
                
                // Ortalama Tamamlanma Süresi (YENİ!)
                AverageCompletionTimeView(viewModel: viewModel, statsManager: statsManager)
                
                // Başarı Rozetleri (YENİ!)
                AchievementsView(viewModel: viewModel, statsManager: statsManager)
                
                // En Üretken Gün
                MostProductiveDayView(viewModel: viewModel, statsManager: statsManager)
                
                Spacer(minLength: 40)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color.adaptiveWindowBackground)
    }
}

// MARK: - Özet Kartlar
struct SummaryCardsView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    
    var body: some View {
        HStack(spacing: 15) {
            // Streak Kartı
            StatCard(
                icon: "flame.fill",
                title: "Güncel Seri",
                value: "\(statsManager.streakData.currentStreak)",
                subtitle: "gün üst üste",
                color: .orange
            )
            
            // En Uzun Streak
            StatCard(
                icon: "star.fill",
                title: "En Uzun Seri",
                value: "\(statsManager.streakData.longestStreak)",
                subtitle: "gün",
                color: .yellow
            )
            
            // Tamamlama Oranı
            let goalData = statsManager.getGoalComparison(from: viewModel.projects, routines: viewModel.routines)
            StatCard(
                icon: "checkmark.circle.fill",
                title: "Tamamlama",
                value: String(format: "%.0f%%", goalData.percentage),
                subtitle: "\(goalData.completed)/\(goalData.total) görev",
                color: .green
            )
            
            // Toplam Aktif Gün
            StatCard(
                icon: "calendar.badge.clock",
                title: "Aktif Günler",
                value: "\(statsManager.streakData.totalDaysActive)",
                subtitle: "toplam",
                color: .blue
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Haftalık Tamamlama Grafiği
struct WeeklyCompletionChart: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let weeklyData = statsManager.getWeeklyStats(from: viewModel.projects)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("Haftalık Tamamlama Grafiği")
                    .font(.headline)
                Spacer()
            }
            
            if weeklyData.isEmpty || weeklyData.allSatisfy({ $0.completedTasks == 0 }) {
                Text("Henüz veri yok. Görevleri tamamladıkça burada görünecek.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(weeklyData) { stat in
                    BarMark(
                        x: .value("Gün", stat.shortDayName),
                        y: .value("Tamamlanan", stat.completedTasks)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Aylık Verimlilik Grafiği
struct MonthlyProductivityChart: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let monthlyData = statsManager.getMonthlyStats(from: viewModel.projects, routines: viewModel.routines)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                Text("Aylık Verimlilik Grafiği")
                    .font(.headline)
                Spacer()
            }
            
            if monthlyData.isEmpty || monthlyData.allSatisfy({ $0.completedTasks == 0 }) {
                Text("Henüz veri yok. Görevleri tamamladıkça burada görünecek.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(monthlyData) { stat in
                    LineMark(
                        x: .value("Ay", stat.month),
                        y: .value("Tamamlanan", stat.completedTasks)
                    )
                    .foregroundStyle(.purple)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Ay", stat.month),
                        y: .value("Tamamlanan", stat.completedTasks)
                    )
                    .foregroundStyle(.purple)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Saatlik Verimlilik Grafiği
struct HourlyProductivityChart: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let hourlyData = statsManager.getHourlyProductivity(from: viewModel.projects)
        let mostProductiveHour = statsManager.getMostProductiveHour(from: viewModel.projects)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Saatlik Verimlilik")
                    .font(.headline)
                Spacer()
                
                if mostProductiveHour.count > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("En Üretken Saat")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(String(format: "%02d:00", mostProductiveHour.hour))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            if hourlyData.allSatisfy({ $0.tasksCompleted == 0 }) {
                Text("Henüz veri yok. Görevleri tamamladıkça burada görünecek.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(hourlyData.filter { $0.tasksCompleted > 0 }) { stat in
                    BarMark(
                        x: .value("Saat", stat.hourLabel),
                        y: .value("Görev", stat.tasksCompleted)
                    )
                    .foregroundStyle(.orange.gradient)
                }
                .frame(height: 150)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Öncelik Dağılımı (Kaldırıldı - Pasta grafiği kullanılıyor)
// PriorityDistributionView artık StatisticsViewExtensions.swift'te pasta grafiği olarak

// MARK: - En Üretken Gün
struct MostProductiveDayView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        let mostProductiveDay = statsManager.getMostProductiveDay(from: viewModel.projects)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("En Üretken Gün")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mostProductiveDay.day)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(mostProductiveDay.count) görev tamamlandı")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptiveCardBackground)
                .shadow(color: themeManager.isLightMode ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(
            viewModel: TodoViewModel(),
            statsManager: StatisticsManager()
        )
        .environmentObject(ThemeManager.shared)
    }
}
