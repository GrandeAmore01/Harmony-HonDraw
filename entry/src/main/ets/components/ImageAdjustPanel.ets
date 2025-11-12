// 图片调整面板
@Component
export struct ImageAdjustPanel {
  @Link imageBrightness: number  // 改名避免与系统属性冲突
  @Link imageContrast: number    // 改名避免与系统属性冲突
  onRotate?: () => void

  build() {
    Column({ space: 16 }) {
      // 旋转按钮
      Row({ space: 12 }) {
        Text('旋转')
          .fontSize(14)
          .fontColor('#333333')
        Button('旋转90°')
          .fontSize(14)
          .height(36)
          .backgroundColor('#007DFF')
          .onClick(() => {
            if (this.onRotate) {
              this.onRotate()
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()

      // 亮度调节
      Column({ space: 8 }) {
        Row() {
          Text('亮度')
            .fontSize(14)
            .fontColor('#333333')
          Blank()
          Text(`${this.imageBrightness > 0 ? '+' : ''}${this.imageBrightness.toFixed(0)}`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')

        Slider({
          value: this.imageBrightness,
          min: -100,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E5E5E5')
          .selectedColor('#007DFF')
          .showTips(false)
          .onChange((value: number) => {
            this.imageBrightness = value
          })
      }

      // 对比度调节
      Column({ space: 8 }) {
        Row() {
          Text('对比度')
            .fontSize(14)
            .fontColor('#333333')
          Blank()
          Text(`${this.imageContrast > 0 ? '+' : ''}${this.imageContrast.toFixed(0)}`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')

        Slider({
          value: this.imageContrast,
          min: -100,
          max: 100,
          step: 1,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E5E5E5')
          .selectedColor('#007DFF')
          .showTips(false)
          .onChange((value: number) => {
            this.imageContrast = value
          })
      }
    }
    .padding(16)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}

