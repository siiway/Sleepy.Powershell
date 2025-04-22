# Sleepy PowerShell 工具集

[中文简体](README_zh.md) | [English](README.md)

一套完整的 PowerShell 工具集，用于与 Sleepy API 交互。本项目包含 SDK、后台客户端和控制面板，用于管理您的 Sleepy 状态。

## 组件

### 1. SDK (`/SDK`)
提供对 Sleepy API 进行编程访问的 PowerShell 模块。功能包括：
- 完整的 API 覆盖
- 可配置的调试模式
- 自动身份验证
- 全面的错误处理
- 详细的日志选项

### 2. 客户端 (`/Client`)
基于活动窗口自动更新状态的后台客户端：
- 在后台运行，带有简单的文本用户界面
- 自动检测活动窗口标题
- 定期状态更新
- 退出时自动设置离线状态
- 可配置的刷新间隔

### 3. 控制面板 (`/ControlPanel`)
用于管理 Sleepy 设置和状态的用户友好界面：
- 状态管理
- 设备管理
- 配置设置
- 调试选项
- 数据持久化控制

## 系统要求

- PowerShell 5.1 或更高版本
- 可访问运行中的 Sleepy API 服务器
- Windows 操作系统（用于客户端窗口检测功能）

## 快速开始

1. 克隆此仓库：
   ```powershell
   git clone https://github.com/siiway/sleepy-powershell.git
   ```

2. 确保 PowerShell 执行策略允许运行脚本：
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. 选择您的工具：

   **使用 SDK：**
   ```powershell
   Import-Module -Name ".\SDK\Sleepy.psm1"
   Set-SleepyConfig -ApiUrl "http://localhost:8080" -Secret "您的密钥"
   ```

   **运行客户端：**
   ```powershell
   .\Client\Sleepy-Client.ps1
   ```

   **启动控制面板：**
   ```powershell
   .\ControlPanel\Sleepy-ControlPanel.ps1
   ```

## 配置

每个组件都将其配置存储在 JSON 文件中：

- SDK: `SDK\sleepy-config.json`
- 客户端: `Client\sleepy-client-config.json`
- 控制面板: `ControlPanel\sleepy-config.json`

默认配置：
```json
{
    "ApiUrl": "http://localhost:9010",
    "Secret": "您的密钥",
    "DebugMode": false,
    "FullDebugMode": false,
    "RefreshInterval": 5
}
```

## 调试模式

所有组件支持两种调试级别：

1. 基本调试模式：显示基本的请求/响应信息
2. 完整调试模式：显示完整的请求/响应详情

通过命令行启用调试模式：
```powershell
# 对于客户端
.\Client\Sleepy-Client.ps1 -DebugMode

# 对于控制面板
.\ControlPanel\Sleepy-ControlPanel.ps1 -FullDebugMode
```

## 组件文档

每个组件都有其详细的 README：

- [SDK 文档](SDK/README_zh.md)
- [客户端文档](Client/README_zh.md)
- [控制面板文档](ControlPanel/README_zh.md)

## 项目结构

> [!NOTE]
> 项目结构中不包含 README 文件的不同语言版本。

```
sleepy-powershell/
├── SDK/
│   ├── Sleepy.psm1         # 主 SDK 模块
│   ├── Sleepy.psd1         # 模块清单
│   ├── Example-Usage.ps1   # 使用示例
│   └── README.md           # SDK 文档
├── Client/
│   ├── Sleepy-Client.ps1   # 后台客户端
│   └── README.md           # 客户端文档
├── ControlPanel/
│   ├── Sleepy-ControlPanel.ps1   # 控制面板界面
│   └── README.md           # 控制面板文档
└── README.md              # 本文件
```

## 常见用例

1. **自动状态更新：**
   使用客户端根据活动窗口自动更新状态。

2. **手动状态管理：**
   使用控制面板手动管理状态和设备。

3. **自定义集成：**
   使用 SDK 构建自定义解决方案或与其他工具集成。

## 贡献

欢迎贡献！请随时提交拉取请求或创建问题报告错误和功能请求。

## 许可证

本项目采用 GNU GPL v3 许可证 - 详见各组件文档。

## 作者

- NT_AUTHORITY
- SiiWay 团队

## 支持

如需支持，请在 GitHub 仓库创建问题或联系开发团队。