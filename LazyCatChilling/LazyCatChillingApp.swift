import SwiftUI
import UIKit

@main
struct LazyCatChillingApp: App {
    @StateObject private var appState = AppStateManager()
    
    init() {
        // 设置全局图像缓存大小限制
        URLCache.shared.memoryCapacity = 10_485_760 // 10 MB
        
        // 检查GIF资源是否存在
        let gifNames = ["cat_working", "cat_resting"]
        var missingGifs: [String] = []
        
        for name in gifNames {
            if !GIFManager.shared.checkGIFExists(named: name) {
                missingGifs.append(name)
            }
        }
        
        if !missingGifs.isEmpty {
            print("⚠️ 警告: 找不到以下GIF资源:")
            for name in missingGifs {
                print("  - \(name).gif")
            }
            print("请将GIF文件添加到项目中，参考 Resources/Animations/README.txt")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(appState)
        }
    }
}
