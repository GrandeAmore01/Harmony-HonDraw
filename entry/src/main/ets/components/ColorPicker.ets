// 颜色选择器组件 (避免与系统组件重名，改名为CustomColorPicker)
@Component
export struct CustomColorPicker {
  @Link selectedColor: string
  private colors: string[] = [
    '#000000', '#FFFFFF', '#FF0000', '#00FF00', '#0000FF',
    '#FFFF00', '#FF00FF', '#00FFFF', '#FFA500', '#800080'
  ]

  build() {
    Column() {
      Text('选择颜色')
        .fontSize(14)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Grid() {
        ForEach(this.colors, (color: string) => {
          GridItem() {
            Stack() {
              Circle({ width: 32, height: 32 })
                .fill(color)
                .border({
                  width: this.selectedColor === color ? 3 : 1,
                  color: this.selectedColor === color ? '#007DFF' : '#CCCCCC'
                })
                .onClick(() => {
                  this.selectedColor = color
                })

              if (this.selectedColor === color) {
                Text('✓')
                  .fontSize(16)
                  .fontColor(color === '#FFFFFF' || color === '#FFFF00' ? '#000000' : '#FFFFFF')
              }
            }
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsGap(8)
      .columnsGap(8)
      .width('100%')
    }
    .padding(16)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}

// 兼容旧引用
export const ColorPicker = CustomColorPicker

