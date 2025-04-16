import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var isActive = false
    @State private var opacity = 0.0
    @State private var loadingStatus = "正在加载中..."
    @State private var loadingProgress = 0.0
    @State private var startTime = Date()
    
    var body: some View {
        ZStack {
            if isActive {
                if appState.isFirstLaunch {
                    OnboardingView()
                } else {
                    MainView()
                }
            } else {
                Color.white
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("🐱")
                            .font(.system(size: 80))
                        
                        Text("LazyCat-Chilling")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    Text("Made with LazyCat")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            // 记录开始时间
            startTime = Date()
            
            withAnimation(.easeIn(duration: 0.3)) {
                self.opacity = 1.0
            }
            
            // 在显示Splash页面的同时预加载GIF资源
            Task {
                await preloadGIFResources()
                
                // 计算已经过去的时间
                let elapsedTime = Date().timeIntervalSince(startTime)
                
                // 如果不足2秒，则等待剩余时间
                let remainingTime = 2.0 - elapsedTime
                if remainingTime > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
                }
                
                // 完成预加载后显示主界面
                withAnimation(.easeOut(duration: 0.3)) {
                    self.isActive = true
                }
            }
        }
    }
    
    // 预加载GIF资源
    private func preloadGIFResources() async {
        let gifNames = ["cat_working", "cat_resting"]
        
        for (index, name) in gifNames.enumerated() {
            // 更新加载状态
            await MainActor.run {
                loadingStatus = "正在加载资源: \(name)"
                loadingProgress = Double((index * 50) + 10)
            }
            
            // 检查GIF是否存在
            if GIFManager.shared.checkGIFExists(named: name) {
                if let fileSize = GIFManager.shared.getGIFFileSize(named: name) {
                    await MainActor.run {
                        loadingStatus = "加载\(name): \(Int(fileSize))KB"
                    }
                }
                
                // 预加载单个GIF
                await withCheckedContinuation { continuation in
                    DispatchQueue.global(qos: .userInitiated).async {
                        GIFManager.shared.preloadGIFs(names: [name])
                        
                        // 更新进度
                        DispatchQueue.main.async {
                            self.loadingProgress = Double((index + 1) * 50)
                            continuation.resume()
                        }
                    }
                }
            } else {
                // GIF不存在
                await MainActor.run {
                    loadingStatus = "未找到GIF资源: \(name)"
                    loadingProgress = Double((index + 1) * 50)
                }
            }
        }
        
        // 完成加载
        await MainActor.run {
            loadingStatus = "加载完成"
            loadingProgress = 100
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(AppStateManager())
    }
} 