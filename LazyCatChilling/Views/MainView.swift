import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: appState.currentState.baseState)
            
            VStack {
                // 顶部状态栏
                HStack {
                    workTimeStats
                    Spacer()
                    settingsButton
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // 中央区域
                VStack(spacing: 20) {
                    catAnimationView
                        .frame(height: UIScreen.main.bounds.height * 0.4)
                        .padding(.horizontal)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: appState.currentState.baseState)
                    
                    countdownTimer
                        .transition(.scale)
                        .animation(.easeInOut(duration: 0.3), value: appState.remainingTime)
                    
                    statusText
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: appState.currentState)
                }
                
                Spacer()
                
                // 底部按钮区域
                HStack(spacing: 20) {
                    pauseResumeButton
                    
                    if canSkip {
                        skipButton
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            if !appState.timerActive {
                appState.startTimer()
            }
            checkAndPlayBackgroundMusic()
        }
        // 添加双击暂停/继续手势
        .gesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    togglePauseResume()
                }
        )
        // 添加下拉重置手势
        .gesture(
            LongPressGesture(minimumDuration: 1.5)
                .onEnded { _ in
                    resetTimer()
                }
        )
    }
    
    // MARK: - 界面组件
    
    private var backgroundColor: Color {
        let baseState = appState.currentState.baseState
        switch baseState {
        case .working:
            return Color(#colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)) // #4A90E2
        case .resting:
            return Color(#colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 1)) // #F5A623
        default:
            return Color.gray
        }
    }
    
    private var workTimeStats: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("今日: \(TimeFormatter.formatTimeIntervalToHours(appState.todayWorkTime))")
                    .font(.footnote)
                    .foregroundColor(.white)
                
                Text("本周: \(TimeFormatter.formatTimeIntervalToHours(appState.weeklyWorkTime))")
                    .font(.footnote)
                    .foregroundColor(.white)
            }
        }
    }
    
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gearshape.fill")
                .font(.title2)
                .foregroundColor(.white)
        }
    }
    
    private var catAnimationView: some View {
        GeometryReader { geometry in
            ZStack {
                // 使用GIF动画或备用视图
                Group {
                    let baseState = appState.currentState.baseState
                    if case .working = baseState {
                        gifOrFallbackView(name: "cat_working", size: geometry.size)
                            .transition(.opacity)
                    } else if case .resting = baseState {
                        gifOrFallbackView(name: "cat_resting", size: geometry.size)
                            .transition(.opacity)
                    } else {
                        gifOrFallbackView(name: "cat_working", size: geometry.size)
                            .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: appState.currentState.baseState)
        }
    }
    
    @ViewBuilder
    private func gifOrFallbackView(name: String, size: CGSize) -> some View {
        // 计算可用尺寸，保留一些边距以防止贴边
        let horizontalPadding: CGFloat = 16 // 水平内边距
        let verticalPadding: CGFloat = 16   // 垂直内边距
        let availableWidth = size.width - (horizontalPadding * 2)
        let availableHeight = size.height - (verticalPadding * 2)
        let dimension = min(availableWidth, availableHeight)
        
        if GIFManager.shared.checkGIFExists(named: name) {
            // 先放置背景圆角矩形
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .frame(width: dimension, height: dimension)
                .overlay(
                    // 在内部放置GIF视图
                    GIFView(name: name, contentMode: .scaleAspectFill)
                        .frame(width: dimension - 2, height: dimension - 2) // 稍微小一点以避免边缘问题
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding([.horizontal, .vertical], 16) // 使用固定内边距确保定位准确
        } else {
            // 如果GIF不存在，显示备用视图
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .frame(width: dimension, height: dimension)
                .overlay(
                    Group {
                        if name.contains("working") {
                            workingCatView
                        } else {
                            restingCatView
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding([.horizontal, .vertical], 16)
        }
    }
    
    private var workingCatView: some View {
        Image(systemName: "person.fill.viewfinder")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .padding(40)
    }
    
    private var restingCatView: some View {
        Image(systemName: "figure.walk")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .padding(40)
    }
    
    private var countdownTimer: some View {
        Text(TimeFormatter.formatSeconds(appState.remainingTime))
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }
    
    private var statusText: some View {
        Text(appState.currentState.isPaused ? 
             "已暂停" : getStatusText())
            .font(.title3)
            .foregroundColor(.white)
            .padding(.vertical, 5)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.2))
            )
    }
    
    private func getStatusText() -> String {
        let baseState = appState.currentState.baseState
        
        switch baseState {
        case .working:
            return "专注工作中"
        case .resting:
            return "休息活动中"
        case .onboarding:
            return "欢迎使用"
        case .paused:
            return "已暂停" // 这种情况不应该发生，因为我们已经在外层处理了isPaused
        }
    }
    
    private var pauseResumeButton: some View {
        Button(action: {
            togglePauseResume()
        }) {
            HStack {
                Image(systemName: appState.currentState.isPaused ? "play.fill" : "pause.fill")
                Text(appState.currentState.isPaused ? "继续" : "暂停")
            }
            .frame(width: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.2))
            )
            .foregroundColor(.white)
        }
    }
    
    private var skipButton: some View {
        Button(action: {
            appState.skipCurrentPhase()
        }) {
            HStack {
                Image(systemName: "forward.fill")
                Text("跳过")
            }
            .frame(width: 100)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.2))
            )
            .foregroundColor(.white)
        }
    }
    
    // MARK: - 辅助属性和方法
    
    private var canSkip: Bool {
        // 仅当剩余时间超过总时间的一半时，允许跳过
        let baseState = appState.currentState.baseState
        
        let totalTime: TimeInterval
        if case .working = baseState {
            totalTime = TimeInterval(appState.workDuration * 60)
        } else if case .resting = baseState {
            totalTime = TimeInterval(appState.restDuration * 60)
        } else {
            return false
        }
        
        let halfTime = totalTime / 2.0
        
        return appState.remainingTime > halfTime && !appState.currentState.isPaused
    }
    
    private func togglePauseResume() {
        if appState.currentState.isPaused {
            appState.resumeTimer()
        } else {
            appState.pauseTimer()
        }
    }
    
    // 检查并播放正确的背景音乐
    private func checkAndPlayBackgroundMusic() {
        if appState.backgroundMusicEnabled {
            let baseState = appState.currentState.baseState
            
            if case .working = baseState {
                // 检查音乐是否已经在播放，避免重复播放
                if !BackgroundMusicManager.shared.isBackgroundMusicPlaying() {
                    BackgroundMusicManager.shared.playBackgroundMusic(name: "work_music")
                    BackgroundMusicManager.shared.setVolume(appState.musicVolume)
                }
            } else if case .resting = baseState {
                // 检查音乐是否已经在播放，避免重复播放
                if !BackgroundMusicManager.shared.isBackgroundMusicPlaying() {
                    BackgroundMusicManager.shared.playBackgroundMusic(name: "rest_music")
                    BackgroundMusicManager.shared.setVolume(appState.musicVolume)
                }
            }
        }
    }
    
    private func resetTimer() {
        appState.resetTimer()
        appState.startTimer()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject({
                let manager = AppStateManager()
                manager.currentState = .working
                return manager
            }())
            .previewDisplayName("工作模式")
        
        MainView()
            .environmentObject({
                let manager = AppStateManager()
                manager.currentState = .resting
                return manager
            }())
            .previewDisplayName("休息模式")
    }
}
