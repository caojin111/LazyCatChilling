import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppStateManager
    
    // 工作时长和休息时长的临时值，用于滑动条
    @State private var workDuration: Double = 45
    @State private var restDuration: Double = 10
    
    // 暗黑模式选项
    private let darkModeOptions = ["跟随系统", "开启", "关闭"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("计时设置")) {
                    VStack {
                        HStack {
                            Text("工作时长: \(Int(workDuration))分钟")
                            Spacer()
                        }
                        
                        Slider(value: $workDuration, in: 15...120, step: 5)
                            .onChange(of: workDuration) { _ in
                                appState.workDuration = Int(workDuration)
                            }
                    }
                    
                    VStack {
                        HStack {
                            Text("休息时长: \(Int(restDuration))分钟")
                            Spacer()
                        }
                        
                        Slider(value: $restDuration, in: 5...30, step: 1)
                            .onChange(of: restDuration) { _ in
                                appState.restDuration = Int(restDuration)
                            }
                    }
                }
                
                Section(header: Text("提醒设置")) {
                    Toggle("声音提醒", isOn: $appState.soundEnabled)
                    Toggle("震动提醒", isOn: $appState.vibrationEnabled)
                    Toggle("背景音乐", isOn: $appState.backgroundMusicEnabled)
                        .onChange(of: appState.backgroundMusicEnabled) { _ in
                            appState.toggleBackgroundMusic()
                        }
                    
                    if appState.backgroundMusicEnabled {
                        VStack {
                            HStack {
                                Text("音乐音量")
                                Spacer()
                                Text("\(Int(appState.musicVolume * 100))%")
                            }
                            
                            Slider(value: $appState.musicVolume, in: 0...1, step: 0.01)
                                .onChange(of: appState.musicVolume) { newValue in
                                    appState.setMusicVolume(newValue)
                                }
                        }
                    }
                }
                
                Section(header: Text("外观")) {
                    Picker("暗黑模式", selection: $appState.darkModePreference) {
                        ForEach(0..<darkModeOptions.count, id: \.self) { index in
                            Text(darkModeOptions[index])
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        resetToDefaults()
                    }) {
                        Text("恢复默认设置")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("关于")) {
                    HStack {
                        Text("应用版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("懒猫开发团队")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("完成") {
                saveSettings()
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            // 初始化滑动条值
            workDuration = Double(appState.workDuration)
            restDuration = Double(appState.restDuration)
        }
    }
    
    private func saveSettings() {
        appState.workDuration = Int(workDuration)
        appState.restDuration = Int(restDuration)
        appState.saveSettings()
    }
    
    private func resetToDefaults() {
        let defaults = UserSettings.defaultSettings
        appState.workDuration = defaults.workDuration
        appState.restDuration = defaults.restDuration
        appState.soundEnabled = defaults.soundEnabled
        appState.vibrationEnabled = defaults.vibrationEnabled
        appState.backgroundMusicEnabled = defaults.backgroundMusicEnabled
        appState.darkModePreference = defaults.darkModePreference
        
        // 更新滑动条值
        workDuration = Double(defaults.workDuration)
        restDuration = Double(defaults.restDuration)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppStateManager())
    }
}
