# Note+ · SwiftUI

根据你的笔记，用 Claude AI 匹配书籍、文章、博客中的共鸣段落。

---

## 快速开始

### 1. 在 Xcode 新建项目
- File → New → Project → App
- 语言选 **Swift**，界面选 **SwiftUI**
- 产品名填 **NotePlus**

### 2. 替换文件
把以下文件拖入 Xcode 项目（替换同名文件）：

```
NotePlusApp.swift     ← App 入口
ContentView.swift     ← 根视图 + 背景 + Logo
Models.swift          ← 数据模型 + 颜色
AnthropicService.swift← API 调用
NoteViewModel.swift   ← 状态管理
HomeView.swift        ← 首页（输入 + chips）
ResultView.swift      ← 结果页（书卡 + 骨架屏）
```

### 3. 填入 API Key
打开 `AnthropicService.swift`，找到这一行：

```swift
static let apiKey = "YOUR_ANTHROPIC_API_KEY"
```

替换成你的 Anthropic API Key。

> ⚠️ 正式上线前建议把 Key 移到服务端，不要硬编码在客户端。

### 4. 运行
选择模拟器或真机，按 ⌘R 运行。

---

## 项目结构

| 文件 | 职责 |
|------|------|
| `NotePlusApp.swift` | App 入口，强制深色模式 |
| `ContentView.swift` | 背景渐变光晕、屏幕切换动画、六边形 Logo |
| `Models.swift` | `ReadingItem` 数据模型、体裁颜色映射 |
| `AnthropicService.swift` | 调用 `claude-sonnet-4-20250514`，解析 JSON |
| `NoteViewModel.swift` | `@MainActor` ViewModel，管理所有状态 |
| `HomeView.swift` | 输入框、示例 chips、FlowLayout |
| `ResultView.swift` | 结果列表、`BookCard`、`SkeletonCard` |

---

## 功能特性

- ✅ 匹配 10 条内容（经典书籍 + 当代书籍 + 文章/博客）
- ✅ 体裁颜色标签（小说/哲学/心理/回忆录/散文/诗歌/新闻/博客）
- ✅ 骨架屏加载动画
- ✅ ❤️ 收藏功能
- ✅ 「阅读原文」链接跳转（文章/博客类）
- ✅ 示例话题 chips + 随机换一个
- ✅ 深色模式 + 渐变光晕背景

---

## 最低要求

- iOS 17+（使用了 `Layout` 协议和 `Canvas`）
- Xcode 15+
