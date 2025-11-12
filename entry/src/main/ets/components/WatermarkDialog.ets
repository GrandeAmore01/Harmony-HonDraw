// 水印对话框组件
@CustomDialog
export struct WatermarkDialog {
  @State watermarkText: string = ''
  @State fontSize: number = 24
  @State fontColor: string = '#FFFFFF'
  @State watermarkOpacity: number = 0.8
  @State watermarkPosition: string = 'center' // 'center', 'topLeft', 'topRight', 'bottomLeft', 'bottomRight', 'repeat'
  controller!: CustomDialogController
  onConfirm?: (params: WatermarkConfirmParams) => void

  // 颜色选项
  private colors: string[] = [
    '#FFFFFF', '#000000', '#FF0000', '#00FF00', '#0000FF',
    '#FFFF00', '#FF00FF', '#00FFFF', '#FFA500', '#800080'
  ]

  // 位置选项
  private positions: PositionOption[] = [
    { label: '居中', value: 'center' },
    { label: '左上', value: 'topLeft' },
    { label: '右上', value: 'topRight' },
    { label: '左下', value: 'bottomLeft' },
    { label: '右下', value: 'bottomRight' },
    { label: '平铺', value: 'repeat' }
  ]

  build() {
    Column({ space: 20 }) {
      // 标题
      Text('添加文字水印')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      // 水印文字输入
      Column({ space: 8 }) {
        Text('水印文字')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        TextInput({ placeholder: '请输入水印文字', text: this.watermarkText })
          .height(48)
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.watermarkText = value
          })
      }
      .width('100%')

      // 字体大小
      Column({ space: 8 }) {
        Row() {
          Text('字体大小')
            .fontSize(14)
            .fontColor('#666666')
          Blank()
          Text(`${this.fontSize}px`)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')

        Slider({
          value: this.fontSize,
          min: 12,
          max: 72,
          step: 2,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E5E5E5')
          .selectedColor('#007DFF')
          .onChange((value: number) => {
            this.fontSize = value
          })
      }
      .width('100%')

      // 字体颜色
      Column({ space: 8 }) {
        Text('字体颜色')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        Grid() {
          ForEach(this.colors, (color: string) => {
            GridItem() {
              Stack() {
                Circle({ width: 36, height: 36 })
                  .fill(color)
                  .border({
                    width: this.fontColor === color ? 3 : 1,
                    color: this.fontColor === color ? '#007DFF' : '#CCCCCC'
                  })
                  .onClick(() => {
                    this.fontColor = color
                  })

                if (this.fontColor === color) {
                  Text('✓')
                    .fontSize(18)
                    .fontColor(color === '#FFFFFF' || color === '#FFFF00' ? '#000000' : '#FFFFFF')
                }
              }
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .width('100%')
      }
      .width('100%')

      // 透明度
      Column({ space: 8 }) {
        Row() {
          Text('透明度')
            .fontSize(14)
            .fontColor('#666666')
          Blank()
          Text(`${Math.round(this.watermarkOpacity * 100)}%`)
            .fontSize(14)
            .fontColor('#333333')
        }
        .width('100%')

        Slider({
          value: this.watermarkOpacity * 100,
          min: 10,
          max: 100,
          step: 5,
          style: SliderStyle.OutSet
        })
          .blockColor('#007DFF')
          .trackColor('#E5E5E5')
          .selectedColor('#007DFF')
          .onChange((value: number) => {
            this.watermarkOpacity = value / 100
          })
      }
      .width('100%')

      // 水印位置
      Column({ space: 8 }) {
        Text('水印位置')
          .fontSize(14)
          .fontColor('#666666')
          .alignSelf(ItemAlign.Start)

        Grid() {
          ForEach(this.positions, (item: PositionOption) => {
            GridItem() {
              Text(item.label)
                .fontSize(14)
                .fontColor(this.watermarkPosition === item.value ? '#FFFFFF' : '#333333')
                .fontWeight(this.watermarkPosition === item.value ? FontWeight.Medium : FontWeight.Normal)
                .width('100%')
                .height(40)
                .textAlign(TextAlign.Center)
                .backgroundColor(this.watermarkPosition === item.value ? '#007DFF' : '#F5F5F5')
                .borderRadius(6)
                .onClick(() => {
                  this.watermarkPosition = item.value
                })
            }
          })
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
      }
      .width('100%')

      // 预览
      Column() {
        Text(this.watermarkText || '水印预览')
          .fontSize(this.fontSize)
          .fontColor(this.fontColor)
          .opacity(this.watermarkOpacity)
      }
      .width('100%')
      .height(100)
      .backgroundColor('#F0F0F0')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)

      // 操作按钮
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(16)
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close()
          })

        Button('确定')
          .fontSize(16)
          .height(44)
          .layoutWeight(1)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .onClick(() => {
            if (this.onConfirm && this.watermarkText.trim() !== '') {
              this.onConfirm({
                text: this.watermarkText,
                fontSize: this.fontSize,
                fontColor: this.fontColor,
                opacity: this.watermarkOpacity,
                position: this.watermarkPosition
              })
            }
            this.controller.close()
          })
      }
      .width('100%')
    }
    .padding(24)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }
}

// 对外暴露的回调 / 位置选项接口
export interface WatermarkConfirmParams {
  text: string
  fontSize: number
  fontColor: string
  opacity: number
  position: string
}

export interface PositionOption {
  label: string
  value: string
}


