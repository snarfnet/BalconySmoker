import SwiftUI

// MARK: - iPad Layout Scale

/// Returns a scale factor for adapting fixed-pixel layouts to iPad.
/// iPhone: 1.0, iPad: ~1.6–1.8 depending on screen width.
enum LayoutScale {
    static var factor: CGFloat {
        let width = UIScreen.main.bounds.width
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad mini ~744, iPad 10th ~820, iPad Pro 12.9 ~1024
            return min(width / 430, 2.0) // 430 is iPhone 15 Pro Max width
        }
        return 1.0
    }
}

// MARK: - Ojisan Character (SwiftUI drawn)

struct OjisanView: View {
    let isHiding: Bool
    let isSmokingPuff: Bool
    private var s: CGFloat { LayoutScale.factor }

    var body: some View {
        ZStack {
            // Smoke puff
            if isSmokingPuff {
                SmokePuffView()
                    .offset(x: 50 * s, y: -60 * s)
                    .transition(.opacity.combined(with: .offset(y: -10)))
            }

            // Photo character
            Image("OjisanChar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: isHiding ? 80 * s : 160 * s)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
                .offset(y: isHiding ? 40 * s : 0)
                .animation(.spring(response: 0.25), value: isHiding)

            // Hiding overlay
            if isHiding {
                Text("🙈")
                    .font(.system(size: 40 * s))
                    .offset(y: 20 * s)
            }
        }
    }
}

// MARK: - Cigarette

struct CigaretteView: View {
    @State private var glowPulse = false

    var body: some View {
        ZStack(alignment: .leading) {
            // Filter
            RoundedRectangle(cornerRadius: 1)
                .fill(Color(red: 0.85, green: 0.70, blue: 0.45))
                .frame(width: 8, height: 4)

            // Paper
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.white.opacity(0.9))
                .frame(width: 14, height: 3.5)
                .offset(x: 8)

            // Burning tip
            Circle()
                .fill(Color.orange)
                .frame(width: 5, height: 5)
                .blur(radius: glowPulse ? 3 : 1.5)
                .offset(x: 21)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                        glowPulse = true
                    }
                }
        }
    }
}

// MARK: - Smoke Puff

struct SmokePuffView: View {
    @State private var drift: CGFloat = 0
    @State private var fade: Double = 1

    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.white.opacity(0.25 * fade))
                    .frame(width: CGFloat(8 + i * 4), height: CGFloat(8 + i * 4))
                    .offset(
                        x: CGFloat(i * 5) + drift * CGFloat(i + 1) * 0.3,
                        y: -drift * CGFloat(i + 1) * 0.5
                    )
                    .blur(radius: CGFloat(2 + i))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                drift = 15
                fade = 0
            }
        }
    }
}

// MARK: - Night Sky with Moon

struct NightSkyView: View {
    private var s: CGFloat { LayoutScale.factor }
    var body: some View {
        ZStack {
            // Moon
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.92, blue: 0.80))
                    .frame(width: 40 * s, height: 40 * s)
                    .blur(radius: 1)
                // Moon glow
                Circle()
                    .fill(Color.yellow.opacity(0.08))
                    .frame(width: 80 * s, height: 80 * s)
                    .blur(radius: 20)
                // Craters
                Circle()
                    .fill(Color(red: 0.88, green: 0.85, blue: 0.72))
                    .frame(width: 6 * s, height: 6 * s)
                    .offset(x: -6 * s, y: -4 * s)
                Circle()
                    .fill(Color(red: 0.88, green: 0.85, blue: 0.72))
                    .frame(width: 4 * s, height: 4 * s)
                    .offset(x: 8 * s, y: 6 * s)
                Circle()
                    .fill(Color(red: 0.88, green: 0.85, blue: 0.72))
                    .frame(width: 5 * s, height: 5 * s)
                    .offset(x: 3 * s, y: -8 * s)
            }
            .offset(x: 120 * s, y: -60 * s)
        }
    }
}

// MARK: - Drawn Balcony Scene

struct DrawnBalconyView: View {
    @ObservedObject var vm: GameViewModel
    var isHiding: Bool { vm.hideTimeLeft > 0 }
    private var s: CGFloat { LayoutScale.factor }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Photo background
            Image("BalconyBG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 280 * s)
                .clipped()

            // Night overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.02, green: 0.02, blue: 0.10).opacity(0.82),
                            Color(red: 0.04, green: 0.04, blue: 0.15).opacity(0.75),
                            Color(red: 0.03, green: 0.03, blue: 0.12).opacity(0.85)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )

            // Ashtray on railing
            AshtrayView(butts: vm.cigarettesSmoked)
                .scaleEffect(s)
                .offset(x: 50 * s, y: -47 * s)

            // Beer can
            BeerCanView()
                .scaleEffect(s)
                .offset(x: -80 * s, y: -30 * s)

            // UFO
            if vm.activeThreat == .ufo {
                DrawnUFOView()
                    .scaleEffect(s)
                    .offset(y: -120 * s)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Crow
            if vm.activeThreat == .crow {
                DrawnCrowView()
                    .scaleEffect(s)
                    .offset(x: 0, y: -140 * s)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    ))
            }

            // Laundry falling
            if vm.activeThreat == .laundry {
                Text("👕").font(.system(size: 36 * s))
                    .offset(x: 30 * s, y: -100 * s)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Neighbor eyes peeking
            if vm.activeThreat == .neighborLeft {
                NeighborPeekView()
                    .scaleEffect(s)
                    .offset(x: -140 * s, y: -80 * s)
                    .transition(.scale.combined(with: .opacity))
            }
            if vm.activeThreat == .neighborRight {
                NeighborPeekView()
                    .scaleEffect(s)
                    .offset(x: 140 * s, y: -80 * s)
                    .transition(.scale.combined(with: .opacity))
            }

            // Wife from sliding door
            if vm.activeThreat == .wife {
                WifeView()
                    .offset(x: 60 * s, y: -75 * s)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            // Ojisan
            OjisanView(
                isHiding: isHiding,
                isSmokingPuff: vm.showPuff
            )
            .offset(y: -25 * s)
        }
        .frame(height: 280 * s)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.3), value: vm.activeThreat)
    }
}

// MARK: - Neighbor Peek (eyes in darkness)

struct NeighborPeekView: View {
    @State private var blink = false
    private var s: CGFloat { LayoutScale.factor }
    var body: some View {
        HStack(spacing: 6 * s) {
            Circle().fill(Color.white).frame(width: 8 * s, height: 8 * s)
                .overlay(Circle().fill(Color.black).frame(width: 4 * s, height: 4 * s))
            Circle().fill(Color.white).frame(width: 8 * s, height: 8 * s)
                .overlay(Circle().fill(Color.black).frame(width: 4 * s, height: 4 * s))
        }
        .scaleEffect(blink ? 1.0 : 0.9)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) { blink = true }
        }
    }
}

// MARK: - Sliding Door

struct SlidingDoorView: View {
    let wifeAppearing: Bool
    private var s: CGFloat { LayoutScale.factor }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.10, green: 0.10, blue: 0.16))
                .frame(width: 74 * s, height: 115 * s)
            HStack(spacing: 1) {
                // Left pane
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.08, green: 0.12, blue: 0.25).opacity(0.7),
                                Color(red: 0.05, green: 0.08, blue: 0.18).opacity(0.5)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 34 * s)
                    .overlay(Rectangle().stroke(Color.white.opacity(0.06), lineWidth: 0.5))
                // Right pane
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.06, green: 0.10, blue: 0.22).opacity(0.7),
                                Color(red: 0.04, green: 0.06, blue: 0.15).opacity(0.5)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 34 * s)
                    .overlay(Rectangle().stroke(Color.white.opacity(0.06), lineWidth: 0.5))
            }
            .frame(height: 109 * s)
            .padding(.horizontal, 2)

            // Light from inside when wife appears
            if wifeAppearing {
                Rectangle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 70 * s, height: 111 * s)
            }

            // Handle
            Circle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 5 * s, height: 5 * s)
                .offset(x: -14 * s, y: 12 * s)
        }
    }
}

// MARK: - Neighbor Window

enum WindowSide { case left, right }

struct NeighborWindowView: View {
    let isLooking: Bool
    let side: WindowSide
    private var s: CGFloat { LayoutScale.factor }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(isLooking ? Color.yellow.opacity(0.25) : Color(red: 0.10, green: 0.10, blue: 0.18))
                .frame(width: 60 * s, height: 72 * s)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

            if isLooking {
                // Angry neighbor silhouette
                VStack(spacing: 2 * s) {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 20 * s, height: 20 * s)
                    // Eyes
                    HStack(spacing: 6 * s) {
                        Circle().fill(Color.white).frame(width: 5 * s, height: 5 * s)
                        Circle().fill(Color.white).frame(width: 5 * s, height: 5 * s)
                    }
                    .offset(y: -14 * s)
                }
            } else {
                // Curtain / blind lines
                VStack(spacing: 6 * s) {
                    ForEach(0..<5) { _ in
                        Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1.5)
                    }
                }
                .padding(.horizontal, 6)
            }
        }
        .animation(.spring(response: 0.3), value: isLooking)
    }
}

// MARK: - Clothesline

struct ClotheslineView: View {
    var body: some View {
        ZStack {
            // Poles
            Rectangle().fill(Color(red: 0.6, green: 0.6, blue: 0.65)).frame(width: 2, height: 45).offset(x: -75)
            Rectangle().fill(Color(red: 0.6, green: 0.6, blue: 0.65)).frame(width: 2, height: 45).offset(x: 75)
            // Horizontal bar
            Rectangle().fill(Color(red: 0.65, green: 0.65, blue: 0.7)).frame(width: 150, height: 2).offset(y: -22)
            // Hanging items
            HangingTowelView().offset(x: -40, y: -8)
            HangingShirtView().offset(x: 20, y: -6)
        }
    }
}

struct HangingTowelView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white.opacity(0.15)).frame(width: 1, height: 10)
            RoundedRectangle(cornerRadius: 1)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.6, green: 0.75, blue: 0.85), Color(red: 0.5, green: 0.65, blue: 0.78)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 18, height: 22)
        }
    }
}

struct HangingShirtView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white.opacity(0.15)).frame(width: 1, height: 8)
            // T-shirt shape
            ZStack {
                // Body
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.85, green: 0.85, blue: 0.9))
                    .frame(width: 20, height: 20)
                // Sleeves
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.9))
                        .frame(width: 8, height: 10)
                        .rotationEffect(.degrees(-15))
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color(red: 0.85, green: 0.85, blue: 0.9))
                        .frame(width: 8, height: 10)
                        .rotationEffect(.degrees(15))
                }
                .offset(y: -4)
            }
        }
    }
}

// MARK: - Outdoor Unit

struct OutdoorUnitView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.60, green: 0.60, blue: 0.58), Color(red: 0.50, green: 0.50, blue: 0.48)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 44, height: 30)
            // Fan grille
            Circle().stroke(Color.gray.opacity(0.4), lineWidth: 1.5).frame(width: 18, height: 18).offset(x: 6)
            // Cross in fan
            Path { path in
                path.move(to: CGPoint(x: 0, y: 9)); path.addLine(to: CGPoint(x: 18, y: 9))
                path.move(to: CGPoint(x: 9, y: 0)); path.addLine(to: CGPoint(x: 9, y: 18))
            }
            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
            .frame(width: 18, height: 18)
            .offset(x: 6)
            // Vents
            VStack(spacing: 3) {
                ForEach(0..<3) { _ in
                    Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 10, height: 1.5)
                }
            }
            .offset(x: -12)
        }
    }
}

// MARK: - Planter

struct PlanterView: View {
    var body: some View {
        ZStack {
            Trapezoid()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.60, green: 0.33, blue: 0.18), Color(red: 0.50, green: 0.28, blue: 0.14)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 32, height: 18)
            // Soil
            Ellipse()
                .fill(Color(red: 0.30, green: 0.22, blue: 0.15))
                .frame(width: 26, height: 6)
                .offset(y: -6)
            // Little plant
            Path { path in
                path.move(to: CGPoint(x: 0, y: 10))
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            .stroke(Color(red: 0.3, green: 0.6, blue: 0.2), lineWidth: 1.5)
            .frame(width: 1, height: 10)
            .offset(y: -14)
            // Leaves
            Ellipse()
                .fill(Color(red: 0.3, green: 0.65, blue: 0.25))
                .frame(width: 8, height: 5)
                .rotationEffect(.degrees(-30))
                .offset(x: -4, y: -20)
            Ellipse()
                .fill(Color(red: 0.35, green: 0.7, blue: 0.3))
                .frame(width: 8, height: 5)
                .rotationEffect(.degrees(25))
                .offset(x: 4, y: -22)
        }
    }
}

// MARK: - Ashtray

struct AshtrayView: View {
    let butts: Int

    var body: some View {
        ZStack {
            // Tray
            Ellipse()
                .fill(Color(red: 0.4, green: 0.4, blue: 0.42))
                .frame(width: 22, height: 8)
            Ellipse()
                .fill(Color(red: 0.3, green: 0.3, blue: 0.32))
                .frame(width: 18, height: 5)
                .offset(y: 1)
            // Butts
            if butts > 0 {
                ForEach(0..<min(butts, 4), id: \.self) { i in
                    RoundedRectangle(cornerRadius: 0.5)
                        .fill(Color(red: 0.85, green: 0.80, blue: 0.70))
                        .frame(width: 6, height: 2)
                        .rotationEffect(.degrees(Double(i) * 40 - 20))
                        .offset(x: CGFloat(i * 3 - 4), y: -1)
                }
            }
        }
    }
}

// MARK: - Beer Can

struct BeerCanView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.75, green: 0.65, blue: 0.2), Color(red: 0.65, green: 0.55, blue: 0.15)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 12, height: 20)
            // Top
            Ellipse()
                .fill(Color(red: 0.7, green: 0.7, blue: 0.72))
                .frame(width: 10, height: 4)
                .offset(y: -9)
        }
    }
}

// MARK: - Balcony Railing

struct BalconyRailingView: View {
    private var s: CGFloat { LayoutScale.factor }
    var body: some View {
        ZStack(alignment: .bottom) {
            // Top rail
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.58, green: 0.58, blue: 0.62), Color(red: 0.50, green: 0.50, blue: 0.54)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(height: 5 * s)
                .offset(y: -44 * s)

            // Vertical bars
            HStack(spacing: 14 * s) {
                ForEach(0..<12) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.55, green: 0.55, blue: 0.58), Color(red: 0.45, green: 0.45, blue: 0.48)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(width: 3 * s, height: 44 * s)
                }
            }
            .offset(y: -22 * s)

            // Bottom rail
            Rectangle()
                .fill(Color(red: 0.50, green: 0.50, blue: 0.55))
                .frame(height: 3 * s)
        }
    }
}

// MARK: - Wife

struct WifeView: View {
    private var s: CGFloat { LayoutScale.factor }
    var body: some View {
        Image("WifeChar")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 140 * s)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .red.opacity(0.4), radius: 10, y: 2)
    }
}

// MARK: - Drawn UFO

struct DrawnUFOView: View {
    @State private var hover = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Dome
                Ellipse()
                    .fill(Color.cyan.opacity(0.4))
                    .frame(width: 30, height: 20)
                    .offset(y: -5)
                // Body
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.5)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: 18)
                // Lights
                HStack(spacing: 8) {
                    ForEach(0..<4) { _ in
                        Circle().fill(Color.yellow).frame(width: 4, height: 4)
                    }
                }
            }
            .offset(y: hover ? -5 : 5)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever()) { hover = true }
            }

            // Beam
            Path { path in
                path.move(to: CGPoint(x: 15, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 80))
                path.addLine(to: CGPoint(x: 50, y: 80))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.3), Color.yellow.opacity(0.0)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .frame(width: 50, height: 80)
        }
    }
}

// MARK: - Drawn Crow

struct DrawnCrowView: View {
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                .frame(width: 30, height: 20)
            // Head
            Circle()
                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                .frame(width: 14, height: 14)
                .offset(x: 14, y: -6)
            // Beak
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 10, y: 3))
                path.addLine(to: CGPoint(x: 0, y: 6))
                path.closeSubpath()
            }
            .fill(Color(red: 0.3, green: 0.25, blue: 0.1))
            .frame(width: 10, height: 6)
            .offset(x: 24, y: -6)
            // Eye
            Circle().fill(Color.white).frame(width: 4, height: 4).offset(x: 16, y: -7)
            Circle().fill(Color.black).frame(width: 2, height: 2).offset(x: 16, y: -7)
            // Wings
            Ellipse()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
                .frame(width: 22, height: 10)
                .rotationEffect(.degrees(-20))
                .offset(x: -5, y: -8)
        }
    }
}
