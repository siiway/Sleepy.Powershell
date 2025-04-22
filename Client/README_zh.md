# Sleepy PowerShell 客户端

一个基于 PowerShell 的 Sleepy API 客户端，在后台运行并定期发送"在线"状态，将前台窗口标题作为应用程序名称。当脚本关闭时，会自动发送"离线"状态。

## 功能

- 作为后台客户端运行，带有简单的文本用户界面（TUI）
- 自动检测活动窗口标题并将其作为应用程序名称发送
- 基于可配置的刷新间隔定期更新状态
- 脚本关闭时发送"离线"状态
- 可配置的设备 ID 和名称
- 用于故障排除的调试模式

## 系统要求

- PowerShell 5.1 或更高版本
- 可访问运行中的 Sleepy API 服务器

## 安装

1. 克隆或下载此仓库
2. 确保 PowerShell 执行策略允许运行脚本
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

## 使用方法

1. 从 PowerShell 运行脚本：
   ```powershell
   .\Sleepy-Client.ps1
   ```

   您也可以直接从命令行启用调试模式：
   ```powershell
   # 启用调试模式
   .\Sleepy-Client.ps1 -DebugMode
   ```

2. 首次运行时，您需要配置：
   - API URL（默认：http://localhost:9010）
   - 用于身份验证的密钥
   - 刷新间隔
   - 设备 ID 和名称

3. 客户端将显示一个简单的 TUI，包含：
   - 服务器状态信息
   - 客户端状态信息
   - 当前活动窗口信息
   - 可用命令

4. 可用命令：
   - S - 打开设置
   - R - 立即强制刷新
   - Q - 退出（发送离线状态）

## 配置

客户端将其配置存储在与脚本相同目录下的 `sleepy-client-config.json` 文件中。该文件包含：

- `ApiUrl`：Sleepy API 服务器的 URL
- `Secret`：API 的身份验证密钥（用于标准 Bearer 令牌认证）
- `RefreshInterval`：刷新状态信息的频率（以秒为单位）
- `DeviceId`：发送状态更新时使用的设备 ID
- `DeviceName`：要显示的设备名称
- `DebugMode`：启用时输出详细的日志信息

## 工作原理

1. 客户端通过 Windows API 调用定期检查活动窗口标题
2. 当活动窗口改变或刷新间隔过去时，它会向 Sleepy API 发送更新
3. 更新包括：
   - 设备 ID 和名称
   - "Using" 状态设置为 true
   - 应用程序名称设置为活动窗口标题
4. 当脚本关闭时（通过按 Q 或使用 Ctrl+C），它会发送"离线"状态

## 许可证

本项目是开源的，采用 GNU GPL v3 许可证。