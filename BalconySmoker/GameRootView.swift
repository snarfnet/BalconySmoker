import SwiftUI

struct GameRootView: View {
    @StateObject var vm = GameViewModel()

    var body: some View {
        ZStack {
            // Night sky gradient
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.18),
                         Color(red: 0.08, green: 0.08, blue: 0.25),
                         Color(red: 0.05, green: 0.05, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            switch vm.state {
            case .title:
                TitleView(vm: vm)
            case .playing, .hiding, .caught(_):
                GamePlayView(vm: vm)
            case .stageClear:
                StageClearView(vm: vm)
            case .gameOver:
                GameOverView(vm: vm)
            case .stats:
                StatsView { vm.state = .title }
            case .tutorial:
                TutorialView { vm.state = .title }
            }
        }
    }
}
