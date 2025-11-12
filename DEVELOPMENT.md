# 鸿绘开发文档

## 📚 HarmonyOS 开发规范详解

本文档详细说明了"鸿绘"项目中遵循的 HarmonyOS 开发规范，以及如何基于 ARK Compiler 和 Stage 模型进行应用开发。

## 1. 项目架构设计

### 1.1 Stage 模型架构

本项目采用 HarmonyOS 推荐的 Stage 模型，主要包含以下组件：

#### UIAbility

- **EntryAbility**：应用主入口，负责应用生命周期管理
- 位置：`entry/src/main/ets/entryability/EntryAbility.ets`

```typescript
import { UIAbility, Want } from "@kit.AbilityKit";
import { window } from "@kit.ArkUI";

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 应用初始化
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 设置主窗口
    windowStage.loadContent("pages/Index");
  }
}
```

#### 页面路由

使用 `@kit.ArkUI` 中的 `router` 进行页面导航：

```typescript
import { router } from "@kit.ArkUI";

// 页面跳转
router.pushUrl({
  url: "pages/EditorPage",
  params: {
    imageUri: imageUri,
    isCollaborative: false,
  },
});

// 页面返回
router.back();

// 获取路由参数
const params = router.getParams() as Record<string, Object>;
```

### 1.2 组件化设计

#### 自定义组件规范

```typescript
// 使用 @Component 装饰器声明组件
@Component
export struct ComponentName {
  // 1. @Link/@Prop/@State 状态变量
  @Link selectedColor: string
  @State isVisible: boolean = false

  // 2. 私有变量
  private items: string[] = []

  // 3. 回调函数
  onConfirm?: () => void

  // 4. 生命周期方法
  aboutToAppear() {
    // 组件即将出现
  }

  aboutToDisappear() {
    // 组件即将消失
  }

  // 5. 自定义方法
  private handleClick() {
    // 处理点击事件
  }

  // 6. build 方法（必须）
  build() {
    Column() {
      // UI 构建
    }
  }
}
```

#### 自定义对话框组件

```typescript
@CustomDialog
export struct WatermarkDialog {
  controller: CustomDialogController
  onConfirm?: (params: any) => void

  build() {
    Column() {
      // 对话框内容
    }
  }
}

// 使用方式
this.dialogController = new CustomDialogController({
  builder: WatermarkDialog({
    onConfirm: (params) => {
      this.handleConfirm(params)
    }
  }),
  autoCancel: true,
  alignment: DialogAlignment.Center,
  customStyle: true
})
this.dialogController.open()
```

## 2. ArkTS 语言规范

### 2.1 类型声明

```typescript
// ✅ 推荐：明确的类型声明
let imageUri: string = "";
let operations: DrawingOperation[] = [];
let isDrawing: boolean = false;

// ❌ 不推荐：使用 any
let data: any = {};

// ✅ 推荐：使用接口定义复杂类型
interface CollaborationMessage {
  type: MessageType;
  sessionCode: string;
  userId: string;
  timestamp: number;
  data?: any;
}
```

### 2.2 枚举类型

```typescript
// 工具类型枚举
export enum ToolType {
  NONE = "NONE",
  PEN = "PEN",
  ERASER = "ERASER",
  LINE = "LINE",
  RECT = "RECT",
  CIRCLE = "CIRCLE",
}

// 使用枚举
this.selectedTool = ToolType.PEN;
```

### 2.3 类与模型

```typescript
// 数据模型类
export class DrawingOperation {
  id: string = "";
  type: OperationType = OperationType.DRAW_LINE;
  color: string = "#000000";
  strokeWidth: number = 2;
  opacity: number = 1.0;
  points: Array<{ x: number; y: number }> = [];

  constructor(type: OperationType) {
    this.type = type;
    this.id = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
}
```

## 3. ArkUI 声明式语法

### 3.1 布局组件

```typescript
build() {
  Column({ space: 20 }) {  // 垂直布局，子组件间距 20
    Row() {                 // 水平布局
      Text('标题')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Blank()              // 弹性空白

      Button('按钮')
        .onClick(() => {
          this.handleClick()
        })
    }
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })

    // 滚动容器
    Scroll() {
      Column({ space: 12 }) {
        // 内容
      }
    }
    .layoutWeight(1)       // 占据剩余空间
  }
  .width('100%')
  .height('100%')
}
```

### 3.2 常用组件

#### Text 文本组件

```typescript
Text("鸿绘图片编辑器")
  .fontSize(20) // 字体大小
  .fontWeight(FontWeight.Bold) // 字体粗细
  .fontColor("#1A1A1A") // 字体颜色
  .textAlign(TextAlign.Center) // 文本对齐
  .maxLines(2) // 最大行数
  .textOverflow({
    // 文本溢出处理
    overflow: TextOverflow.Ellipsis,
  });
```

#### Button 按钮组件

```typescript
Button("开始编辑")
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .backgroundColor("#007DFF") // 背景色
  .fontColor("#FFFFFF") // 文字颜色
  .borderRadius(24) // 圆角
  .height(48)
  .width(160)
  .onClick(() => {
    this.selectImage();
  });
```

#### Image 图片组件

```typescript
Image(this.imageUri)
  .width(80)
  .height(80)
  .borderRadius(8)
  .objectFit(ImageFit.Cover); // 图片填充模式
```

#### TextInput 输入框

```typescript
TextInput({
  placeholder: "请输入用户名",
  text: this.userName,
})
  .height(48)
  .fontSize(16)
  .backgroundColor("#F5F5F5")
  .borderRadius(8)
  .onChange((value: string) => {
    this.userName = value;
  });
```

#### Slider 滑块

```typescript
Slider({
  value: this.strokeWidth,
  min: 1,
  max: 50,
  step: 1,
  style: SliderStyle.OutSet,
})
  .blockColor("#007DFF") // 滑块颜色
  .trackColor("#E5E5E5") // 轨道颜色
  .selectedColor("#007DFF") // 选中部分颜色
  .showTips(false)
  .onChange((value: number) => {
    this.strokeWidth = value;
  });
```

#### List 列表组件

```typescript
List({ space: 12 }) {
  ForEach(this.items, (item: string, index: number) => {
    ListItem() {
      Row() {
        Text(item)
      }
    }
  })
}
.width('100%')
.scrollBar(BarState.Off)          // 隐藏滚动条
```

#### Grid 网格组件

```typescript
Grid() {
  ForEach(this.colors, (color: string) => {
    GridItem() {
      Circle({ width: 32, height: 32 })
        .fill(color)
    }
  })
}
.columnsTemplate('1fr 1fr 1fr 1fr 1fr')  // 5列均分
.rowsGap(8)                               // 行间距
.columnsGap(8)                            // 列间距
```

### 3.3 Canvas 绘图

```typescript
@State canvasContext: CanvasRenderingContext2D | null = null
private settings: RenderingContextSettings = new RenderingContextSettings(true)

build() {
  Canvas(this.canvasContext)
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .onReady(() => {
      // Canvas 初始化
      this.canvasContext = new CanvasRenderingContext2D(this.settings)
      this.redrawCanvas()
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.handleTouchStart(event)
      } else if (event.type === TouchType.Move) {
        this.handleTouchMove(event)
      } else if (event.type === TouchType.Up) {
        this.handleTouchEnd(event)
      }
    })
}

// Canvas 绘图方法
redrawCanvas() {
  if (!this.canvasContext) return

  // 清空画布
  this.canvasContext.clearRect(0, 0, 800, 600)

  // 绘制图片
  const img = new Image()
  img.src = this.imageUri
  this.canvasContext.drawImage(img, 0, 0, 800, 600)

  // 绘制路径
  this.canvasContext.beginPath()
  this.canvasContext.moveTo(x1, y1)
  this.canvasContext.lineTo(x2, y2)
  this.canvasContext.stroke()

  // 绘制矩形
  this.canvasContext.strokeRect(x, y, width, height)

  // 绘制圆形
  this.canvasContext.arc(x, y, radius, 0, Math.PI * 2)
  this.canvasContext.stroke()

  // 绘制椭圆
  this.canvasContext.ellipse(x, y, radiusX, radiusY, 0, 0, Math.PI * 2)
  this.canvasContext.stroke()
}
```

## 4. 系统能力使用

### 4.1 文件选择

```typescript
import { picker } from '@kit.CoreFileKit'

async selectImage() {
  try {
    const photoSelectOptions = new picker.PhotoSelectOptions()
    photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
    photoSelectOptions.maxSelectNumber = 1

    const photoPicker = new picker.PhotoViewPicker()
    const result = await photoPicker.select(photoSelectOptions)

    if (result && result.photoUris && result.photoUris.length > 0) {
      const imageUri = result.photoUris[0]
      // 处理选中的图片
    }
  } catch (err) {
    console.error('选择图片失败:', JSON.stringify(err))
  }
}
```

### 4.2 Toast 提示

```typescript
import { promptAction } from "@kit.ArkUI";

promptAction.showToast({
  message: "操作成功",
  duration: 2000,
});
```

### 4.3 获取 Context

```typescript
import { common } from "@kit.AbilityKit";

// 在组件中获取 Context
const context = getContext(this) as common.UIAbilityContext;

// 使用 Context
await ShareManager.shareToApp(this.imageUri, "wechat", context);
```

### 4.4 WebSocket 通信

```typescript
import { webSocket } from "@kit.NetworkKit";

export class CollaborationManager {
  private ws: webSocket.WebSocket | null = null;

  async connect(serverUrl: string): Promise<boolean> {
    try {
      this.ws = webSocket.createWebSocket();

      this.ws.on("open", () => {
        console.log("WebSocket连接已建立");
      });

      this.ws.on("message", (err, value) => {
        if (!err) {
          const message = JSON.parse(value.toString());
          this.handleMessage(message);
        }
      });

      this.ws.on("close", (err, reason) => {
        console.log("WebSocket连接已关闭");
      });

      this.ws.on("error", (err) => {
        console.error("WebSocket错误:", err);
      });

      await this.ws.connect(serverUrl);
      return true;
    } catch (err) {
      console.error("连接失败:", err);
      return false;
    }
  }

  sendMessage(message: any) {
    if (this.ws) {
      this.ws.send(JSON.stringify(message));
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
    }
  }
}
```

## 5. 状态管理

### 5.1 @State 装饰器

用于组件内部状态管理，状态变化会触发 UI 刷新：

```typescript
@State selectedTool: ToolType = ToolType.NONE
@State currentColor: string = '#000000'
@State strokeWidth: number = 3
```

### 5.2 @Link 装饰器

用于父子组件双向数据绑定：

```typescript
// 父组件
@State selectedColor: string = '#000000'

ColorPicker({ selectedColor: $selectedColor })

// 子组件
@Component
export struct ColorPicker {
  @Link selectedColor: string

  build() {
    // selectedColor 的修改会同步到父组件
  }
}
```

### 5.3 @Prop 装饰器

用于父子组件单向数据传递：

```typescript
// 父组件
CollaboratorCursor({ collaborator: collab })

// 子组件
@Component
export struct CollaboratorCursor {
  @Prop collaborator: CollaboratorInfo

  build() {
    // 只读，不能修改
  }
}
```

## 6. 最佳实践

### 6.1 命名规范

```typescript
// 文件命名：大驼峰
EditorPage.ets
DrawingOperation.ets

// 类名：大驼峰
export class ImageManager { }

// 接口名：大驼峰
export interface CollaborationMessage { }

// 枚举名：大驼峰
export enum ToolType { }

// 变量名：小驼峰
let imageUri: string
let isDrawing: boolean

// 常量名：全大写下划线
const MAX_HISTORY_SIZE = 50

// 私有成员：下划线前缀（可选）
private _canvasContext: CanvasRenderingContext2D | null
```

### 6.2 代码组织

```typescript
// 1. 导入语句（按类型分组）
import { router } from '@kit.ArkUI'           // 系统 Kit
import { image } from '@kit.ImageKit'
import { ToolType } from '../model/ToolbarItem'  // 自定义模块
import { ImageManager } from '../utils/ImageManager'

// 2. 接口/类型定义
interface WatermarkParams {
  text: string
  fontSize: number
}

// 3. 枚举定义
enum MessageType {
  DRAW = 'DRAW',
  UNDO = 'UNDO'
}

// 4. 组件定义
@Entry
@Component
struct EditorPage {
  // 状态变量
  @State imageUri: string = ''

  // 私有变量
  private canvasContext: CanvasRenderingContext2D | null = null

  // 生命周期
  aboutToAppear() { }

  // 自定义方法
  private handleClick() { }

  // build 方法
  build() { }

  // Builder 方法
  @Builder
  ToolbarItem() { }
}
```

### 6.3 错误处理

```typescript
async loadImage() {
  try {
    const pixelMap = await ImageManager.loadImagePixelMap(this.imageUri)
    if (pixelMap) {
      // 处理图片
    }
  } catch (err) {
    console.error('加载图片失败:', JSON.stringify(err))
    promptAction.showToast({
      message: '图片加载失败',
      duration: 2000
    })
  }
}
```

### 6.4 性能优化

```typescript
// 使用 @Builder 复用 UI
@Builder
FeatureCard(icon: string, title: string, desc: string) {
  Column({ space: 8 }) {
    Text(icon).fontSize(32)
    Text(title).fontSize(14)
    Text(desc).fontSize(10)
  }
}

// 列表使用 ForEach + 唯一 key
ForEach(this.items, (item: ItemData, index: number) => {
  ListItem() {
    // ...
  }
  .key(item.id)  // 提供唯一 key
})

// 避免频繁的状态更新
// ❌ 不推荐
this.canvasContext.drawImage(...)
this.operations.push(op)  // 触发刷新
this.redrawCanvas()       // 再次刷新

// ✅ 推荐
this.operations.push(op)
this.redrawCanvas()       // 只刷新一次
```

## 7. 调试技巧

### 7.1 日志输出

```typescript
console.log("普通日志");
console.info("信息日志");
console.warn("警告日志");
console.error("错误日志");
console.debug("调试日志");
```

### 7.2 DevEco Studio 调试

1. 设置断点：点击代码行号左侧
2. 启动调试：点击 Debug 按钮
3. 查看变量：在 Variables 面板查看
4. 单步执行：使用 F8（Step Over）、F7（Step Into）

## 8. 项目配置

### 8.1 module.json5

```json5
{
  module: {
    name: "entry",
    type: "entry",
    description: "$string:module_desc",
    mainElement: "EntryAbility",
    deviceTypes: ["phone"],
    deliveryWithInstall: true,
    installationFree: false,
    pages: "$profile:main_pages",
    abilities: [
      {
        name: "EntryAbility",
        srcEntry: "./ets/entryability/EntryAbility.ets",
        description: "$string:EntryAbility_desc",
        icon: "$media:layered_image",
        label: "$string:EntryAbility_label",
        startWindowIcon: "$media:startIcon",
        startWindowBackground: "$color:start_window_background",
        exported: true,
        skills: [
          {
            entities: ["entity.system.home"],
            actions: ["ohos.want.action.home"],
          },
        ],
      },
    ],
  },
}
```

### 8.2 main_pages.json

```json
{
  "src": [
    "pages/Index",
    "pages/HomePage",
    "pages/EditorPage",
    "pages/CollaborationPage",
    "pages/CollaborativeEditorPage"
  ]
}
```

## 9. 总结

遵循 HarmonyOS 开发规范能够：

- ✅ 提高代码可读性和可维护性
- ✅ 充分利用 ARK Compiler 优化
- ✅ 确保应用性能和稳定性
- ✅ 符合鸿蒙生态标准

持续关注 HarmonyOS 官方文档，了解最新的开发规范和最佳实践。
