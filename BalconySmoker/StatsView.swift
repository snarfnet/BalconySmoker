import SwiftUI

// MARK: - Achievements

struct Achievement: Identifiable {
    let id: String
    let icon: String
    let title: String
    let description: String
    let check: () -> Bool

    var unlocked: Bool { check() }
}

let allAchievements: [Achievement] = [
    Achievement(id: "first_smoke", icon: "🚬", title: "初めての一服", description: "煙草を1本吸い切る") {
        ScoreManager.totalCigarettes >= 1
    },
    Achievement(id: "chain_smoker", icon: "🔗", title: "チェーンスモーカー", description: "5コンボ以上を達成") {
        ScoreManager.bestCombo >= 5
    },
    Achievement(id: "nicotine_god", icon: "👑", title: "ニコチンの神", description: "8コンボ以上を達成") {
        ScoreManager.bestCombo >= 8
    },
    Achievement(id: "dodge_master", icon: "🏃", title: "回避の達人", description: "累計50回脅威を回避") {
        ScoreManager.totalDodges >= 50
    },
    Achievement(id: "veteran", icon: "🎖️", title: "ベテランスモーカー", description: "10回以上プレイ") {
        ScoreManager.gamesPlayed >= 10
    },
    Achievement(id: "ten_cigs", icon: "📦", title: "1箱クリア", description: "累計10本吸い切る") {
        ScoreManager.totalCigarettes >= 10
    },
    Achievement(id: "fifty_cigs", icon: "🏭", title: "工場長", description: "累計50本吸い切る") {
        ScoreManager.totalCigarettes >= 50
    },
    Achievement(id: "high_level", icon: "⚡", title: "上級者", description: "レベル6以上に到達") {
        ScoreManager.bestLevel >= 6
    },
    Achievement(id: "max_level", icon: "🌟", title: "伝説のスモーカー", description: "レベル12に到達") {
        ScoreManager.bestLevel >= 12
    },
    Achievement(id: "hard_clear", icon: "😈", title: "鉄の意志", description: "ハードで1本吸い切る") {
        ScoreManager.hardClears >= 1
    },
    Achievement(id: "score_1000", icon: "💰", title: "千点突破", description: "スコア1,000点以上") {
        ScoreManager.highScore >= 1000
    },
    Achievement(id: "score_5000", icon: "💎", title: "ダイヤモンドスモーカー", description: "スコア5,000点以上") {
        ScoreManager.highScore >= 5000
    },
    Achievement(id: "puff_500", icon: "💨", title: "煙の達人", description: "累計500回パフする") {
        ScoreManager.totalPuffs >= 500
    },
    Achievement(id: "survivor", icon: "🛡️", title: "不屈の精神", description: "累計20回捕まっても続ける") {
        ScoreManager.totalCaught >= 20
    },
]

// MARK: - Stats View

struct StatsView: View {
    let onBack: () -> Void
    @State private var showAchievements = false

    private var unlockedCount: Int { allAchievements.filter(\.unlocked).count }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("戻る")
                        }
                        .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Text("記録").font(.system(size: 32, weight: .black)).foregroundColor(.white)

                // Stats cards
                VStack(spacing: 12) {
                    statRow(icon: "🏆", label: "ハイスコア", value: "\(ScoreManager.highScore)")
                    statRow(icon: "🎮", label: "プレイ回数", value: "\(ScoreManager.gamesPlayed)")
                    statRow(icon: "🚬", label: "累計吸い切り", value: "\(ScoreManager.totalCigarettes)本")
                    statRow(icon: "💨", label: "累計パフ数", value: "\(ScoreManager.totalPuffs)回")
                    statRow(icon: "🔥", label: "最高コンボ", value: "\(ScoreManager.bestCombo)x")
                    statRow(icon: "⚡", label: "最高レベル", value: "Lv.\(ScoreManager.bestLevel)")
                    statRow(icon: "🏃", label: "累計回避", value: "\(ScoreManager.totalDodges)回")
                    statRow(icon: "❌", label: "累計バレ", value: "\(ScoreManager.totalCaught)回")

                    if ScoreManager.totalDodges + ScoreManager.totalCaught > 0 {
                        let rate = Double(ScoreManager.totalDodges) / Double(ScoreManager.totalDodges + ScoreManager.totalCaught) * 100
                        statRow(icon: "📊", label: "回避率", value: String(format: "%.1f%%", rate))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal)

                // Achievements section
                VStack(spacing: 12) {
                    HStack {
                        Text("実績").font(.title2.weight(.bold)).foregroundColor(.white)
                        Spacer()
                        Text("\(unlockedCount)/\(allAchievements.count)")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.orange)
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 4).fill(Color.orange)
                                .frame(width: geo.size.width * CGFloat(unlockedCount) / CGFloat(allAchievements.count))
                        }
                    }.frame(height: 8)

                    ForEach(allAchievements) { a in
                        achievementRow(a)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer().frame(height: 40)
            }
            .padding(.top, 20)
        }
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Text(icon).font(.title3)
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).font(.headline.weight(.bold)).foregroundColor(.white)
        }
        .padding(.vertical, 4)
    }

    private func achievementRow(_ a: Achievement) -> some View {
        HStack(spacing: 12) {
            Text(a.unlocked ? a.icon : "🔒")
                .font(.title2)
                .frame(width: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(a.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(a.unlocked ? .white : .gray)
                Text(a.description)
                    .font(.caption)
                    .foregroundColor(a.unlocked ? .orange.opacity(0.8) : .gray.opacity(0.6))
            }
            Spacer()
            if a.unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 6)
        .opacity(a.unlocked ? 1.0 : 0.5)
    }
}
