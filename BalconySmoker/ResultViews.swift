import SwiftUI

struct StageClearView: View {
    let vm: GameViewModel
    @State private var scale: CGFloat = 0.5
    @State private var rotation: Double = -10

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("💨").font(.system(size: 60))
                .rotationEffect(.degrees(rotation))
                .scaleEffect(scale)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        scale = 1.0; rotation = 0
                    }
                }
            Text("一服完了！").font(.system(size: 40, weight: .black)).foregroundColor(.white)
            Text("🚬 × \(vm.cigarettesSmoked)").font(.title).foregroundColor(.orange)

            VStack(spacing: 6) {
                Text(clearMessage(count: vm.cigarettesSmoked)).font(.title3).foregroundColor(.yellow)
                Text("Lv.\(vm.level) — 次の煙草はもっと難しい...").font(.caption).foregroundColor(.gray)
            }

            Text("スコア: \(vm.score)").font(.headline).foregroundColor(.white.opacity(0.7))

            Spacer()
            Text("次の煙草を準備中...").font(.caption).foregroundColor(.gray)
                .padding(.bottom, 40)
        }
        .padding()
    }

    func clearMessage(count: Int) -> String {
        switch count {
        case 1: return "まあまあだ"
        case 2: return "なかなかやるじゃないか"
        case 3: return "腕が上がってきたな"
        case 5: return "煙草の達人"
        case 10: return "伝説のスモーカー"
        default: return count > 5 ? "もはや神の領域" : "いい感じだ"
        }
    }
}

struct GameOverView: View {
    let vm: GameViewModel
    @State private var isNewHighScore = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image("GameOverSkull")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .white.opacity(0.2), radius: 15)
            Text("ゲームオーバー").font(.system(size: 32, weight: .black)).foregroundColor(.red)
            Text("完全にバレた...").font(.body).foregroundColor(.gray)

            if isNewHighScore {
                Text("🏆 NEW HIGH SCORE! 🏆")
                    .font(.headline.weight(.black))
                    .foregroundStyle(
                        LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                    )
                    .padding(.vertical, 4)
            }

            VStack(spacing: 8) {
                HStack {
                    Text("最終スコア").foregroundColor(.gray)
                    Spacer()
                    Text("\(vm.score)").font(.title2.weight(.bold)).foregroundColor(.white)
                }
                HStack {
                    Text("吸い切った本数").foregroundColor(.gray)
                    Spacer()
                    Text("🚬 × \(vm.cigarettesSmoked)").font(.title3).foregroundColor(.orange)
                }
                Divider().background(Color.white.opacity(0.1))
                HStack {
                    Text("ハイスコア").foregroundColor(.gray)
                    Spacer()
                    Text("\(ScoreManager.highScore)").font(.title3.weight(.bold)).foregroundColor(.yellow)
                }
                HStack {
                    Text("累計本数").foregroundColor(.gray)
                    Spacer()
                    Text("🚬 × \(ScoreManager.totalCigarettes)").font(.subheadline).foregroundColor(.orange.opacity(0.8))
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal, 40)

            Text(vm.cigarettesSmoked == 0 ? "一本も吸えなかったか..." :
                 vm.cigarettesSmoked < 3 ? "まだまだ修行が足りない" :
                 vm.cigarettesSmoked < 7 ? "なかなかの腕前だった" : "見事な一生だった")
                .font(.subheadline).foregroundColor(.yellow)

            Button(action: { vm.restart() }) {
                Text("もう一服").font(.title3.weight(.bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.orange)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)

            Button(action: { vm.state = .title }) {
                Text("タイトルへ").foregroundColor(.gray).font(.subheadline)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            isNewHighScore = vm.score >= ScoreManager.highScore && vm.score > 0
        }
    }
}
