import SwiftUI
import UIKit

struct GIFView: UIViewRepresentable {
    private let name: String
    private let contentMode: UIView.ContentMode
    
    init(name: String, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.name = name
        self.contentMode = contentMode
    }
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        
        // 添加布局约束以保持比例
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        return imageView
    }
    
    func updateUIView(_ imageView: UIImageView, context: Context) {
        // 确保正确设置contentMode
        imageView.contentMode = contentMode
        
        // 首先尝试从缓存加载
        if let cachedGif = GIFManager.shared.getCachedGIF(named: name) {
            DispatchQueue.main.async {
                imageView.animationImages = cachedGif.images
                imageView.animationDuration = cachedGif.duration
                imageView.animationRepeatCount = 0 // 无限循环
                imageView.startAnimating()
            }
            return
        }
        
        // 如果缓存中没有，在后台线程加载GIF数据。
        DispatchQueue.global(qos: .userInitiated).async {
            if let gifData = GIFManager.shared.loadGIFData(named: name),
               let source = CGImageSourceCreateWithData(gifData as CFData, nil) {
                
                let frameCount = CGImageSourceGetCount(source)
                if frameCount <= 1 {
                    // 如果GIF只有一帧，或者不是GIF，直接加载静态图像
                    if let image = UIImage(data: gifData) {
                        DispatchQueue.main.async {
                            imageView.image = image
                        }
                    }
                    return
                }
                
                var images = [UIImage]()
                var duration: TimeInterval = 0
                
                // 提取GIF的所有帧和时间
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
                
                DispatchQueue.main.async {
                    imageView.animationImages = images
                    imageView.animationDuration = duration
                    imageView.animationRepeatCount = 0 // 无限循环
                    imageView.startAnimating()
                }
            } else {
                // 加载备用图像
                DispatchQueue.main.async {
                    imageView.image = UIImage(systemName: 
                        name.contains("working") ? "person.fill.viewfinder" : "figure.walk")
                    imageView.tintColor = .white
                }
            }
        }
    }
    
    static func dismantleUIView(_ uiView: UIImageView, coordinator: ()) {
        uiView.stopAnimating()
        uiView.animationImages = nil
    }
}

// 用于在预览中显示静态图片的替代组件
struct StaticImageFallback: View {
    let name: String
    
    var body: some View {
        Image(systemName: name.contains("working") ? "person.fill.viewfinder" : "figure.walk")
            .resizable()
            .scaledToFit()
            .foregroundColor(.white)
    }
}
