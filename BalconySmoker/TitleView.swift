import SwiftUI

struct TitleView: View {
    let vm: GameViewModel
    @State private var glow = false
    @State private var smokeFloat = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            // Building silhouette
            Text("🌃").font(.system(size: 60)).opacity(0.6)

            Spacer().frame(height: 30)

            // Title
            VStack(spacing: 8) {
                Text("バルコニースモーカー").font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: .orange.opacity(glow ? 0.8 : 0.3), radius: glow ? 20 : 8)
                Text("BALCONY SMOKER").font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange.opacity(0.7))
                    .tracking(6)
            }
            .onAppear { withAnimation(.easeInOut(duration: 1.5).repeatForever()) { glow = true } }

            Spacer().frame(height: 30)

            // Man smoking with floating smoke
            ZStack {
                Text("💨").font(.system(size: 28))
                    .offset(x: 40, y: smokeFloat ? -30 : -10)
                    .opacity(smokeFloat ? 0.3 : 0.7)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            smokeFloat = true
                        }
                    }
                Text("🚬").font(.system(size: 40)).offset(x: 28, y: 0).opacity(0.7)
                Text("🧍‍♂️").font(.system(size: 70))
            }

            Spacer().frame(height: 20)

            // Difficulty picker
            VStack(spacing: 8) {
                Text("難易度").font(.caption).foregroundColor(.gray)
                HStack(spacing: 10) {
                    ForEach(Difficulty.allCases, id: \.rawValue) { diff in
                        Button {
                            vm.difficulty = diff
                            FeedbackEngine.buttonTap()
                        } label: {
                            VStack(spacing: 4) {
                                Text(diff.icon).font(.title2)
                                Text(diff.rawValue).font(.caption2.weight(.bold))
                            }
                            .foregroundColor(vm.difficulty == diff ? .black : .white.opacity(0.6))
                            .frame(width: 80, height: 56)
                            .background(vm.difficulty == diff ? Color.orange : Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(vm.difficulty == diff ? Color.orange : Color.white.opacity(0.1), lineWidth: 1.5)
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)

            Spacer().frame(height: 16)

            // High score
            if ScoreManager.highScore > 0 {
                VStack(spacing: 4) {
                    Text("🏆 ハイスコア").font(.caption).foregroundColor(.gray)
                    Text("\(ScoreManager.highScore)").font(.title2.weight(.bold)).foregroundColor(.yellow)
                    if ScoreManager.totalCigarettes > 0 {
                        Text("累計 🚬×\(ScoreManager.totalCigarettes)  プレイ回数 \(ScoreManager.gamesPlayed)")
                            .font(.caption2).foregroundColor(.gray.opacity(0.7))
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)

                Spacer().frame(height: 12)
            }

            // Enemies preview
            VStack(spacing: 8) {
                Text("敵").font(.caption).foregroundColor(.gray)
                HStack(spacing: 12) {
                    ForEach(ThreatType.allCases) { t in
                        Text(t.icon).font(.title2)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)

            Spacer().frame(height: 24)

            Button(action: { vm.startGame() }) {
                Text("こっそり始める").font(.title2.weight(.bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.orange)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)

            Spacer().frame(height: 12)

            // Bottom navigation
            HStack(spacing: 24) {
                Button { vm.state = .tutorial } label: {
                    Label("遊び方", systemImage: "questionmark.circle")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.orange.opacity(0.8))
                }
                Button { vm.state = .stats } label: {
                    Label("記録", systemImage: "chart.bar")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.orange.opacity(0.8))
                }
            }

            Spacer().frame(height: 8)

            Text("監視の目を逃れながら\n一服を完了せよ！").multilineTextAlignment(.center)
                .font(.caption).foregroundColor(.gray)

            Spacer()
        }
        .padding()
    }
}
