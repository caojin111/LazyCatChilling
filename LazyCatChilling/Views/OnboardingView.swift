import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppStateManager
    @State private var currentPage = 0
    
    // 工作类型选项
    private let workTypeOptions = ["商务销售", "技术开发（主要电脑工作）", "设计创意（需要专注）", "体力劳动"]
    @State private var selectedWorkType = 0
    @State private var customWorkType = ""
    
    // 久坐时长
    @State private var sittingHours: Double = 8.0
    
    // 休息习惯选项
    private let restFrequencyOptions = ["不固定", "1小时左右", "2小时左右", "半天一次", "几乎不休息"]
    @State private var selectedRestFrequency = 0
    
    // 健身习惯选项
    private let fitnessHabitOptions = ["每天都有", "每周3-5次", "偶尔健身", "几乎不健身"]
    @State private var selectedFitnessHabit = 0
    
    // 推荐设置值
    @State private var recommendedWorkDuration: Double = 45.0
    @State private var recommendedRestDuration: Double = 10.0
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            VStack {
                // 顶部进度指示器（除了欢迎页）
                if currentPage > 0 {
                    progressIndicator
                        .padding(.top)
                }
                
                // 页面内容区域
                Spacer()
                
                pageContent
                
                Spacer()
                
                // 底部按钮区域
                buttonArea
                    .padding(.bottom, 50)
            }
            .padding()
        }
    }
    
    // MARK: - UI组件
    
    private var backgroundColor: Color {
        Color(#colorLiteral(red: 0.2901960784, green: 0.5647058824, blue: 0.8862745098, alpha: 1)) // #4A90E2
    }
    
    private var progressIndicator: some View {
        HStack {
            ForEach(1...5, id: \.self) { page in
                Circle()
                    .fill(currentPage >= page ? Color.white : Color.white.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
    }
    
    @ViewBuilder
    private var pageContent: some View {
        switch currentPage {
        case 0:
            welcomePage
        case 1:
            workTypePage
        case 2:
            sittingDurationPage
        case 3:
            restFrequencyPage
        case 4:
            fitnessHabitPage
        case 5:
            recommendedSettingsPage
        default:
            EmptyView()
        }
    }
    
    private var welcomePage: some View {
        VStack(spacing: 30) {
            // 临时猫咪标志
            Image(systemName: "cat.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.white)
                .padding()
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )
            
            Text("欢迎使用懒猫摸鱼")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Text("我们将帮助您科学安排工作和休息时间，\n提醒您适时舒展身体、减少久坐危害。")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
        }
    }
    
    private var workTypePage: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("您的工作类型是？")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            ForEach(0..<workTypeOptions.count, id: \.self) { index in
                Button(action: {
                    selectedWorkType = index
                }) {
                    HStack {
                        Text(workTypeOptions[index])
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if selectedWorkType == index {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedWorkType == index ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                    )
                }
            }
        }
    }
    
    private var sittingDurationPage: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("您每天大约坐多久？")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            VStack {
                HStack {
                    Text("\(String(format: "%.1f", sittingHours))小时")
                        .font(.title2)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Slider(value: $sittingHours, in: 2...12, step: 0.5)
                    .accentColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
            )
            
            VStack(alignment: .leading, spacing: 10) {
                Text("小贴士:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("研究表明，持续久坐可能导致颈椎病、腰椎病等职业病，建议每45-60分钟起身活动一次。")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    private var restFrequencyPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("您目前多久休息一次？")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            ForEach(0..<restFrequencyOptions.count, id: \.self) { index in
                Button(action: {
                    selectedRestFrequency = index
                }) {
                    HStack {
                        Text(restFrequencyOptions[index])
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if selectedRestFrequency == index {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedRestFrequency == index ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                    )
                }
            }
        }
    }
    
    private var fitnessHabitPage: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("您有固定健身习惯吗？")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            ForEach(0..<fitnessHabitOptions.count, id: \.self) { index in
                Button(action: {
                    selectedFitnessHabit = index
                }) {
                    HStack {
                        Text(fitnessHabitOptions[index])
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        if selectedFitnessHabit == index {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedFitnessHabit == index ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("小贴士:")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("适当的运动习惯对于缓解工作压力和预防健康问题非常有帮助。即使没有固定健身习惯，工作间隙的伸展活动也很重要。")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    private var recommendedSettingsPage: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("您的推荐设置")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("根据您提供的信息，我们为您推荐的设置如下：")
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                // 工作时长
                VStack(alignment: .leading) {
                    HStack {
                        Text("工作时长:")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(recommendedWorkDuration))分钟")
                            .foregroundColor(.white)
                    }
                    
                    Slider(value: $recommendedWorkDuration, in: 15...120, step: 5)
                        .accentColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                )
                
                // 休息时长
                VStack(alignment: .leading) {
                    HStack {
                        Text("休息时长:")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(recommendedRestDuration))分钟")
                            .foregroundColor(.white)
                    }
                    
                    Slider(value: $recommendedRestDuration, in: 5...30, step: 1)
                        .accentColor(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                )
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("您可以随时在设置中修改这些配置。点击下方完成设置按钮开始使用应用。")
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
    
    private var buttonArea: some View {
        HStack {
            // 如果不是第一页，显示上一步按钮
            if currentPage > 0 {
                Button(action: {
                    currentPage -= 1
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("上一步")
                    }
                    .padding()
                    .frame(minWidth: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            Button(action: {
                if currentPage == 5 {
                    // 最后一页，完成设置
                    completeOnboarding()
                } else {
                    // 前往下一页
                    // 如果是第4页，在进入第5页时计算推荐设置
                    if currentPage == 4 {
                        calculateRecommendedSettings()
                    }
                    currentPage += 1
                }
            }) {
                HStack {
                    Text(currentPage == 0 ? "开始" : (currentPage == 5 ? "完成设置" : "下一步"))
                    
                    if currentPage != 5 {
                        Image(systemName: "arrow.right")
                    }
                }
                .padding()
                .frame(minWidth: 100)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
                .foregroundColor(backgroundColor)
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func calculateRecommendedSettings() {
        // 根据用户选择计算推荐设置
        let workTypeValue = workTypeOptions[selectedWorkType]
        let restFrequency = restFrequencyOptions[selectedRestFrequency]
        let fitnessHabit = fitnessHabitOptions[selectedFitnessHabit]
        
        // 设置到appState
        appState.workType = workTypeValue
        appState.sittingHours = sittingHours
        appState.restFrequency = restFrequency
        appState.fitnessHabit = fitnessHabit
        
        // 计算推荐时间
        appState.calculateRecommendedTimes()
        
        // 更新推荐设置页面的值
        recommendedWorkDuration = Double(appState.workDuration)
        recommendedRestDuration = Double(appState.restDuration)
    }
    
    private func completeOnboarding() {
        // 保存用户设置的值
        appState.workDuration = Int(recommendedWorkDuration)
        appState.restDuration = Int(recommendedRestDuration)
        
        // 完成引导流程
        appState.completeOnboarding()
        
        // 如果背景音乐已启用，开始播放工作音乐
        if appState.backgroundMusicEnabled {
            BackgroundMusicManager.shared.playBackgroundMusic(name: "work_music")
            BackgroundMusicManager.shared.setVolume(appState.musicVolume)
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppStateManager())
    }
}
