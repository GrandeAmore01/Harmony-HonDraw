import { ToolType, ToolbarItem } from '../model/ToolbarItem'

// 编辑器工具栏组件
@Component
export struct EditorToolbar {
  @Link selectedTool: ToolType
  onToolSelected?: (tool: ToolType) => void

  private tools: ToolbarItem[] = [
    new ToolbarItem(ToolType.PEN, '✏️', '画笔'),
    new ToolbarItem(ToolType.ERASER, '🧹', '橡皮'),
    new ToolbarItem(ToolType.LINE, '📏', '直线'),
    new ToolbarItem(ToolType.RECT, '▢', '矩形'),
    new ToolbarItem(ToolType.CIRCLE, '○', '圆形'),
    new ToolbarItem(ToolType.ELLIPSE, '⬭', '椭圆'),
    new ToolbarItem(ToolType.TEXT, '𝐓', '文字'),
    new ToolbarItem(ToolType.CROP, '✂️', '裁剪'),
    new ToolbarItem(ToolType.ROTATE, '↻', '旋转'),
    new ToolbarItem(ToolType.BRIGHTNESS, '☀️', '亮度'),
    new ToolbarItem(ToolType.WATERMARK, '🏷️', '水印')
  ]

  build() {
    Row() {
      List({ space: 12 }) {
        ForEach(this.tools, (tool: ToolbarItem) => {
          ListItem() {
            Column({ space: 4 }) {
              Text(tool.icon)
                .fontSize(24)

              Text(tool.label)
                .fontSize(10)
                .fontColor(this.selectedTool === tool.type ? '#007DFF' : '#666666')
            }
            .width(60)
            .height(60)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedTool === tool.type ? '#E6F2FF' : '#FFFFFF')
            .borderRadius(8)
            .border({
              width: this.selectedTool === tool.type ? 2 : 1,
              color: this.selectedTool === tool.type ? '#007DFF' : '#E5E5E5'
            })
            .onClick(() => {
              this.selectedTool = tool.type
              if (this.onToolSelected) {
                this.onToolSelected(tool.type)
              }
            })
          }
        })
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(80)
      .padding({ left: 8, right: 8 })
    }
    .width('100%')
    .height(80)
    .backgroundColor('#FAFAFA')
    .shadow({
      radius: 8,
      color: '#10000000',
      offsetY: -2
    })
  }
}

