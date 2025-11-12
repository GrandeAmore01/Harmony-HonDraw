// 工具栏项目类型
export enum ToolType {
  NONE = 'NONE',
  PEN = 'PEN',
  ERASER = 'ERASER',
  LINE = 'LINE',
  RECT = 'RECT',
  CIRCLE = 'CIRCLE',
  ELLIPSE = 'ELLIPSE',
  TEXT = 'TEXT',
  CROP = 'CROP',
  ROTATE = 'ROTATE',
  BRIGHTNESS = 'BRIGHTNESS',
  CONTRAST = 'CONTRAST',
  WATERMARK = 'WATERMARK'
}

// 工具栏项目模型
export class ToolbarItem {
  type: ToolType
  icon: string
  label: string
  selected: boolean = false

  constructor(type: ToolType, icon: string, label: string) {
    this.type = type
    this.icon = icon
    this.label = label
  }
}

