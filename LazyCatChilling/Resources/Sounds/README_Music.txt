如何添加背景音乐文件：

1. 准备两个音乐文件：
   - work_music.mp3：工作时播放的背景音乐
   - rest_music.mp3：休息时播放的背景音乐

2. 将音乐文件放入该目录(Resources/Sounds/)

3. 在Xcode中，选择"Add Files to 'LazyCatChilling'..."将这些文件添加到项目中
   - 确保选择"Copy items if needed"选项
   - 选择"Create groups"选项
   - 确保Target Membership中勾选了"LazyCatChilling"

音乐文件建议：
- 工作音乐：轻松、舒缓但有节奏感的音乐，如轻音乐、lo-fi音乐
- 休息音乐：活泼、轻快的音乐，提醒用户起身活动

音频格式：
- 推荐使用MP3格式，体积小、兼容性好
- 也支持WAV、M4A等格式，但需要在代码中修改fileType参数

音量控制：
- 默认音量设置为50%
- 用户可以在设置中调整音量或完全关闭背景音乐 