import SwiftUI
import Combine
import AudioToolbox
import AVFoundation

// MARK: - Enums

enum GameState: Equatable {
    case title, playing, hiding, caught(ThreatType), stageClear, gameOver
    case stats, tutorial
}

enum Difficulty: String, CaseIterable {
    case easy = "イージー"
    case normal = "ノーマル"
    case hard = "ハード"

    var lives: Int {
        switch self { case .easy: return 5; case .normal: return 3; case .hard: return 1 }
    }
    var threatSpeedMultiplier: Double {
        switch self { case .easy: return 0.7; case .normal: return 1.0; case .hard: return 1.4 }
    }
    var puffAmount: Double {
        switch self { case .easy: return 0.06; case .normal: return 0.04; case .hard: return 0.03 }
    }
    var hideTime: Double {
        switch self { case .easy: return 4.0; case .normal: return 3.0; case .hard: return 2.0 }
    }
    var icon: String {
        switch self { case .easy: return "😌"; case .normal: return "😐"; case .hard: return "😈" }
    }
}

enum ThreatType: String, CaseIterable, Identifiable, Equatable {
    case neighborLeft, neighborRight, wife, crow, laundry, ufo, rain
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .neighborLeft: return "👁️"
        case .neighborRight: return "👁️"
        case .wife: return "🙍‍♀️"
        case .crow: return "🐦‍⬛"
        case .laundry: return "👗"
        case .ufo: return "🛸"
        case .rain: return "🌧️"
        }
    }

    var warning: String {
        switch self {
        case .neighborLeft: return "左の隣人が見てる！"
        case .neighborRight: return "右の隣人が見てる！"
        case .wife: return "妻が来た！！逃げろ！！"
        case .crow: return "カラスが接近中！"
        case .laundry: return "洗濯物が飛んできた！"
        case .ufo: return "謎の光が...UFO!?"
        case .rain: return "豪雨！煙草が濡れる！"
        }
    }

    var caughtMessage: String {
        switch self {
        case .neighborLeft: return "隣人に見られた！\n「はあ？煙草？非常識ですよ！」"
        case .neighborRight: return "隣人に見られた！\n「臭いんですけど！」"
        case .wife: return "妻にバレた！！\n「あなた！また吸ってる！！禁煙って言ったでしょ！！」"
        case .crow: return "カラスに煙草を奪われた！\n「カアッ」←勝利のポーズ"
        case .laundry: return "洗濯物が直撃！\n「なんで火の粉がついてんのよ！」"
        case .ufo: return "UFOにスキャンされた！\n「ピー...タバコ成分検出...拿捕します」"
        case .rain: return "ずぶ濡れ...\n煙草が湿って消えた"
        }
    }

    var timeLimit: Double {
        switch self {
        case .wife: return 1.8
        case .laundry: return 1.3
        case .neighborLeft, .neighborRight: return 2.5
        case .crow: return 2.0
        case .ufo: return 3.5
        case .rain: return 2.5
        }
    }

    var alertSpeed: Double {
        switch self {
        case .wife: return 0.55
        case .neighborLeft, .neighborRight: return 0.22
        case .crow: return 0.20
        case .laundry: return 0.35
        case .ufo: return 0.13
        case .rain: return 0.12
        }
    }

    var penetratesHide: Bool { self == .ufo && Bool.random() }

    var weight: Int {
        switch self {
        case .neighborLeft: return 22
        case .neighborRight: return 22
        case .wife: return 14
        case .crow: return 14
        case .laundry: return 12
        case .rain: return 10
        case .ufo: return 6
        }
    }
}

// MARK: - Haptics & Sound

struct FeedbackEngine {
    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()

    static func puff() {
        impactLight.impactOccurred()
    }

    static func hide() {
        impactMedium.impactOccurred()
    }

    static func threatAppear() {
        notification.notificationOccurred(.warning)
    }

    static func caught() {
        notification.notificationOccurred(.error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            impactHeavy.impactOccurred()
        }
    }

    static func stageClear() {
        notification.notificationOccurred(.success)
    }

    static func gameOver() {
        impactHeavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impactHeavy.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            impactHeavy.impactOccurred()
        }
    }

    static func buttonTap() {
        impactLight.impactOccurred(intensity: 0.5)
    }
}

// MARK: - High Score

struct ScoreManager {
    private static let ud = UserDefaults.standard
    private static let highScoreKey = "BalconySmoker_HighScore"
    private static let totalCigsKey = "BalconySmoker_TotalCigs"
    private static let gamesPlayedKey = "BalconySmoker_GamesPlayed"
    private static let bestComboKey = "BalconySmoker_BestCombo"
    private static let totalDodgesKey = "BalconySmoker_TotalDodges"
    private static let totalCaughtKey = "BalconySmoker_TotalCaught"
    private static let bestLevelKey = "BalconySmoker_BestLevel"
    private static let totalPuffsKey = "BalconySmoker_TotalPuffs"
    private static let hardClearsKey = "BalconySmoker_HardClears"

    static var highScore: Int {
        get { ud.integer(forKey: highScoreKey) }
        set { ud.set(newValue, forKey: highScoreKey) }
    }
    static var totalCigarettes: Int {
        get { ud.integer(forKey: totalCigsKey) }
        set { ud.set(newValue, forKey: totalCigsKey) }
    }
    static var gamesPlayed: Int {
        get { ud.integer(forKey: gamesPlayedKey) }
        set { ud.set(newValue, forKey: gamesPlayedKey) }
    }
    static var bestCombo: Int {
        get { ud.integer(forKey: bestComboKey) }
        set { ud.set(newValue, forKey: bestComboKey) }
    }
    static var totalDodges: Int {
        get { ud.integer(forKey: totalDodgesKey) }
        set { ud.set(newValue, forKey: totalDodgesKey) }
    }
    static var totalCaught: Int {
        get { ud.integer(forKey: totalCaughtKey) }
        set { ud.set(newValue, forKey: totalCaughtKey) }
    }
    static var bestLevel: Int {
        get { ud.integer(forKey: bestLevelKey) }
        set { ud.set(newValue, forKey: bestLevelKey) }
    }
    static var totalPuffs: Int {
        get { ud.integer(forKey: totalPuffsKey) }
        set { ud.set(newValue, forKey: totalPuffsKey) }
    }
    static var hardClears: Int {
        get { ud.integer(forKey: hardClearsKey) }
        set { ud.set(newValue, forKey: hardClearsKey) }
    }

    static func submitScore(_ score: Int, cigarettes: Int, combo: Int, level: Int, dodges: Int, caught: Int, puffs: Int, hardClear: Bool) {
        if score > highScore { highScore = score }
        if combo > bestCombo { bestCombo = combo }
        if level > bestLevel { bestLevel = level }
        totalCigarettes += cigarettes
        totalDodges += dodges
        totalCaught += caught
        totalPuffs += puffs
        gamesPlayed += 1
        if hardClear { hardClears += 1 }
    }
}

// MARK: - ViewModel

@MainActor
class GameViewModel: ObservableObject {
    @Published var state: GameState = .title
    @Published var lives = 3
    @Published var score = 0
    @Published var cigarettesSmoked = 0
    @Published var smokeGauge: Double = 0
    @Published var alertLevel: Double = 0
    @Published var activeThreat: ThreatType? = nil
    @Published var threatTimeLeft: Double = 0
    @Published var hideTimeLeft: Double = 0
    @Published var showPuff = false
    @Published var caughtText = ""
    @Published var comboCount = 0
    @Published var showCombo = false
    @Published var hideCooldown: Double = 0
    @Published var difficulty: Difficulty = .normal

    var highScore: Int { ScoreManager.highScore }

    private(set) var level = 1
    private var nextThreatIn: Double = 4.0
    private var gameTimer: Timer?
    private let tick: Double = 0.1
    private var lastThreatDodged = false
    private var consecutivePuffs = 0
    private var sessionBestCombo = 0
    private var sessionDodges = 0
    private var sessionCaught = 0
    private var sessionPuffs = 0

    func startGame() {
        lives = difficulty.lives; score = 0; cigarettesSmoked = 0
        smokeGauge = 0; alertLevel = 0
        activeThreat = nil; hideTimeLeft = 0; level = 1
        nextThreatIn = 4.0; comboCount = 0; hideCooldown = 0
        consecutivePuffs = 0; lastThreatDodged = false
        sessionBestCombo = 0; sessionDodges = 0; sessionCaught = 0; sessionPuffs = 0
        state = .playing
        FeedbackEngine.buttonTap()
        startTimer()
    }

    func restart() { startGame() }

    private func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: tick, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.gameTick() }
        }
    }

    func stopTimer() { gameTimer?.invalidate(); gameTimer = nil }

    private func gameTick() {
        guard state == .playing || state == .hiding else { return }

        // Hide countdown
        if hideTimeLeft > 0 {
            hideTimeLeft = max(0, hideTimeLeft - tick)
            if hideTimeLeft == 0 { state = .playing }
        }

        // Hide cooldown
        if hideCooldown > 0 {
            hideCooldown = max(0, hideCooldown - tick)
        }

        // Alert recovery
        if activeThreat == nil && alertLevel > 0 {
            alertLevel = max(0, alertLevel - 0.08 * tick)
        }

        // Threat logic
        if let threat = activeThreat {
            threatTimeLeft -= tick
            let hiding = hideTimeLeft > 0
            let safe = hiding && !threat.penetratesHide

            if !safe {
                alertLevel += threat.alertSpeed * tick
                if alertLevel >= 1.0 { caught(by: threat); return }
            }

            if threatTimeLeft <= 0 {
                // Threat dodged — flat bonus only
                activeThreat = nil
                score += safe ? 15 : 10
                sessionDodges += 1
                nextThreatIn = Double.random(in: threatInterval())
            }
        } else {
            nextThreatIn -= tick
            if nextThreatIn <= 0 { spawnThreat() }
        }
    }

    private func threatInterval() -> ClosedRange<Double> {
        let lo = max(1.5, 5.0 - Double(level) * 0.35)
        let hi = max(3.0, 9.0 - Double(level) * 0.45)
        return lo...hi
    }

    private func spawnThreat() {
        let total = ThreatType.allCases.map(\.weight).reduce(0, +)
        var r = Int.random(in: 0..<total)
        var selected = ThreatType.neighborLeft
        for t in ThreatType.allCases { r -= t.weight; if r < 0 { selected = t; break } }
        activeThreat = selected
        threatTimeLeft = selected.timeLimit * max(0.5, 1.0 - Double(level - 1) * 0.06) / difficulty.threatSpeedMultiplier
        nextThreatIn = Double.random(in: threatInterval())
        comboCount = 0
        FeedbackEngine.threatAppear()
    }

    private func caught(by threat: ThreatType) {
        activeThreat = nil; alertLevel = 0; lives -= 1
        caughtText = threat.caughtMessage
        sessionCaught += 1
        if comboCount > sessionBestCombo { sessionBestCombo = comboCount }
        comboCount = 0
        state = .caught(threat)
        FeedbackEngine.caught()
        stopTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { [weak self] in
            guard let self else { return }
            if self.lives <= 0 {
                self.state = .gameOver
                FeedbackEngine.gameOver()
                ScoreManager.submitScore(self.score, cigarettes: self.cigarettesSmoked, combo: self.sessionBestCombo, level: self.level, dodges: self.sessionDodges, caught: self.sessionCaught, puffs: self.sessionPuffs, hardClear: self.difficulty == .hard && self.cigarettesSmoked > 0)
            } else {
                self.smokeGauge = max(0, self.smokeGauge - 0.2)
                self.state = .playing
                self.nextThreatIn = 3.0
                self.startTimer()
            }
        }
    }

    func takePuff() {
        guard state == .playing, activeThreat == nil, hideTimeLeft == 0 else { return }
        comboCount += 1
        sessionPuffs += 1
        let puffAmount = difficulty.puffAmount + (comboCount > 5 ? 0.01 : 0)
        let comboMultiplier = min(comboCount, 5)
        smokeGauge = min(1.0, smokeGauge + puffAmount)
        score += 5 * comboMultiplier
        showPuff = true
        FeedbackEngine.puff()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { self.showPuff = false }

        if comboCount >= 3 {
            showCombo = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.showCombo = false }
        }

        // Smoking raises alert slightly
        alertLevel = min(0.95, alertLevel + 0.008)

        if smokeGauge >= 1.0 { stageClear() }
    }

    func hide() {
        guard (state == .playing || state == .hiding), hideCooldown <= 0 else { return }
        hideTimeLeft = difficulty.hideTime
        hideCooldown = 5.0
        state = .hiding
        FeedbackEngine.hide()
    }

    var canHide: Bool { (state == .playing || state == .hiding) && hideCooldown <= 0 }

    private func stageClear() {
        cigarettesSmoked += 1
        score += 200 + level * 50
        level = min(level + 1, 12)
        activeThreat = nil
        state = .stageClear
        FeedbackEngine.stageClear()
        stopTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self else { return }
            self.smokeGauge = 0
            self.alertLevel = 0
            self.comboCount = 0
            self.hideCooldown = 0
            self.state = .playing
            self.nextThreatIn = 3.0
            self.startTimer()
        }
    }
}
