import Foundation

struct TimeFormatter {
    static func formatSeconds(_ totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    static func formatHoursMinutes(_ totalSeconds: TimeInterval) -> String {
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d小时%d分钟", hours, minutes)
        } else {
            return String(format: "%d分钟", minutes)
        }
    }
    
    static func formatTimeIntervalToHours(_ interval: TimeInterval) -> String {
        let hours = interval / 3600
        return String(format: "%.1f小时", hours)
    }
}
