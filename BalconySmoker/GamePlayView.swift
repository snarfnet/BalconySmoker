import SwiftUI

struct GamePlayView: View {
    @ObservedObject var vm: GameViewModel
    @State private var crowOffset: CGFloat = -200
    @State private var laundryOffset: CGFloat = -300
    @State private var ufoOffset: CGFloat = -100
    @State private var rainOpacity: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Stars & Moon
                StarsView()
                NightSkyView()

                VStack(spacing: 0) {
                    // Top HUD
                    HUDView(vm: vm)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Alert bar
                    AlertBarView(level: vm.alertLevel)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Smoke gauge
                    SmokeGaugeView(progress: vm.smokeGauge)
                        .padding(.horizontal, 16)
                        .padding(.top, 6)

                    Spacer()

                    // Scene
                    DrawnBalconyView(vm: vm)

                    Spacer().frame(height: 20)

                    // Buttons
                    ControlsView(vm: vm)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }

                // Threat overlays
                ThreatOverlayView(vm: vm)

                // Combo overlay
                if vm.showCombo {
                    ComboView(count: vm.comboCount)
                        .transition(.scale.combined(with: .opacity))
                }

                // Caught overlay
                if case .caught = vm.state {
                    CaughtFlashView(vm: vm)
                }

                // Rain overlay
                if vm.activeThreat == .rain {
                    RainOverlayView()
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - HUD

struct HUDView: View {
    @ObservedObject var vm: GameViewModel
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Text(i < vm.lives ? "❤️" : "🖤").font(.title3)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("SCORE").font(.caption2).foregroundColor(.gray)
                Text("\(vm.score)").font(.title3.weight(.bold)).foregroundColor(.white)
            }
        }
    }
}

// MARK: - Alert Bar

struct AlertBarView: View {
    let level: Double
    var color: Color {
        if level < 0.4 { return .green }
        if level < 0.7 { return .yellow }
        return .red
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text("バレ度").font(.caption2).foregroundColor(.gray)
                Spacer()
                Text("\(Int(level * 100))%").font(.caption2.weight(.medium)).foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(color)
                        .frame(width: geo.size.width * CGFloat(level), height: 8)
                        .animation(.linear(duration: 0.1), value: level)
                }
            }.frame(height: 8)
        }
    }
}

// MARK: - Smoke Gauge

struct SmokeGaugeView: View {
    let progress: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text("🚬 煙草ゲージ").font(.caption2).foregroundColor(.gray)
                Spacer()
                Text("\(Int(progress * 100))%").font(.caption2.weight(.medium)).foregroundColor(.orange)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: geo.size.width * CGFloat(progress), height: 8)
                    .animation(.linear(duration: 0.1), value: progress)
                }
            }.frame(height: 8)
        }
    }
}

// MARK: - Scene

struct SceneView: View {
    @ObservedObject var vm: GameViewModel
    let width: CGFloat
    @State private var puffOpacity: Double = 0
    @State private var puffOffset: CGFloat = 0

    var isHiding: Bool { vm.hideTimeLeft > 0 }
    var manIcon: String { isHiding ? "🙈" : "🧍‍♂️" }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Building back wall — concrete texture
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.22, green: 0.22, blue: 0.28),
                                Color(red: 0.18, green: 0.18, blue: 0.24),
                                Color(red: 0.15, green: 0.15, blue: 0.20)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(height: 200)
                    .overlay(
                        // Wall stain / texture lines
                        VStack(spacing: 0) {
                            ForEach(0..<4) { _ in
                                Rectangle().fill(Color.white.opacity(0.02)).frame(height: 1)
                                Spacer().frame(height: 18)
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                    )
            }

            // Sliding door (wife entrance) — center back
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.18))
                .frame(width: 70, height: 110)
                .overlay(
                    HStack(spacing: 0) {
                        // Glass panes
                        Rectangle().fill(Color(red: 0.08, green: 0.10, blue: 0.20).opacity(0.6))
                            .frame(width: 33)
                            .overlay(
                                Rectangle().stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                            )
                        Rectangle().fill(Color(red: 0.06, green: 0.08, blue: 0.18).opacity(0.6))
                            .frame(width: 33)
                            .overlay(
                                Rectangle().stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                            )
                    }
                    .padding(2)
                )
                .overlay(
                    // Door handle
                    Circle().fill(Color.gray.opacity(0.4)).frame(width: 5, height: 5)
                        .offset(x: -12, y: 10)
                )
                .offset(y: -60)

            // Neighbor windows — left and right sides
            HStack {
                WindowView(
                    showEnemy: vm.activeThreat == .neighborLeft,
                    enemyIcon: "👁️"
                )
                Spacer()
                WindowView(
                    showEnemy: vm.activeThreat == .neighborRight,
                    enemyIcon: "👁️"
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 80)

            // Outdoor unit (室外機) — bottom left
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(red: 0.55, green: 0.55, blue: 0.53))
                    .frame(width: 44, height: 30)
                // Fan grille
                Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 18, height: 18)
                    .offset(x: 6)
                // Vent lines
                VStack(spacing: 3) {
                    ForEach(0..<3) { _ in
                        Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 10, height: 1.5)
                    }
                }
                .offset(x: -12)
            }
            .offset(x: -120, y: -28)

            // Planter (プランター) — bottom right
            ZStack {
                // Pot
                Trapezoid()
                    .fill(Color(red: 0.55, green: 0.30, blue: 0.15))
                    .frame(width: 36, height: 20)
                // Plant
                Text("🌱").font(.system(size: 16)).offset(y: -14)
            }
            .offset(x: 110, y: -28)

            // Clothesline pole (物干し竿) — top area
            Rectangle()
                .fill(Color(red: 0.6, green: 0.6, blue: 0.65))
                .frame(width: 2, height: 50)
                .offset(x: -80, y: -155)
            Rectangle()
                .fill(Color(red: 0.6, green: 0.6, blue: 0.65))
                .frame(width: 2, height: 50)
                .offset(x: 80, y: -155)
            // Pole horizontal
            Rectangle()
                .fill(Color(red: 0.65, green: 0.65, blue: 0.7))
                .frame(width: 160, height: 2)
                .offset(y: -180)
            // Hanging towel
            Text("🧦").font(.system(size: 14)).offset(x: -40, y: -168)
            Text("👕").font(.system(size: 16)).offset(x: 20, y: -166)

            // Wife appears from sliding door
            if vm.activeThreat == .wife {
                Text("🙍‍♀️").font(.system(size: 50))
                    .offset(y: -80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // UFO
            if vm.activeThreat == .ufo {
                VStack(spacing: 0) {
                    Text("🛸").font(.system(size: 50))
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.yellow.opacity(0.4), .clear],
                            startPoint: .top, endPoint: .bottom
                        ))
                        .frame(width: 60, height: 80)
                }
                .offset(y: -60)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Crow flying
            if vm.activeThreat == .crow {
                Text("🐦‍⬛").font(.system(size: 40))
                    .offset(x: 0, y: -100)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    ))
            }

            // Laundry falling
            if vm.activeThreat == .laundry {
                Text("👗").font(.system(size: 40))
                    .offset(x: 30, y: -80)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Concrete floor
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.35, green: 0.35, blue: 0.38),
                            Color(red: 0.30, green: 0.30, blue: 0.33)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 24)

            // Railing — metal balcony railing
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.50, green: 0.50, blue: 0.55),
                            Color(red: 0.40, green: 0.40, blue: 0.45)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 4)
                .offset(y: -44)
            // Top rail
            Rectangle()
                .fill(Color(red: 0.55, green: 0.55, blue: 0.60))
                .frame(height: 6)
                .offset(y: -44)
            // Vertical bars
            HStack(spacing: 16) {
                ForEach(0..<10) { _ in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.55, green: 0.55, blue: 0.58),
                                    Color(red: 0.45, green: 0.45, blue: 0.48)
                                ],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: 44)
                }
            }
            .offset(y: -22)
            // Bottom rail
            Rectangle()
                .fill(Color(red: 0.50, green: 0.50, blue: 0.55))
                .frame(height: 3)
                .offset(y: 0)

            // Man
            ZStack {
                // Smoke puff
                if vm.showPuff {
                    Text("💨").font(.system(size: 24))
                        .offset(x: 25, y: -100)
                        .transition(.opacity.combined(with: .offset(x: 0, y: -20)))
                }
                // Cigarette glow
                if !isHiding {
                    Circle()
                        .fill(Color.orange.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(x: 26, y: -48)
                        .blur(radius: 4)
                }
                Text(manIcon).font(.system(size: 72))
                    .offset(y: isHiding ? 15 : 0)
                    .animation(.spring(response: 0.2), value: isHiding)
            }
            .offset(y: -20)
        }
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.3), value: vm.activeThreat)
    }
}

struct WindowView: View {
    let showEnemy: Bool
    let enemyIcon: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(showEnemy ? Color.yellow.opacity(0.3) : Color(red: 0.1, green: 0.1, blue: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .frame(width: 70, height: 80)
            if showEnemy {
                Text(enemyIcon).font(.system(size: 32))
                    .transition(.scale.combined(with: .opacity))
            } else {
                VStack(spacing: 8) {
                    ForEach(0..<4) { _ in
                        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 2)
                    }
                }.padding(.horizontal, 8)
            }
        }
        .animation(.spring(response: 0.3), value: showEnemy)
    }
}

// MARK: - Threat Warning Overlay

struct ThreatOverlayView: View {
    @ObservedObject var vm: GameViewModel
    @State private var blinkOn = false

    var body: some View {
        VStack {
            if let threat = vm.activeThreat {
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Text(threat.icon).font(.title)
                        Text(threat.warning).font(.headline.weight(.bold))
                            .foregroundColor(.red)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.white.opacity(0.1))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.red)
                                .frame(width: geo.size.width * CGFloat(vm.threatTimeLeft / threat.timeLimit))
                                .animation(.linear(duration: 0.1), value: vm.threatTimeLeft)
                        }
                    }.frame(height: 6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.15))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red.opacity(blinkOn ? 0.8 : 0.2), lineWidth: 2))
                .cornerRadius(10)
                .padding(.horizontal, 24)
                .padding(.top, 120)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            Spacer()
        }
        .onAppear { withAnimation(.easeInOut(duration: 0.4).repeatForever()) { blinkOn = true } }
        .animation(.easeInOut(duration: 0.2), value: vm.activeThreat != nil)
    }
}

// MARK: - Combo View

struct ComboView: View {
    let count: Int
    @State private var scale: CGFloat = 0.3

    var body: some View {
        VStack(spacing: 4) {
            Text("🔥 \(count)x COMBO").font(.system(size: 28, weight: .black))
                .foregroundStyle(
                    LinearGradient(colors: [.yellow, .orange, .red], startPoint: .leading, endPoint: .trailing)
                )
            Text(comboPhrase)
                .font(.caption.weight(.bold))
                .foregroundColor(.yellow.opacity(0.8))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.7))
        .cornerRadius(16)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { scale = 1.0 }
        }
    }

    var comboPhrase: String {
        switch count {
        case 3: return "いい調子！"
        case 4: return "スパスパ！"
        case 5...7: return "チェーンスモーカー！"
        case 8...: return "ニコチンの神！！"
        default: return ""
        }
    }
}

// MARK: - Controls

struct ControlsView: View {
    @ObservedObject var vm: GameViewModel
    var isHiding: Bool { vm.hideTimeLeft > 0 }
    var canSmoke: Bool { vm.state == .playing && vm.activeThreat == nil && !isHiding }

    var body: some View {
        HStack(spacing: 16) {
            // Hide button
            Button(action: { vm.hide() }) {
                VStack(spacing: 4) {
                    Text(isHiding ? "🙈" : "🫣").font(.system(size: 32))
                    if isHiding {
                        Text("隠れ中...\n\(String(format: "%.1f", vm.hideTimeLeft))s")
                            .multilineTextAlignment(.center)
                    } else if vm.hideCooldown > 0 {
                        Text("待機中\n\(String(format: "%.0f", vm.hideCooldown))s")
                            .multilineTextAlignment(.center)
                    } else {
                        Text("隠れる")
                    }
                }
                .font(.subheadline.weight(.bold))
                .foregroundColor(isHiding ? .yellow : vm.canHide ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    isHiding ? Color.yellow.opacity(0.2) :
                    vm.canHide ? Color.white.opacity(0.1) : Color.white.opacity(0.03)
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isHiding ? Color.yellow.opacity(0.6) :
                            vm.canHide ? Color.white.opacity(0.15) : Color.white.opacity(0.05),
                            lineWidth: 1.5
                        )
                )
            }
            .disabled(!vm.canHide)

            // Smoke button
            Button(action: { vm.takePuff() }) {
                VStack(spacing: 4) {
                    Text("🚬").font(.system(size: 32))
                    Text("煙草を吸う")
                }
                .font(.subheadline.weight(.bold))
                .foregroundColor(canSmoke ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(canSmoke ? Color.orange : Color.white.opacity(0.05))
                .cornerRadius(16)
            }
            .disabled(!canSmoke)
        }
    }
}

// MARK: - Caught Flash

struct CaughtFlashView: View {
    @ObservedObject var vm: GameViewModel
    @State private var shake = false

    var body: some View {
        ZStack {
            Color.red.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 12) {
                Text("❌ バレた！").font(.system(size: 36, weight: .black)).foregroundColor(.white)
                Text(vm.caughtText).multilineTextAlignment(.center)
                    .font(.body).foregroundColor(.white.opacity(0.9))
                if vm.lives > 0 {
                    Text("残りライフ: \(String(repeating: "❤️", count: vm.lives))")
                        .font(.subheadline)
                }
            }
            .padding(32)
            .background(Color.black.opacity(0.7))
            .cornerRadius(20)
            .offset(x: shake ? -10 : 10)
            .onAppear { withAnimation(.easeInOut(duration: 0.08).repeatCount(6)) { shake = true } }
        }
        .transition(.opacity)
    }
}

// MARK: - Rain Overlay

struct RainOverlayView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1).ignoresSafeArea()
            ForEach(0..<20) { i in
                RainDrop(delay: Double(i) * 0.15, xPos: CGFloat(i) / 20.0)
            }
        }
        .transition(.opacity)
    }
}

struct RainDrop: View {
    let delay: Double
    let xPos: CGFloat
    @State private var offset: CGFloat = -50

    var body: some View {
        GeometryReader { geo in
            Text("│").font(.system(size: 16)).foregroundColor(.blue.opacity(0.4))
                .position(x: geo.size.width * xPos, y: offset)
                .onAppear {
                    withAnimation(.linear(duration: 0.8).delay(delay).repeatForever(autoreverses: false)) {
                        offset = geo.size.height + 50
                    }
                }
        }
    }
}

// MARK: - Trapezoid Shape

struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset: CGFloat = 4
        path.move(to: CGPoint(x: inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width - inset, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Stars

struct StarsView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<40) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.2...0.8)))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat(i * 37 % Int(geo.size.width)),
                        y: CGFloat(i * 53 % Int(geo.size.height / 2))
                    )
            }
        }.ignoresSafeArea()
    }
}
