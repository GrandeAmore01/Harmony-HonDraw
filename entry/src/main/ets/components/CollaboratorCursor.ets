import { CollaboratorInfo } from '../model/DrawingOperation'

// 协作者光标组件
@Component
export struct CollaboratorCursor {
  @Prop collaborator: CollaboratorInfo

  build() {
    Stack() {
      // 光标指针
      Path()
        .width(20)
        .height(20)
        .commands(`M 0 0 L 0 16 L 4 12 L 7 18 L 9 17 L 6 11 L 12 10 Z`)
        .fillOpacity(1)
        .fill(this.collaborator.userColor)
        .stroke(this.collaborator.userColor)
        .strokeWidth(1)

      // 用户名标签
      Text(this.collaborator.userName)
        .fontSize(10)
        .fontColor('#FFFFFF')
        .backgroundColor(this.collaborator.userColor)
        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
        .borderRadius(4)
        .position({ x: 22, y: 0 })

      // 正在绘制指示
      if (this.collaborator.isDrawing) {
        Text('正在绘制...')
          .fontSize(9)
          .fontColor('#666666')
          .backgroundColor('#FFFFFF')
          .padding({ left: 4, right: 4, top: 2, bottom: 2 })
          .borderRadius(4)
          .border({ width: 1, color: '#E5E5E5' })
          .position({ x: 22, y: 20 })
      }
    }
    .width(120)
    .height(60)
    .position({ x: this.collaborator.cursorX, y: this.collaborator.cursorY })
  }
}

