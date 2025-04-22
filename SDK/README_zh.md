# Sleepy PowerShell SDK

[中文简体](SDK/README_zh.md) | [English](SDK/README.md)

用于与 Sleepy API 交互的 PowerShell SDK。该 SDK 提供了一种简单直观的方式将 Sleepy 功能集成到您的 PowerShell 脚本和应用程序中。

## 功能

- 完整的 Sleepy 功能 API 覆盖
- 用于故障排除的可配置调试模式
- 自动身份验证处理
- 查询参数支持
- 全面的错误处理
- 详细的日志选项

## 系统要求

- PowerShell 5.1 或更高版本
- 可访问运行中的 Sleepy API 服务器

## 安装

1. 克隆或下载此仓库
2. 在您的 PowerShell 脚本中导入模块：
   ```powershell
   Import-Module -Name "path\to\SDK\Sleepy.psm1"
   ```

## 快速开始

```powershell
# 导入模块
Import-Module -Name ".\Sleepy.psm1"

# 配置 SDK
Set-SleepyConfig -ApiUrl "http://localhost:9010" -Secret "您的密钥"

# 获取当前状态
$status = Get-SleepyStatus

# 设置新状态
Set-SleepyStatus -StatusId 0

# 更新设备状态
Set-SleepyDeviceStatus -Id "device-1" -ShowName "我的设备" -Using $true -AppName "PowerShell"
```

## 可用函数

- `Import-SleepyConfig`：从文件加载配置
- `Set-SleepyConfig`：配置 SDK 设置
- `Get-SleepyStatus`：获取当前状态
- `Get-SleepyStatusList`：获取可用状态选项
- `Set-SleepyStatus`：设置当前状态
- `Set-SleepyDeviceStatus`：更新设备状态
- `Remove-SleepyDevice`：移除设备
- `Clear-SleepyDevices`：移除所有设备
- `Set-SleepyPrivateMode`：切换私密模式
- `Save-SleepyData`：将当前状态保存到持久存储

## 调试模式

SDK 支持两种调试级别：

1. 基本调试模式：
```powershell
Set-SleepyConfig -DebugMode
```

2. 完整调试模式（包括完整的请求/响应详情）：
```powershell
Set-SleepyConfig -FullDebugMode
```

## 配置

SDK 可以使用 JSON 文件（`sleepy-config.json`）或以编程方式进行配置：

```json
{
    "ApiUrl": "http://localhost:9010",
    "Secret": "您的密钥",
    "DebugMode": false,
    "FullDebugMode": false
}
```

## 使用示例

查看 `Example-Usage.ps1` 获取所有 SDK 功能的完整示例。

## 错误处理

SDK 包含健壮的错误处理，带有详细的错误消息和调试信息。在调试模式下，您将收到有关任何失败的全面信息，包括：

- HTTP 状态码
- 错误消息
- 堆栈跟踪
- 请求/响应详情

## 许可证

本项目是开源的，采用 GNU GPL v3 许可证。

## 贡献

欢迎贡献！请随时提交拉取请求。