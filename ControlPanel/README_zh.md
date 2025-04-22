# Sleepy PowerShell 控制面板

一个基于 PowerShell 的控制面板，用于管理 Sleepy API。该控制面板提供了一个用户友好的界面来与 Sleepy 交互，允许您管理状态、设备和其他设置。

## 功能

- 查看当前状态信息
- 从可用选项中更改状态
- 管理设备信息：
  - 添加/更新设备
  - 移除设备
  - 清除所有设备
  - 切换私密模式
- 将数据保存到持久存储
- 配置连接设置
- 用于详细日志记录的调试模式
- 完整调试模式，提供完整的请求/响应信息，并支持手动继续

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
   .\Sleepy-ControlPanel.ps1
   ```

   您也可以直接从命令行启用调试模式：
   ```powershell
   # 启用调试模式
   .\Sleepy-ControlPanel.ps1 -DebugMode

   # 启用完整调试模式（包括完整的请求/响应详情并暂停以供查看）
   .\Sleepy-ControlPanel.ps1 -FullDebugMode
   ```

2. 首次运行时，进入"设置"配置：
   - API URL（默认：http://localhost:9010）
   - 用于身份验证的密钥
   - 刷新间隔

3. 使用方向键导航菜单，按回车键选择选项

## 配置

控制面板将其配置存储在与脚本相同目录下的 `sleepy-config.json` 文件中。该文件包含：

- `ApiUrl`：Sleepy API 服务器的 URL
- `Secret`：API 的身份验证密钥（用于标准 Bearer 令牌认证）
- `RefreshInterval`：刷新状态信息的频率（以秒为单位）
- `DebugMode`：启用时输出有关 API 请求和响应的详细日志信息
- `FullDebugMode`：启用时输出完整的请求和响应详情，包括头部、正文内容和异常信息。还会在每个操作后暂停，以便在继续之前查看调试信息

## 菜单选项

### 查看当前状态
显示来自 Sleepy API 的当前状态信息，包括：
- 当前时间和时区
- 当前状态和描述
- 设备列表及其状态

### 更改状态
显示可用状态列表，允许您选择一个设置为当前状态。

### 管理设备
提供设备管理子菜单：
- 添加/更新设备：添加新设备或更新现有设备
- 移除设备：移除特定设备
- 清除所有设备：移除所有设备
- 切换私密模式：启用或禁用私密模式

### 保存数据
将当前状态和设备信息保存到服务器上的持久存储。

### 设置
配置控制面板设置：
- API URL
- 身份验证密钥
- 刷新间隔
- 调试模式（启用/禁用详细日志记录）
- 完整调试模式（启用/禁用完整请求/响应日志记录）

## 许可证

本项目是开源的，采用 GNU GPL v3 许可证。