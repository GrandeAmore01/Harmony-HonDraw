// 画笔设置组件
@Component
export struct BrushSettings {
  @Link strokeWidth: number
  @Link brushOpacity: number  // 改名避免与系统属性冲突

  build() {
    Column({ space: 16 }) {
      // 画笔粗细
      Column({ space: 8 }) {
        Row() {
          Text('粗细')
            .fontSize(14)
            .fontColor('#333333')
          Blank()
          Text(`${this.strokeWidth.toFixed(0)}px`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')

        Slider({
          value: this.strokeWidth,
          min: 1,
          max: 50,
          step: 1,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E5E5E5')
          .selectedColor('#007DFF')
          .showTips(false)
          .onChange((value: number) => {
            this.strokeWidth = value
          })
      }

      // 透明度
      Column({ space: 8 }) {
        Row() {
          Text('透明度')
            .fontSize(14)
            .fontColor('#333333')
          Blank()
          Text(`${Math.round(this.brushOpacity * 100)}%`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')

        Slider({
          value: this.brushOpacity * 100,
          min: 0,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E5E5E5')
          .selectedColor('#007DFF')
          .showTips(false)
          .onChange((value: number) => {
            this.brushOpacity = value / 100
          })
      }
    }
    .padding(16)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}

