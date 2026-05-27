import SwiftUI

struct ContentView: View {
    @State private var showAd = true
    @State private var countdown = 5
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            GameRootView()
            if showAd {
                AdOverlayView(countdown: countdown) {
                    showAd = false
                    timer?.invalidate()
                }
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if countdown > 0 { countdown -= 1 }
            }
        }
    }
}

struct AdOverlayView: View {
    let countdown: Int
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                Text("🚬").font(.system(size: 80))
                Text("バルコニースモーカー").font(.system(size: 28, weight: .black)).foregroundColor(.white)
                Text("監視の目を逃れながら\nひっそりと一服を楽しもう").multilineTextAlignment(.center).foregroundColor(.gray).font(.body)
                Text("広 告").font(.caption).foregroundColor(.gray.opacity(0.5))
                Spacer()
                Spacer()
            }
            .padding()

            Group {
                if countdown > 0 {
                    Text("\(countdown)")
                        .font(.headline).foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.gray.opacity(0.6))
                        .clipShape(Circle())
                } else {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.headline).foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.gray.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.top, 56)
            .padding(.trailing, 16)
        }
    }
}
