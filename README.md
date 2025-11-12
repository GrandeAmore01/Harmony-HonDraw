# 鸿绘 - HarmonyOS 图片编辑器

<div align="center">
  <h3>专业的图片编辑工具，支持多人协同创作</h3>
</div>

## 📱 项目简介

鸿绘是一款基于 HarmonyOS 开发的现代化图片编辑应用，采用 ArkTS 语言和 ArkUI 框架构建。应用提供了丰富的图片编辑功能，并支持多人实时协同编辑，是 HarmonyOS 平台上功能完整的图片编辑解决方案。

## ✨ 核心功能

### 1. 基础编辑功能

- **图片打开与保存**：支持从相册选择图片，编辑后保存回相册
- **图片缩放与滚动**：支持手势缩放和拖拽浏览大图
- **图片裁剪**：提供多种预设宽高比，支持自定义裁剪区域
- **图片旋转**：支持 90° 旋转
- **亮度调节**：范围 -100 到 +100
- **对比度调节**：范围 -100 到 +100

### 2. 绘图工具

- **画笔工具**：自由绘制路径
- **直线工具**：绘制直线
- **矩形工具**：绘制矩形
- **圆形工具**：绘制圆形
- **椭圆工具**：绘制椭圆
- **橡皮擦**：擦除绘制内容（不影响原图）

### 3. 画笔自定义

- **粗细调节**：1-50px 可调
- **颜色选择**：10 种预设颜色
- **透明度调节**：0-100% 可调
- **实时预览**：调整参数实时显示效果

### 4. 文字水印

- **水印文字**：自定义水印内容
- **字体大小**：12-72px 可调
- **字体颜色**：多种颜色选择
- **透明度**：10-100% 可调
- **位置选择**：居中、四角、平铺六种模式

### 5. 撤销/重做

- **操作历史**：记录最近 50 次操作
- **智能管理**：支持撤销和重做
- **状态提示**：按钮状态实时反馈

### 6. 多人协同编辑

- **实时同步**：所有编辑操作实时广播
- **光标显示**：显示其他协作者的光标位置和用户信息
- **用户标识**：不同颜色区分不同用户
- **状态提示**：显示协作者"正在绘制"状态
- **会话管理**：通过 6 位会话码加入协同编辑
- **冲突解决**：采用最后写入优先策略

### 7. 分享功能

- **一键分享**：分享到微信、微博、QQ
- **邮件分享**：通过邮件发送图片
- **保存到相册**：快速保存编辑结果
- **复制到剪贴板**：方便粘贴到其他应用

## 🏗️ 项目结构

```
HongHui1/
├── entry/src/main/
│   ├── ets/
│   │   ├── components/          # UI组件
│   │   │   ├── BrushSettings.ets          # 画笔设置组件
│   │   │   ├── CollaboratorCursor.ets     # 协作者光标组件
│   │   │   ├── ColorPicker.ets            # 颜色选择器
│   │   │   ├── CropPanel.ets              # 裁剪面板
│   │   │   ├── EditorToolbar.ets          # 编辑器工具栏
│   │   │   ├── ImageAdjustPanel.ets       # 图像调整面板
│   │   │   └── WatermarkDialog.ets        # 水印对话框
│   │   │
│   │   ├── model/               # 数据模型
│   │   │   ├── DrawingOperation.ets       # 绘图操作模型
│   │   │   └── ToolbarItem.ets            # 工具栏项模型
│   │   │
│   │   ├── pages/               # 页面
│   │   │   ├── Index.ets                  # 主入口页面
│   │   │   ├── HomePage.ets               # 主页
│   │   │   ├── EditorPage.ets             # 编辑器页面
│   │   │   ├── CollaborationPage.ets      # 协同编辑入口页
│   │   │   └── CollaborativeEditorPage.ets # 协同编辑器页面
│   │   │
│   │   ├── utils/               # 工具类
│   │   │   ├── CollaborationManager.ets   # 协同编辑管理器
│   │   │   ├── HistoryManager.ets         # 历史记录管理器
│   │   │   ├── ImageManager.ets           # 图片管理器
│   │   │   ├── ShareManager.ets           # 分享管理器
│   │   │   └── WatermarkManager.ets       # 水印管理器
│   │   │
│   │   └── entryability/        # Ability
│   │       └── EntryAbility.ets
│   │
│   ├── resources/               # 资源文件
│   │   ├── base/
│   │   │   ├── element/         # 颜色、字符串等
│   │   │   ├── media/           # 图片资源
│   │   │   └── profile/         # 配置文件
│   │   └── dark/                # 深色模式资源
│   │
│   └── module.json5             # 模块配置
│
├── AppScope/                    # 应用全局配置
│   ├── app.json5
│   └── resources/
│
└── README.md                    # 项目说明文档
```

## 🎨 技术架构

### 开发语言与框架

- **ArkTS**：TypeScript 超集，HarmonyOS 官方推荐语言
- **ArkUI**：声明式 UI 框架，提供丰富的组件和布局能力
- **Stage 模型**：HarmonyOS 推荐的应用模型

### 核心技术

- **Canvas API**：用于图片绘制和编辑操作
- **WebSocket**：用于多人协同编辑的实时通信
- **File API**：用于图片文件的读写
- **Router**：用于页面导航和参数传递

### 设计模式

- **MVVM**：Model-View-ViewModel 架构
- **组件化**：UI 组件高度模块化，可复用性强
- **状态管理**：使用 @State、@Link、@Prop 进行状态管理

## 📋 HarmonyOS 开发规范

### 1. 命名规范

- **文件命名**：大驼峰命名法（PascalCase），如 `EditorPage.ets`
- **组件命名**：使用 `@Component` 装饰器，结构体名称使用大驼峰
- **变量命名**：小驼峰命名法（camelCase），如 `imageUri`
- **常量命名**：全大写下划线分隔，如 `MAX_HISTORY_SIZE`

### 2. 代码结构规范

- **导入顺序**：系统 Kit → 第三方库 → 自定义模块
- **组件结构**：装饰器 → 状态变量 → 私有变量 → 生命周期方法 → 自定义方法 → build 方法
- **类型声明**：优先使用明确的类型声明，避免使用 `any`

### 3. UI 开发规范

- **声明式语法**：使用 ArkUI 提供的声明式语法构建 UI
- **响应式布局**：使用 Column、Row、Flex 等容器组件
- **尺寸单位**：使用 vp（虚拟像素）作为统一单位
- **颜色规范**：使用十六进制颜色码或资源引用

### 4. Stage 模型规范

- **UIAbility**：用于界面展示，每个页面对应一个 Ability
- **Context**：通过 `getContext()` 获取上下文，访问系统能力
- **生命周期**：正确实现 `aboutToAppear` 和 `aboutToDisappear`

## 🚀 快速开始

### 环境要求

- DevEco Studio 4.0 或更高版本
- HarmonyOS SDK API 9 或更高版本
- Node.js 14.x 或更高版本

### 安装步骤

1. **克隆项目**

```bash
git clone <repository-url>
cd HongHui1
```

2. **使用 DevEco Studio 打开项目**

   - File → Open → 选择项目目录

3. **同步依赖**

   - DevEco Studio 会自动检测并下载依赖

4. **运行项目**
   - 连接 HarmonyOS 设备或启动模拟器
   - 点击运行按钮或使用快捷键 Shift+F10

## 📱 功能使用指南

### 单人编辑模式

1. 在主页点击"开始编辑"
2. 从相册选择图片
3. 使用底部工具栏选择编辑工具
4. 完成编辑后点击"分享"保存或分享

### 协同编辑模式

#### 创建会话

1. 在主页点击"协同编辑"
2. 输入用户名
3. 选择"创建会话"
4. 选择要编辑的图片
5. 系统生成 6 位会话码，分享给协作者

#### 加入会话

1. 在主页点击"协同编辑"
2. 输入用户名
3. 选择"加入会话"
4. 输入 6 位会话码
5. 点击"加入会话"开始协同编辑

## 🎯 核心功能实现说明

### 1. Canvas 绘图

使用 HarmonyOS Canvas API 实现所有绘图操作，支持：

- 实时绘制预览
- 多种绘图模式（路径、形状）
- 橡皮擦功能（使用 `globalCompositeOperation`）

### 2. 撤销/重做

基于命令模式实现：

- 维护操作历史栈
- 记录当前操作索引
- 支持前进和后退

### 3. 协同编辑

基于 WebSocket 实现实时通信：

- 操作广播：每次绘图操作广播给所有用户
- 光标同步：实时显示其他用户的光标位置
- 状态同步：新用户加入时同步当前画布状态
- 冲突解决：采用最后写入优先（Last Write Wins）策略

### 4. 图片处理

使用 HarmonyOS Image Kit：

- PixelMap 操作
- 亮度/对比度调整（像素级别）
- 裁剪功能

## 📝 待优化功能

1. **性能优化**

   - 大图片加载优化
   - Canvas 渲染性能优化
   - 协同编辑消息限流

2. **功能增强**

   - 更多绘图工具（文本、箭头等）
   - 图层管理
   - 滤镜效果
   - 历史记录持久化

3. **用户体验**
   - 手势操作优化
   - 动画效果
   - 暗黑模式适配
   - 多语言支持

## 🤝 协同编辑架构说明

### WebSocket 消息协议

```typescript
interface CollaborationMessage {
  type: MessageType; // 消息类型
  sessionCode: string; // 会话码
  userId: string; // 用户ID
  userName: string; // 用户名
  userColor: string; // 用户标识颜色
  timestamp: number; // 时间戳
  data?: any; // 消息数据
}
```

### 消息类型

- `JOIN`：用户加入会话
- `LEAVE`：用户离开会话
- `DRAW`：绘图操作
- `UNDO`：撤销操作
- `REDO`：重做操作
- `CURSOR_MOVE`：光标移动
- `SYNC_REQUEST`：请求同步
- `SYNC_RESPONSE`：同步响应

## 📄 许可证

本项目仅供学习和参考使用。

## 👥 贡献指南

欢迎提交 Issue 和 Pull Request 来改进项目。

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 GitHub Issue
- 发送邮件至项目维护者

---

**鸿绘** - 让图片编辑更简单，让协作创作更高效！
