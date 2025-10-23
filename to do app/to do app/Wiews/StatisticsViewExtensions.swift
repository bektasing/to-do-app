//
//  StatisticsViewExtensions.swift
//  to do app
//
//  Created by Macbook Air on 21.10.2025.
//

import SwiftUI
import Charts

// MARK: - Verimlilik Skoru View
struct ProductivityScoreView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        let score = statsManager.getProductivityScore(from: viewModel.projects, routines: viewModel.routines)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gauge.high")
                    .foregroundColor(.blue)
                Text(localizationManager.localized("productivity_score"))
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 30) {
                // Skor Göstergesi
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(score.score) / 100)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 15, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 4) {
                        Text("\(score.score)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        Text("/100")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Level Bilgisi
                VStack(alignment: .leading, spacing: 8) {
                    Text(score.level)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(localizationManager.localized("current_level"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(localizationManager.localized("completion_points"))
                                .font(.caption)
                        }
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text(localizationManager.localized("streak_points"))
                                .font(.caption)
                        }
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                            Text(localizationManager.localized("activity_points"))
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
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

// MARK: - Öncelik Pasta Grafiği
struct PriorityPieChartView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        let distribution = statsManager.getPriorityDistribution(from: viewModel.projects)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.pink)
                Text(localizationManager.localized("priority_distribution_pie"))
                    .font(.headline)
                Spacer()
            }
            
            if viewModel.projects.isEmpty {
                Text(localizationManager.localized("no_projects_yet"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                HStack(spacing: 40) {
                    // Pasta Grafiği
                    Chart {
                        ForEach(Array(distribution.keys.sorted()), id: \.self) { key in
                            SectorMark(
                                angle: .value("Sayı", distribution[key] ?? 0),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Öncelik", key))
                            .cornerRadius(4)
                        }
                    }
                    .chartForegroundStyleScale([
                        "Yüksek": .red,
                        "Orta": .orange,
                        "Düşük": .green
                    ])
                    .frame(height: 200)
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(distribution.keys.sorted()), id: \.self) { key in
                            HStack {
                                Circle()
                                    .fill(key == "Yüksek" ? Color.red : key == "Orta" ? Color.orange : Color.green)
                                    .frame(width: 12, height: 12)
                                
                                Text(key)
                                    .font(.caption)
                                
                                Spacer()
                                
                                Text("\(distribution[key] ?? 0)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .frame(width: 150)
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

// MARK: - Toplam Sayaçlar
struct TotalCountersView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        let counts = statsManager.getTotalCounts(from: viewModel.projects, routines: viewModel.routines)
        
        HStack(spacing: 15) {
            CounterCard(
                icon: "list.bullet",
                title: localizationManager.localized("total_tasks"),
                value: "\(counts.total)",
                color: .blue
            )
            
            CounterCard(
                icon: "checkmark.circle.fill",
                title: localizationManager.localized("completed_tasks"),
                value: "\(counts.completed)",
                color: .green
            )
            
            CounterCard(
                icon: "clock.fill",
                title: localizationManager.localized("active_tasks"),
                value: "\(counts.active)",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
}

struct CounterCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
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

// MARK: - Ortalama Tamamlanma Süresi
struct AverageCompletionTimeView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        let avgTime = statsManager.getAverageCompletionTime(from: viewModel.projects)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.cyan)
                Text(localizationManager.localized("average_completion_time"))
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f \(localizationManager.localized("days"))", avgTime))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(localizationManager.localized("average_time"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "hourglass")
                    .font(.system(size: 50))
                    .foregroundColor(.cyan)
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

// MARK: - Başarı Rozetleri
struct AchievementsView: View {
    @ObservedObject var viewModel: TodoViewModel
    @ObservedObject var statsManager: StatisticsManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var localizationManager: LocalizationManager
    
    var body: some View {
        let achievements = statsManager.getAchievements(from: viewModel.projects, routines: viewModel.routines)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text(localizationManager.localized("achievements"))
                    .font(.headline)
                Spacer()
                
                Text("\(achievements.filter { $0.isUnlocked }.count)/\(achievements.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(achievements) { achievement in
                    AchievementCard(achievement: achievement)
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

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.icon)
                .font(.system(size: 40))
                .opacity(achievement.isUnlocked ? 1.0 : 0.3)
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .opacity(achievement.isUnlocked ? 1.0 : 0.5)
            
            Text(achievement.description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Progress bar
            if !achievement.isUnlocked {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * CGFloat(achievement.progressPercentage / 100), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
                
                Text("\(achievement.progress)/\(achievement.requirement)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(achievement.isUnlocked ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(achievement.isUnlocked ? Color.yellow : Color.clear, lineWidth: 2)
                )
        )
    }
}
