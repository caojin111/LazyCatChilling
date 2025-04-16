import Foundation
import SwiftUI
import UserNotifications
import AudioToolbox // 添加AudioToolbox以使用AudioServices

// 使用indirect关键字标记递归枚举
indirect enum AppState: Equatable {
    case onboarding
    case working
    case resting
    case paused(previousState: AppState)
    
    var isPaused: Bool {
        if case .paused = self {
            return true
        }
        return false
    }
    
    var baseState: AppState {
        if case .paused(let previousState) = self {
            return previousState
        }
        return self
    }
    
    static func == (lhs: AppState, rhs: AppState) -> Bool {
        switch (lhs, rhs) {
        case (.onboarding, .onboarding),
             (.working, .working),
             (.resting, .resting):
            return true
        case (.paused(let lhsPrevious), .paused(let rhsPrevious)):
            return lhsPrevious == rhsPrevious
        default:
            return false
        }
    }
}

class AppStateManager: ObservableObject {
    @Published var currentState: AppState = .onboarding
    @Published var remainingTime: TimeInterval = 0
    @Published var timerActive = false
    
    @Published var workDuration: Int = 45 // 默认45分钟
    @Published var restDuration: Int = 10 // 默认10分钟
    
    @Published var isFirstLaunch: Bool = true
    
    @Published var todayWorkTime: TimeInterval = 0
    @Published var weeklyWorkTime: TimeInterval = 0
    
    @Published var workType: String = ""
    @Published var sittingHours: Double = 8.0
    @Published var restFrequency: String = ""
    @Published var fitnessHabit: String = ""
    
    @Published var soundEnabled: Bool = true
    @Published var vibrationEnabled: Bool = true
    @Published var backgroundMusicEnabled: Bool = true
    @Published var musicVolume: Float = 0.5
    @Published var darkModePreference: Int = 0 // 0-跟随系统
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTimeRemaining: TimeInterval = 0
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
        
        // 检查是否是首次启动
        isFirstLaunch = userDefaults.bool(forKey: "hasCompletedOnboarding") == false
        
        // 如果不是首次启动，设置初始状态为工作状态
        if !isFirstLaunch {
            currentState = .working
            remainingTime = TimeInterval(workDuration * 60)
            
            // 如果背景音乐已启用，开始播放工作音乐
            if backgroundMusicEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    BackgroundMusicManager.shared.playBackgroundMusic(name: "work_music")
                    BackgroundMusicManager.shared.setVolume(self.musicVolume)
                }
            }
        }
        
        // 请求通知权限
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("通知权限请求失败: \(error.localizedDescription)")
            }
        }
    }
    
    func startTimer() {
        if timer == nil {
            startTime = Date()
            timerActive = true
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
        }
    }
    
    func pauseTimer() {
        let baseState = currentState.baseState
        if case .onboarding = baseState {
            return
        }
        
        pausedTimeRemaining = remainingTime
        currentState = .paused(previousState: baseState)
        timerActive = false
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        if case .paused(let previousState) = currentState {
            currentState = previousState
            remainingTime = pausedTimeRemaining
            startTimer()
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        timerActive = false
        
        let baseState = currentState.baseState
        switch baseState {
        case .working:
            remainingTime = TimeInterval(workDuration * 60)
        case .resting:
            remainingTime = TimeInterval(restDuration * 60)
        default:
            break
        }
    }
    
    func skipCurrentPhase() {
        timer?.invalidate()
        timer = nil
        timerActive = false
        
        let baseState = currentState.baseState
        switch baseState {
        case .working:
            transitionToRestState()
        case .resting:
            transitionToWorkState()
        default:
            break
        }
    }
    
    private func updateTimer() {
        guard let startTime = startTime else { return }
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        var newRemainingTime: TimeInterval = 0
        
        switch currentState {
        case .working:
            newRemainingTime = max(TimeInterval(workDuration * 60) - elapsedTime, 0)
            // 累计工作时间
            todayWorkTime += 0.1
        case .resting:
            newRemainingTime = max(TimeInterval(restDuration * 60) - elapsedTime, 0)
        default:
            return
        }
        
        remainingTime = newRemainingTime
        
        // 检查计时器是否结束
        if newRemainingTime <= 0 {
            timer?.invalidate()
            timer = nil
            timerActive = false
            
            // 切换状态
            switch currentState {
            case .working:
                transitionToRestState()
            case .resting:
                transitionToWorkState()
            default:
                break
            }
        }
        
        // 距离结束30秒时播放提示声音
        if newRemainingTime <= 30 && newRemainingTime > 29.9 {
            playAlertSound()
        }
    }
    
    private func transitionToRestState() {
        currentState = .resting
        remainingTime = TimeInterval(restDuration * 60)
        
        // 发送通知
        sendNotification(
            title: "是时候休息一下了！",
            body: "站起来活动\(restDuration)分钟吧～",
            isWorkComplete: true
        )
        
        // 振动和声音提醒
        if vibrationEnabled {
            performWorkCompleteVibration()
        }
        
        if soundEnabled {
            playWorkCompleteSound()
        }
        
        // 如果启用了背景音乐，播放休息时的音乐
        if backgroundMusicEnabled {
            BackgroundMusicManager.shared.playBackgroundMusic(name: "rest_music")
            BackgroundMusicManager.shared.setVolume(musicVolume)
        } else {
            BackgroundMusicManager.shared.stopBackgroundMusic()
        }
        
        // 重新开始计时器
        startTime = Date()
        startTimer()
    }
    
    private func transitionToWorkState() {
        currentState = .working
        remainingTime = TimeInterval(workDuration * 60)
        
        // 发送通知
        sendNotification(
            title: "休息结束",
            body: "回到工作状态吧！",
            isWorkComplete: false
        )
        
        // 振动和声音提醒
        if vibrationEnabled {
            performRestCompleteVibration()
        }
        
        if soundEnabled {
            playRestCompleteSound()
        }
        
        // 如果启用了背景音乐，播放工作时的音乐
        if backgroundMusicEnabled {
            BackgroundMusicManager.shared.playBackgroundMusic(name: "work_music")
            BackgroundMusicManager.shared.setVolume(musicVolume)
        } else {
            BackgroundMusicManager.shared.stopBackgroundMusic()
        }
        
        // 重新开始计时器
        startTime = Date()
        startTimer()
    }
    
    func completeOnboarding() {
        currentState = .working
        remainingTime = TimeInterval(workDuration * 60)
        isFirstLaunch = false
        userDefaults.set(true, forKey: "hasCompletedOnboarding")
        saveSettings()
        
        // 如果启用了背景音乐，播放工作时的音乐
        if backgroundMusicEnabled {
            BackgroundMusicManager.shared.playBackgroundMusic(name: "work_music")
            BackgroundMusicManager.shared.setVolume(musicVolume)
        }
    }
    
    // 根据用户问卷计算推荐时间
    func calculateRecommendedTimes() {
        if workType == "商务销售" && sittingHours > 8 && restFrequency == "几乎不休息" {
            workDuration = 45
            restDuration = 10
        } else if workType == "技术开发（主要电脑工作）" && sittingHours > 6 {
            workDuration = 50
            restDuration = 8
        } else if workType == "设计创意（需要专注）" && restFrequency == "1小时左右" {
            workDuration = 60
            restDuration = 15
        } else if workType == "体力劳动" {
            workDuration = 60
            restDuration = 15
        } else if fitnessHabit == "每天都有" {
            workDuration = 55
            restDuration = 10
        } else if fitnessHabit == "几乎不健身" {
            workDuration = 40
            restDuration = 12
        } else {
            // 默认值
            workDuration = 50
            restDuration = 10
        }
    }
    
    // MARK: - 通知和提醒方法
    
    private func sendNotification(title: String, body: String, isWorkComplete: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        if isWorkComplete {
            // 为工作完成通知添加"再休息5分钟"按钮
            let extendAction = UNNotificationAction(
                identifier: "EXTEND_REST",
                title: "再休息5分钟",
                options: .foreground
            )
            
            let category = UNNotificationCategory(
                identifier: "WORK_COMPLETE",
                actions: [extendAction],
                intentIdentifiers: [],
                options: []
            )
            
            UNUserNotificationCenter.current().setNotificationCategories([category])
            content.categoryIdentifier = "WORK_COMPLETE"
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知发送失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func performWorkCompleteVibration() {
        // 三短一长震动
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        
        // 三短
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            generator.notificationOccurred(.success)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generator.notificationOccurred(.success)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            generator.notificationOccurred(.success)
        }
        
        // 一长
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            generator.notificationOccurred(.warning)
        }
    }
    
    private func performRestCompleteVibration() {
        // 两短震动
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            generator.notificationOccurred(.success)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generator.notificationOccurred(.success)
        }
    }
    
    private func playWorkCompleteSound() {
        // 临时使用系统声音，实际应用中应该使用自定义声音
        AudioServicesPlaySystemSound(1005)
    }
    
    private func playRestCompleteSound() {
        // 临时使用系统声音，实际应用中应该使用自定义声音
        AudioServicesPlaySystemSound(1009)
    }
    
    private func playAlertSound() {
        // 临时使用系统声音
        AudioServicesPlaySystemSound(1013)
    }
    
    // MARK: - 背景音乐控制
    
    func toggleBackgroundMusic() {
        backgroundMusicEnabled = !backgroundMusicEnabled
        
        if backgroundMusicEnabled {
            // 根据当前状态播放对应音乐
            let musicName = currentState.baseState == .working ? "work_music" : "rest_music"
            BackgroundMusicManager.shared.playBackgroundMusic(name: musicName)
            BackgroundMusicManager.shared.setVolume(musicVolume)
        } else {
            BackgroundMusicManager.shared.stopBackgroundMusic()
        }
        
        saveSettings()
    }
    
    func setMusicVolume(_ volume: Float) {
        musicVolume = volume
        BackgroundMusicManager.shared.setVolume(volume)
        saveSettings()
    }
    
    // MARK: - 设置保存和加载
    
    func saveSettings() {
        userDefaults.set(workDuration, forKey: "workDuration")
        userDefaults.set(restDuration, forKey: "restDuration")
        userDefaults.set(soundEnabled, forKey: "soundEnabled")
        userDefaults.set(vibrationEnabled, forKey: "vibrationEnabled")
        userDefaults.set(backgroundMusicEnabled, forKey: "backgroundMusicEnabled")
        userDefaults.set(musicVolume, forKey: "musicVolume")
        userDefaults.set(darkModePreference, forKey: "darkModePreference")
        
        // 保存问卷数据
        userDefaults.set(workType, forKey: "workType")
        userDefaults.set(sittingHours, forKey: "sittingHours")
        userDefaults.set(restFrequency, forKey: "restFrequency")
        userDefaults.set(fitnessHabit, forKey: "fitnessHabit")
        
        // 保存工作时间统计
        userDefaults.set(todayWorkTime, forKey: "todayWorkTime")
        userDefaults.set(weeklyWorkTime, forKey: "weeklyWorkTime")
    }
    
    func loadSettings() {
        workDuration = userDefaults.integer(forKey: "workDuration")
        if workDuration == 0 { workDuration = 45 } // 默认值
        
        restDuration = userDefaults.integer(forKey: "restDuration")
        if restDuration == 0 { restDuration = 10 } // 默认值
        
        soundEnabled = userDefaults.bool(forKey: "soundEnabled")
        if !userDefaults.contains(key: "soundEnabled") { soundEnabled = true }
        
        vibrationEnabled = userDefaults.bool(forKey: "vibrationEnabled")
        if !userDefaults.contains(key: "vibrationEnabled") { vibrationEnabled = true }
        
        backgroundMusicEnabled = userDefaults.bool(forKey: "backgroundMusicEnabled")
        if !userDefaults.contains(key: "backgroundMusicEnabled") { backgroundMusicEnabled = true }
        
        musicVolume = userDefaults.float(forKey: "musicVolume")
        if musicVolume == 0 { musicVolume = 0.5 } // 默认值
        
        darkModePreference = userDefaults.integer(forKey: "darkModePreference")
        
        // 加载问卷数据
        workType = userDefaults.string(forKey: "workType") ?? ""
        sittingHours = userDefaults.double(forKey: "sittingHours")
        if sittingHours == 0 { sittingHours = 8.0 }
        
        restFrequency = userDefaults.string(forKey: "restFrequency") ?? ""
        fitnessHabit = userDefaults.string(forKey: "fitnessHabit") ?? ""
        
        // 加载工作时间统计
        todayWorkTime = userDefaults.double(forKey: "todayWorkTime")
        weeklyWorkTime = userDefaults.double(forKey: "weeklyWorkTime")
    }
}

// MARK: - UserDefaults 扩展
extension UserDefaults {
    func contains(key: String) -> Bool {
        return object(forKey: key) != nil
    }
}
