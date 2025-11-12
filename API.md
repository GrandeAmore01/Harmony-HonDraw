# 鸿绘 API 文档

本文档详细说明了鸿绘应用中各个模块、组件和工具类的 API 接口。

## 目录

- [数据模型](#数据模型)
- [UI 组件](#ui-组件)
- [工具类](#工具类)
- [页面](#页面)

---

## 数据模型

### OperationType 枚举

绘图操作类型枚举。

```typescript
enum OperationType {
  DRAW_LINE = 'DRAW_LINE'           // 绘制直线
  DRAW_RECT = 'DRAW_RECT'           // 绘制矩形
  DRAW_CIRCLE = 'DRAW_CIRCLE'       // 绘制圆形
  DRAW_ELLIPSE = 'DRAW_ELLIPSE'     // 绘制椭圆
  DRAW_PATH = 'DRAW_PATH'           // 绘制路径
  DRAW_TEXT = 'DRAW_TEXT'           // 绘制文字
  CROP = 'CROP'                     // 裁剪
  ROTATE = 'ROTATE'                 // 旋转
  ADJUST_BRIGHTNESS = 'ADJUST_BRIGHTNESS'  // 调整亮度
  ADJUST_CONTRAST = 'ADJUST_CONTRAST'      // 调整对比度
  ERASER = 'ERASER'                 // 橡皮擦
}
```

### DrawingOperation 类

绘图操作数据模型。

#### 属性

| 属性名      | 类型                          | 默认值     | 说明                   |
| ----------- | ----------------------------- | ---------- | ---------------------- |
| id          | string                        | ''         | 操作唯一标识           |
| type        | OperationType                 | DRAW_LINE  | 操作类型               |
| color       | string                        | '#000000'  | 颜色（十六进制）       |
| strokeWidth | number                        | 2          | 线条宽度               |
| opacity     | number                        | 1.0        | 透明度（0-1）          |
| points      | Array<{x: number, y: number}> | []         | 坐标点数组             |
| text        | string?                       | -          | 文字内容（可选）       |
| timestamp   | number                        | Date.now() | 时间戳                 |
| userId      | string?                       | -          | 用户 ID（协同编辑用）  |
| userName    | string?                       | -          | 用户名（协同编辑用）   |
| userColor   | string?                       | -          | 用户颜色（协同编辑用） |

#### 构造函数

```typescript
constructor(type: OperationType)
```

创建一个新的绘图操作实例。

**参数：**

- `type`: 操作类型

**示例：**

```typescript
const operation = new DrawingOperation(OperationType.DRAW_LINE);
operation.color = "#FF0000";
operation.strokeWidth = 5;
operation.points = [
  { x: 10, y: 10 },
  { x: 100, y: 100 },
];
```

### ImageAdjustment 类

图片调整参数模型。

#### 属性

| 属性名     | 类型   | 默认值 | 说明                        |
| ---------- | ------ | ------ | --------------------------- |
| brightness | number | 0      | 亮度（-100 到 100）         |
| contrast   | number | 0      | 对比度（-100 到 100）       |
| rotation   | number | 0      | 旋转角度（0, 90, 180, 270） |
| scale      | number | 1.0    | 缩放比例                    |
| offsetX    | number | 0      | X 轴偏移                    |
| offsetY    | number | 0      | Y 轴偏移                    |

### CollaboratorInfo 类

协作者信息模型。

#### 属性

| 属性名           | 类型              | 默认值    | 说明         |
| ---------------- | ----------------- | --------- | ------------ |
| userId           | string            | ''        | 用户 ID      |
| userName         | string            | ''        | 用户名       |
| userColor        | string            | '#FF0000' | 用户标识颜色 |
| cursorX          | number            | 0         | 光标 X 坐标  |
| cursorY          | number            | 0         | 光标 Y 坐标  |
| isDrawing        | boolean           | false     | 是否正在绘制 |
| currentOperation | DrawingOperation? | -         | 当前操作     |

### ToolType 枚举

工具栏工具类型枚举。

```typescript
enum ToolType {
  NONE = 'NONE'               // 无
  PEN = 'PEN'                 // 画笔
  ERASER = 'ERASER'           // 橡皮擦
  LINE = 'LINE'               // 直线
  RECT = 'RECT'               // 矩形
  CIRCLE = 'CIRCLE'           // 圆形
  ELLIPSE = 'ELLIPSE'         // 椭圆
  TEXT = 'TEXT'               // 文字
  CROP = 'CROP'               // 裁剪
  ROTATE = 'ROTATE'           // 旋转
  BRIGHTNESS = 'BRIGHTNESS'   // 亮度
  CONTRAST = 'CONTRAST'       // 对比度
  WATERMARK = 'WATERMARK'     // 水印
}
```

### ToolbarItem 类

工具栏项目模型。

#### 属性

| 属性名   | 类型     | 默认值 | 说明     |
| -------- | -------- | ------ | -------- |
| type     | ToolType | -      | 工具类型 |
| icon     | string   | -      | 工具图标 |
| label    | string   | -      | 工具标签 |
| selected | boolean  | false  | 是否选中 |

#### 构造函数

```typescript
constructor(type: ToolType, icon: string, label: string)
```

---

## UI 组件

### EditorToolbar 组件

编辑器底部工具栏组件。

#### 属性

| 属性名         | 类型                     | 说明           |
| -------------- | ------------------------ | -------------- |
| selectedTool   | ToolType (@Link)         | 当前选中的工具 |
| onToolSelected | (tool: ToolType) => void | 工具选中回调   |

#### 示例

```typescript
EditorToolbar({
  selectedTool: $selectedTool,
  onToolSelected: (tool: ToolType) => {
    this.onToolSelected(tool);
  },
});
```

### ColorPicker 组件

颜色选择器组件。

#### 属性

| 属性名        | 类型           | 说明           |
| ------------- | -------------- | -------------- |
| selectedColor | string (@Link) | 当前选中的颜色 |

#### 示例

```typescript
ColorPicker({ selectedColor: $currentColor });
```

### BrushSettings 组件

画笔设置组件。

#### 属性

| 属性名      | 类型           | 说明             |
| ----------- | -------------- | ---------------- |
| strokeWidth | number (@Link) | 画笔粗细（1-50） |
| opacity     | number (@Link) | 透明度（0-1）    |

#### 示例

```typescript
BrushSettings({
  strokeWidth: $strokeWidth,
  opacity: $opacity,
});
```

### ImageAdjustPanel 组件

图像调整面板组件。

#### 属性

| 属性名     | 类型           | 说明                  |
| ---------- | -------------- | --------------------- |
| brightness | number (@Link) | 亮度（-100 到 100）   |
| contrast   | number (@Link) | 对比度（-100 到 100） |
| onRotate   | () => void     | 旋转回调              |

#### 示例

```typescript
ImageAdjustPanel({
  brightness: $imageAdjustment.brightness,
  contrast: $imageAdjustment.contrast,
  onRotate: () => {
    this.rotateImage();
  },
});
```

### CropPanel 组件

裁剪面板组件。

#### 属性

| 属性名     | 类型           | 说明            |
| ---------- | -------------- | --------------- |
| cropX      | number (@Link) | 裁剪区域 X 坐标 |
| cropY      | number (@Link) | 裁剪区域 Y 坐标 |
| cropWidth  | number (@Link) | 裁剪区域宽度    |
| cropHeight | number (@Link) | 裁剪区域高度    |
| onConfirm  | () => void     | 确认裁剪回调    |
| onCancel   | () => void     | 取消裁剪回调    |

#### 示例

```typescript
CropPanel({
  cropX: $cropX,
  cropY: $cropY,
  cropWidth: $cropWidth,
  cropHeight: $cropHeight,
  onConfirm: () => {
    this.confirmCrop();
  },
  onCancel: () => {
    this.cancelCrop();
  },
});
```

### WatermarkDialog 对话框

水印对话框组件。

#### 属性

| 属性名     | 类型                   | 说明         |
| ---------- | ---------------------- | ------------ |
| controller | CustomDialogController | 对话框控制器 |
| onConfirm  | (params) => void       | 确认回调     |

#### 回调参数

```typescript
interface WatermarkParams {
  text: string; // 水印文字
  fontSize: number; // 字体大小
  fontColor: string; // 字体颜色
  opacity: number; // 透明度
  position: string; // 位置
}
```

#### 示例

```typescript
this.dialogController = new CustomDialogController({
  builder: WatermarkDialog({
    onConfirm: (params) => {
      this.addWatermark(params);
    },
  }),
  autoCancel: true,
  alignment: DialogAlignment.Center,
});
this.dialogController.open();
```

### CollaboratorCursor 组件

协作者光标组件。

#### 属性

| 属性名       | 类型                     | 说明       |
| ------------ | ------------------------ | ---------- |
| collaborator | CollaboratorInfo (@Prop) | 协作者信息 |

#### 示例

```typescript
ForEach(this.collaborators, (collab: CollaboratorInfo) => {
  CollaboratorCursor({ collaborator: collab });
});
```

---

## 工具类

### HistoryManager 类

历史记录管理器，实现撤销/重做功能。

#### 方法

##### addOperation(operation: DrawingOperation): void

添加新操作到历史记录。

**参数：**

- `operation`: 绘图操作对象

##### undo(): DrawingOperation | null

撤销上一步操作。

**返回值：**

- 被撤销的操作对象，如果无法撤销则返回 null

##### redo(): DrawingOperation | null

重做上一步被撤销的操作。

**返回值：**

- 被重做的操作对象，如果无法重做则返回 null

##### canUndo(): boolean

检查是否可以撤销。

**返回值：**

- true 如果可以撤销，否则 false

##### canRedo(): boolean

检查是否可以重做。

**返回值：**

- true 如果可以重做，否则 false

##### getCurrentOperations(): DrawingOperation[]

获取当前所有有效操作。

**返回值：**

- 操作数组

##### clear(): void

清空历史记录。

#### 示例

```typescript
const historyManager = new HistoryManager();

// 添加操作
historyManager.addOperation(operation);

// 撤销
if (historyManager.canUndo()) {
  const op = historyManager.undo();
}

// 重做
if (historyManager.canRedo()) {
  const op = historyManager.redo();
}
```

### ImageManager 类

图片管理器，处理图片的打开、保存、加载。

#### 静态方法

##### openImage(): Promise<string | null>

打开图片选择器。

**返回值：**

- Promise<string | null>：图片 URI，失败返回 null

##### saveImageToGallery(pixelMap: image.PixelMap, fileName: string): Promise<boolean>

保存图片到相册。

**参数：**

- `pixelMap`: 图片 PixelMap 对象
- `fileName`: 文件名

**返回值：**

- Promise<boolean>：成功返回 true，失败返回 false

##### loadImagePixelMap(uri: string): Promise<image.PixelMap | null>

加载图片到 PixelMap。

**参数：**

- `uri`: 图片 URI

**返回值：**

- Promise<image.PixelMap | null>：PixelMap 对象，失败返回 null

##### getImageSize(uri: string): Promise<{width: number, height: number} | null>

获取图片尺寸。

**参数：**

- `uri`: 图片 URI

**返回值：**

- Promise<{width, height} | null>：图片尺寸，失败返回 null

#### 示例

```typescript
// 打开图片
const uri = await ImageManager.openImage();

// 获取图片尺寸
const size = await ImageManager.getImageSize(uri);

// 加载图片
const pixelMap = await ImageManager.loadImagePixelMap(uri);

// 保存图片
const success = await ImageManager.saveImageToGallery(pixelMap, "edited.jpg");
```

### WatermarkManager 类

水印管理器，添加文字水印。

#### 静态方法

##### drawTextWatermark(ctx, text, x, y, options?)

在 Canvas 上绘制文字水印。

**参数：**

- `ctx`: CanvasRenderingContext2D
- `text`: 水印文字
- `x`: X 坐标
- `y`: Y 坐标
- `options`: 可选参数
  - `fontSize`: 字体大小（默认 24）
  - `fontColor`: 字体颜色（默认'#FFFFFF'）
  - `opacity`: 透明度（默认 0.8）
  - `fontFamily`: 字体家族（默认'sans-serif'）
  - `rotation`: 旋转角度（默认 0）

##### drawRepeatedWatermark(ctx, text, canvasWidth, canvasHeight, options?)

在 Canvas 上绘制重复水印（铺满整个画布）。

**参数：**

- `ctx`: CanvasRenderingContext2D
- `text`: 水印文字
- `canvasWidth`: 画布宽度
- `canvasHeight`: 画布高度
- `options`: 可选参数
  - `fontSize`: 字体大小（默认 24）
  - `fontColor`: 字体颜色（默认'#CCCCCC'）
  - `opacity`: 透明度（默认 0.3）
  - `spacing`: 间距（默认 200）
  - `rotation`: 旋转角度（默认-45）

##### measureText(ctx, text, fontSize): {width, height}

测量文字尺寸。

**参数：**

- `ctx`: CanvasRenderingContext2D
- `text`: 文字内容
- `fontSize`: 字体大小

**返回值：**

- {width, height}：文字尺寸

#### 示例

```typescript
// 单个水印
WatermarkManager.drawTextWatermark(this.canvasContext, "鸿绘", 100, 100, {
  fontSize: 32,
  fontColor: "#FF0000",
  opacity: 0.8,
});

// 重复水印
WatermarkManager.drawRepeatedWatermark(
  this.canvasContext,
  "鸿绘水印",
  800,
  600,
  {
    fontSize: 24,
    opacity: 0.3,
    rotation: -45,
  }
);
```

### ShareManager 类

分享管理器，一键分享功能。

#### 静态方法

##### shareImage(pixelMap, context): Promise<boolean>

分享图片（显示系统分享面板）。

**参数：**

- `pixelMap`: image.PixelMap
- `context`: common.UIAbilityContext

**返回值：**

- Promise<boolean>：成功返回 true

##### shareToApp(imageUri, appName, context): Promise<boolean>

分享到指定应用。

**参数：**

- `imageUri`: 图片 URI
- `appName`: 应用名称（'wechat', 'weibo', 'qq'）
- `context`: common.UIAbilityContext

**返回值：**

- Promise<boolean>：成功返回 true

##### shareViaEmail(imageUri, context, subject?, body?): Promise<boolean>

通过邮件分享。

**参数：**

- `imageUri`: 图片 URI
- `context`: common.UIAbilityContext
- `subject`: 邮件主题（可选）
- `body`: 邮件正文（可选）

**返回值：**

- Promise<boolean>：成功返回 true

##### copyImageToClipboard(imageUri): Promise<boolean>

保存图片到系统剪贴板。

**参数：**

- `imageUri`: 图片 URI

**返回值：**

- Promise<boolean>：成功返回 true

#### 示例

```typescript
const context = getContext(this) as common.UIAbilityContext;

// 分享到微信
await ShareManager.shareToApp(this.imageUri, "wechat", context);

// 邮件分享
await ShareManager.shareViaEmail(
  this.imageUri,
  context,
  "分享图片",
  "来自鸿绘图片编辑器"
);

// 复制到剪贴板
await ShareManager.copyImageToClipboard(this.imageUri);
```

### CollaborationManager 类

协同编辑管理器，实现 WebSocket 实时通信。

#### 构造函数

```typescript
constructor(serverUrl?: string)
```

**参数：**

- `serverUrl`: WebSocket 服务器地址（可选）

#### 回调属性

| 属性名               | 类型                                     | 说明           |
| -------------------- | ---------------------------------------- | -------------- |
| onOperationReceived  | (operation: DrawingOperation) => void    | 接收到绘图操作 |
| onCollaboratorJoined | (collaborator: CollaboratorInfo) => void | 协作者加入     |
| onCollaboratorLeft   | (userId: string) => void                 | 协作者离开     |
| onCursorMoved        | (userId, x, y) => void                   | 光标移动       |
| onSyncReceived       | (operations: DrawingOperation[]) => void | 同步历史操作   |
| onError              | (error: string) => void                  | 错误回调       |

#### 方法

##### connect(sessionCode, userId, userName, userColor): Promise<boolean>

连接到协同编辑会话。

**参数：**

- `sessionCode`: 会话码
- `userId`: 用户 ID
- `userName`: 用户名
- `userColor`: 用户颜色

**返回值：**

- Promise<boolean>：连接成功返回 true

##### disconnect(): void

断开连接。

##### broadcastOperation(operation: DrawingOperation): void

广播绘图操作。

**参数：**

- `operation`: 绘图操作对象

##### broadcastUndo(): void

广播撤销操作。

##### broadcastRedo(): void

广播重做操作。

##### broadcastCursorMove(x: number, y: number): void

广播光标移动。

**参数：**

- `x`: X 坐标
- `y`: Y 坐标

##### requestSync(): void

请求同步历史操作。

##### isConnectedToSession(): boolean

检查连接状态。

**返回值：**

- true 如果已连接

#### 示例

```typescript
const manager = new CollaborationManager();

// 设置回调
manager.onOperationReceived = (operation) => {
  this.operations.push(operation);
  this.redrawCanvas();
};

manager.onCollaboratorJoined = (collaborator) => {
  this.collaborators.push(collaborator);
};

// 连接
await manager.connect("ABC123", "user1", "张三", "#FF0000");

// 广播操作
manager.broadcastOperation(operation);

// 广播光标
manager.broadcastCursorMove(100, 200);

// 断开
manager.disconnect();
```

---

## 消息协议

### CollaborationMessage 接口

协同编辑消息格式。

```typescript
interface CollaborationMessage {
  type: MessageType; // 消息类型
  sessionCode: string; // 会话码
  userId: string; // 用户ID
  userName: string; // 用户名
  userColor: string; // 用户颜色
  timestamp: number; // 时间戳
  data?: any; // 消息数据
}
```

### MessageType 枚举

```typescript
enum MessageType {
  JOIN = 'JOIN'                    // 加入会话
  LEAVE = 'LEAVE'                  // 离开会话
  DRAW = 'DRAW'                    // 绘图操作
  UNDO = 'UNDO'                    // 撤销
  REDO = 'REDO'                    // 重做
  CURSOR_MOVE = 'CURSOR_MOVE'      // 光标移动
  SYNC_REQUEST = 'SYNC_REQUEST'    // 请求同步
  SYNC_RESPONSE = 'SYNC_RESPONSE'  // 同步响应
}
```

---

## 页面路由参数

### EditorPage

| 参数名          | 类型    | 说明             |
| --------------- | ------- | ---------------- |
| imageUri        | string  | 图片 URI         |
| isCollaborative | boolean | 是否协同编辑模式 |

### CollaborativeEditorPage

| 参数名      | 类型    | 说明               |
| ----------- | ------- | ------------------ |
| imageUri    | string  | 图片 URI（主持人） |
| sessionCode | string  | 会话码             |
| userName    | string  | 用户名             |
| isHost      | boolean | 是否为主持人       |

---

## 常量定义

```typescript
// 历史记录最大数量
const MAX_HISTORY_SIZE = 50;

// Canvas默认尺寸
const DEFAULT_CANVAS_WIDTH = 800;
const DEFAULT_CANVAS_HEIGHT = 600;

// 画笔参数范围
const MIN_STROKE_WIDTH = 1;
const MAX_STROKE_WIDTH = 50;
const MIN_OPACITY = 0;
const MAX_OPACITY = 1;

// 图片调整范围
const MIN_BRIGHTNESS = -100;
const MAX_BRIGHTNESS = 100;
const MIN_CONTRAST = -100;
const MAX_CONTRAST = 100;

// 会话码长度
const SESSION_CODE_LENGTH = 6;
```

---

以上为鸿绘应用的完整 API 文档。如有疑问，请参考源代码或联系开发团队。
