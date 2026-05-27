import SwiftUI

struct TutorialView: View {
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
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

                Text("遊び方").font(.system(size: 32, weight: .black)).foregroundColor(.white)

                // Objective
                tutorialSection(title: "目的", icon: "🎯") {
                    Text("バルコニーでこっそり煙草を吸おう。煙草ゲージを100%にすれば1本クリア。監視の目を避けながら、できるだけ多くの煙草を吸い切れ！")
                }

                // Controls
                tutorialSection(title: "操作", icon: "🕹️") {
                    VStack(alignment: .leading, spacing: 10) {
                        controlRow(icon: "🚬", label: "煙草を吸う", desc: "脅威がいない時にタップ。連続で吸うとコンボボーナス。")
                        controlRow(icon: "🫣", label: "隠れる", desc: "脅威が来たら隠れてやり過ごす。クールダウンあり。")
                    }
                }

                // Threats
                tutorialSection(title: "脅威（7種類）", icon: "⚠️") {
                    VStack(alignment: .leading, spacing: 10) {
                        threatRow(icon: "🙍‍♀️", name: "妻", desc: "最も危険。バレ速度が速く、猶予時間が短い。")
                        threatRow(icon: "👁️", name: "隣人（左右）", desc: "窓から覗いてくる。比較的猶予がある。")
                        threatRow(icon: "🐦‍⬛", name: "カラス", desc: "飛来して煙草を狙う。中程度の速さ。")
                        threatRow(icon: "👗", name: "洗濯物", desc: "上から落ちてくる。反応が速め。")
                        threatRow(icon: "🛸", name: "UFO", desc: "まれに出現。隠れても見つかることがある！")
                        threatRow(icon: "🌧️", name: "雨", desc: "豪雨で煙草が消える。逃げ場なし。")
                    }
                }

                // Gauges
                tutorialSection(title: "ゲージ", icon: "📊") {
                    VStack(alignment: .leading, spacing: 10) {
                        gaugeRow(color: .orange, name: "煙草ゲージ", desc: "100%で1本クリア。バレると20%減少。")
                        gaugeRow(color: .red, name: "バレ度", desc: "脅威に見つかると上昇。100%でアウト。")
                    }
                }

                // Difficulty
                tutorialSection(title: "難易度", icon: "🎚️") {
                    VStack(alignment: .leading, spacing: 10) {
                        diffRow(icon: "😌", name: "イージー", desc: "ライフ5、脅威遅め、ゲージ溜まりやすい")
                        diffRow(icon: "😐", name: "ノーマル", desc: "ライフ3、標準バランス")
                        diffRow(icon: "😈", name: "ハード", desc: "ライフ1、脅威速い、ゲージ溜まりにくい")
                    }
                }

                // Tips
                tutorialSection(title: "コツ", icon: "💡") {
                    VStack(alignment: .leading, spacing: 8) {
                        tipRow("脅威がいない隙に連続タップでコンボを稼ごう")
                        tipRow("隠れるのはクールダウンがある。タイミングを見極めて")
                        tipRow("UFOは隠れても見つかることがある。運も大事")
                        tipRow("レベルが上がると脅威が速くなる。早めに隠れよう")
                    }
                }

                Spacer().frame(height: 40)
            }
            .padding(.top, 20)
        }
    }

    private func tutorialSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(icon).font(.title2)
                Text(title).font(.title3.weight(.bold)).foregroundColor(.white)
            }
            content()
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func controlRow(icon: String, label: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.title3).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.subheadline.weight(.bold)).foregroundColor(.orange)
                Text(desc).font(.caption).foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private func threatRow(icon: String, name: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.title3).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.weight(.bold)).foregroundColor(.red.opacity(0.9))
                Text(desc).font(.caption).foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private func gaugeRow(color: Color, name: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 30, height: 8).padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.weight(.bold)).foregroundColor(color)
                Text(desc).font(.caption).foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private func diffRow(icon: String, name: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon).font(.title3).frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.subheadline.weight(.bold)).foregroundColor(.white)
                Text(desc).font(.caption).foregroundColor(.white.opacity(0.7))
            }
        }
    }

    private func tipRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("*").foregroundColor(.yellow).font(.headline)
            Text(text).font(.caption).foregroundColor(.white.opacity(0.8))
        }
    }
}
