import Foundation

struct UserSettings: Codable {
    var workDuration: Int // 分钟
    var restDuration: Int // 分钟
    var soundEnabled: Bool
    var vibrationEnabled: Bool
    var backgroundMusicEnabled: Bool
    var darkModePreference: Int // 0-跟随系统，1-开启，2-关闭
    
    static var defaultSettings: UserSettings {
        return UserSettings(
            workDuration: 45,
            restDuration: 10,
            soundEnabled: true,
            vibrationEnabled: true,
            backgroundMusicEnabled: true,
            darkModePreference: 0
        )
    }
}

struct WorkSession: Codable {
    var id: UUID
    var date: Date
    var plannedWorkDuration: Int // 分钟
    var actualWorkDuration: Int // 分钟
    var restCount: Int
    var totalRestDuration: Int // 分钟
    
    init(plannedWorkDuration: Int, actualWorkDuration: Int, restCount: Int, totalRestDuration: Int) {
        self.id = UUID()
        self.date = Date()
        self.plannedWorkDuration = plannedWorkDuration
        self.actualWorkDuration = actualWorkDuration
        self.restCount = restCount
        self.totalRestDuration = totalRestDuration
    }
}
