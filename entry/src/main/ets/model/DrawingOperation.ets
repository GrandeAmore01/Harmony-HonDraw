// 坐标点接口
export interface Point {
  x: number
  y: number
}

// 绘图操作类型枚举
export enum OperationType {
  DRAW_LINE = 'DRAW_LINE',
  DRAW_RECT = 'DRAW_RECT',
  DRAW_CIRCLE = 'DRAW_CIRCLE',
  DRAW_ELLIPSE = 'DRAW_ELLIPSE',
  DRAW_PATH = 'DRAW_PATH',
  DRAW_TEXT = 'DRAW_TEXT',
  CROP = 'CROP',
  ROTATE = 'ROTATE',
  ADJUST_BRIGHTNESS = 'ADJUST_BRIGHTNESS',
  ADJUST_CONTRAST = 'ADJUST_CONTRAST',
  ERASER = 'ERASER'
}

// 绘图操作数据模型
export class DrawingOperation {
  id: string = ''
  type: OperationType = OperationType.DRAW_LINE
  color: string = '#000000'
  strokeWidth: number = 2
  opacityValue: number = 1.0  // 改名避免与系统属性冲突
  points: Array<Point> = []
  text?: string
  timestamp: number = Date.now()
  userId?: string // 协同编辑时标识用户
  userName?: string
  userColor?: string // 用户标识颜色

  constructor(type: OperationType) {
    this.type = type
    this.id = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
  }
}

// 图片调整参数
export class ImageAdjustment {
  brightness: number = 0 // -100 到 100
  contrast: number = 0 // -100 到 100
  rotation: number = 0 // 0, 90, 180, 270
  scale: number = 1.0
  offsetX: number = 0
  offsetY: number = 0
}

// 用户信息
export class CollaboratorInfo {
  userId: string = ''
  userName: string = ''
  userColor: string = '#FF0000'
  cursorX: number = 0
  cursorY: number = 0
  isDrawing: boolean = false
  currentOperation?: DrawingOperation
}

