// 裁剪面板组件
@Component
export struct CropPanel {
  @Link cropX: number
  @Link cropY: number
  @Link cropWidth: number
  @Link cropHeight: number
  @State selectedAspectRatio: string = 'free' // 'free', '1:1', '4:3', '16:9'
  onConfirm?: () => void
  onCancel?: () => void

  // 预设宽高比
  private aspectRatios: AspectRatioOption[] = [
    { label: '自由', value: 'free', ratio: 0 },
    { label: '1:1', value: '1:1', ratio: 1 },
    { label: '4:3', value: '4:3', ratio: 4 / 3 },
    { label: '16:9', value: '16:9', ratio: 16 / 9 },
    { label: '3:4', value: '3:4', ratio: 3 / 4 },
    { label: '9:16', value: '9:16', ratio: 9 / 16 }
  ]

  // 应用宽高比
  applyAspectRatio(ratio: number) {
    if (ratio === 0) return // 自由裁剪

    // 根据当前宽度计算高度
    const newHeight = this.cropWidth / ratio
    this.cropHeight = Math.round(newHeight)
  }

  build() {
    Column({ space: 16 }) {
      // 标题
      Row() {
        Text('裁剪图片')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        Text('×')
          .fontSize(24)
          .fontColor('#999999')
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel()
            }
          })
      }
      .width('100%')

      Divider()

      // 宽高比选择
      Column({ space: 8 }) {
        Text('宽高比')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        Grid() {
          ForEach(this.aspectRatios, (item: AspectRatioOption) => {
            GridItem() {
              Text(item.label)
                .fontSize(14)
                .fontColor(this.selectedAspectRatio === item.value ? '#FFFFFF' : '#333333')
                .fontWeight(this.selectedAspectRatio === item.value ? FontWeight.Medium : FontWeight.Normal)
                .width('100%')
                .height(36)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.selectedAspectRatio === item.value ? '#007DFF' : '#F5F5F5')
                .borderRadius(6)
                .onClick(() => {
                  this.selectedAspectRatio = item.value
                  this.applyAspectRatio(item.ratio)
                })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
      }

      Divider()

      // 裁剪区域尺寸
      Column({ space: 12 }) {
        Text('裁剪区域')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        // X坐标
        Row() {
          Text('X:')
            .fontSize(14)
            .fontColor('#333333')
            .width(60)

          Slider({
            value: this.cropX,
            min: 0,
            max: 500,
            step: 1,
            style: SliderStyle.OutSet
          })
            .blockColor('#007DFF')
            .trackColor('#E5E5E5')
            .selectedColor('#007DFF')
            .layoutWeight(1)
            .onChange((value: number) => {
              this.cropX = Math.round(value)
            })

          Text(`${this.cropX}`)
            .fontSize(14)
            .fontColor('#666666')
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')

        // Y坐标
        Row() {
          Text('Y:')
            .fontSize(14)
            .fontColor('#333333')
            .width(60)

          Slider({
            value: this.cropY,
            min: 0,
            max: 500,
            step: 1,
            style: SliderStyle.OutSet
          })
            .blockColor('#007DFF')
            .trackColor('#E5E5E5')
            .selectedColor('#007DFF')
            .layoutWeight(1)
            .onChange((value: number) => {
              this.cropY = Math.round(value)
            })

          Text(`${this.cropY}`)
            .fontSize(14)
            .fontColor('#666666')
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')

        // 宽度
        Row() {
          Text('宽度:')
            .fontSize(14)
            .fontColor('#333333')
            .width(60)

          Slider({
            value: this.cropWidth,
            min: 50,
            max: 800,
            step: 1,
            style: SliderStyle.OutSet
          })
            .blockColor('#007DFF')
            .trackColor('#E5E5E5')
            .selectedColor('#007DFF')
            .layoutWeight(1)
            .onChange((value: number) => {
              this.cropWidth = Math.round(value)
              // 如果有固定宽高比，同时调整高度
              const currentRatio = this.aspectRatios.find(r => r.value === this.selectedAspectRatio)
              if (currentRatio && currentRatio.ratio > 0) {
                this.applyAspectRatio(currentRatio.ratio)
              }
            })

          Text(`${this.cropWidth}`)
            .fontSize(14)
            .fontColor('#666666')
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')

        // 高度
        Row() {
          Text('高度:')
            .fontSize(14)
            .fontColor('#333333')
            .width(60)

          Slider({
            value: this.cropHeight,
            min: 50,
            max: 800,
            step: 1,
            style: SliderStyle.OutSet
          })
            .blockColor('#007DFF')
            .trackColor('#E5E5E5')
            .selectedColor('#007DFF')
            .layoutWeight(1)
            .enabled(this.selectedAspectRatio === 'free') // 固定宽高比时禁用
            .onChange((value: number) => {
              this.cropHeight = Math.round(value)
            })

          Text(`${this.cropHeight}`)
            .fontSize(14)
            .fontColor('#666666')
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')
      }

      Divider()

      // 操作按钮
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(16)
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .onClick(() => {
            if (this.onCancel) {
              this.onCancel()
            }
          })

        Button('确认裁剪')
          .fontSize(16)
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .onClick(() => {
            if (this.onConfirm) {
              this.onConfirm()
            }
          })
      }
      .width('100%')
    }
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}

// 供外部复用的宽高比选项接口
export interface AspectRatioOption {
  label: string
  value: string
  ratio: number
}


