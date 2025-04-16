import Foundation
import AVFoundation

class BackgroundMusicManager {
    static let shared = BackgroundMusicManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    
    // 用于标识当前播放的音乐
    private var currentMusic: String?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("设置音频会话失败: \(error.localizedDescription)")
        }
    }
    
    // 播放背景音乐
    func playBackgroundMusic(name: String, fileType: String = "mp3", loop: Bool = true) {
        // 如果已经在播放相同的音乐，则不重新加载
        if isPlaying && currentMusic == name {
            return
        }
        
        // 停止当前音乐
        stopBackgroundMusic()
        
        // 加载并播放新音乐
        if let path = Bundle.main.path(forResource: name, ofType: fileType) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.delegate = nil
                
                // 设置循环播放
                if loop {
                    audioPlayer?.numberOfLoops = -1 // 无限循环
                }
                
                audioPlayer?.volume = 0.5 // 设置适中音量
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
                isPlaying = true
                currentMusic = name
                
                print("开始播放背景音乐: \(name).\(fileType)")
            } catch {
                print("播放背景音乐失败: \(error.localizedDescription)")
            }
        } else {
            print("未找到音频文件: \(name).\(fileType)")
        }
    }
    
    // 暂停背景音乐
    func pauseBackgroundMusic() {
        guard isPlaying, let player = audioPlayer else { return }
        
        player.pause()
        isPlaying = false
    }
    
    // 恢复播放
    func resumeBackgroundMusic() {
        guard !isPlaying, let player = audioPlayer else { return }
        
        player.play()
        isPlaying = true
    }
    
    // 停止并释放资源
    func stopBackgroundMusic() {
        guard let player = audioPlayer else { return }
        
        player.stop()
        audioPlayer = nil
        isPlaying = false
        currentMusic = nil
    }
    
    // 设置音量
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    // 当前是否正在播放
    func isBackgroundMusicPlaying() -> Bool {
        return isPlaying
    }
} 