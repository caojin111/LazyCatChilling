import Foundation
import UIKit

class GIFManager {
    static let shared = GIFManager()
    
    // 添加内存缓存
    private var gifCache: [String: (data: Data, images: [UIImage], duration: TimeInterval)] = [:]
    
    private init() {}
    
    /// 检查GIF资源是否存在
    func checkGIFExists(named: String) -> Bool {
        return Bundle.main.url(forResource: named, withExtension: "gif") != nil
    }
    
    /// 获取GIF文件的大小(KB)
    func getGIFFileSize(named: String) -> Double? {
        guard let url = Bundle.main.url(forResource: named, withExtension: "gif"),
              let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else {
            return nil
        }
        
        let fileSize = attributes[.size] as? NSNumber
        return fileSize?.doubleValue ?? 0 / 1024.0 // 转换为KB
    }
    
    /// 预加载GIF动画并保存到缓存
    func preloadGIFs(names: [String]) {
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "gif") else {
                print("预加载失败: 找不到GIF资源 \(name).gif")
                continue
            }
            
            do {
                let gifData = try Data(contentsOf: url)
                
                // 处理GIF并缓存
                if let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
                    let frameCount = CGImageSourceGetCount(source)
                    var images = [UIImage]()
                    var duration: TimeInterval = 0
                    
                    for i in 0..<frameCount {
                        if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                            images.append(UIImage(cgImage: cgImage))
                            
                            // 获取这一帧的持续时间
                            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                               let gifProperties = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
                               let delayTime = gifProperties[kCGImagePropertyGIFDelayTime as String] as? Double {
                                duration += delayTime
                            }
                        }
                    }
                    
                    // 确保总时长有效
                    if duration <= 0 {
                        duration = Double(frameCount) * 0.1 // 默认每帧0.1秒
                    }
                    
                    // 保存到缓存
                    self.gifCache[name] = (gifData, images, duration)
                    print("成功预加载并缓存GIF: \(name).gif")
                }
            } catch {
                print("预加载GIF失败: \(name).gif, 错误: \(error.localizedDescription)")
            }
        }
    }
    
    /// 加载GIF数据，优先从缓存加载
    func loadGIFData(named: String) -> Data? {
        // 如果缓存中有，直接返回
        if let cachedData = gifCache[named]?.data {
            return cachedData
        }
        
        // 否则从文件加载
        guard let url = Bundle.main.url(forResource: named, withExtension: "gif") else {
            return nil
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            print("加载GIF数据失败: \(named).gif, 错误: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 获取预处理的GIF图像和持续时间
    func getCachedGIF(named: String) -> (images: [UIImage], duration: TimeInterval)? {
        return gifCache[named] != nil ? (gifCache[named]!.images, gifCache[named]!.duration) : nil
    }
    
    /// 清除缓存
    func clearCache() {
        gifCache.removeAll()
    }
}
