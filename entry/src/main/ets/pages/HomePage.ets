import { router } from '@kit.ArkUI'
import { picker } from '@kit.CoreFileKit'

// 主页 - 图片库
@Entry
@Component
struct HomePage {
  @State recentImages: string[] = []
  @State showTips: boolean = true

  // 选择图片
  async selectImage() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)

      if (result && result.photoUris && result.photoUris.length > 0) {
        const imageUri = result.photoUris[0]
        // 跳转到编辑器页面
        router.pushUrl({
          url: 'pages/EditorPage',
          params: {
            imageUri: imageUri,
            isCollaborative: false
          }
        })
      }
    } catch (err) {
      console.error('选择图片失败:', JSON.stringify(err))
    }
  }

  // 开启协同编辑
  startCollaboration() {
    router.pushUrl({
      url: 'pages/CollaborationPage'
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('鸿绘')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Blank()

        Button('协同编辑')
          .fontSize(14)
          .backgroundColor('#007DFF')
          .borderRadius(20)
          .height(40)
          .onClick(() => {
            this.startCollaboration()
          })
      }
      .width('100%')
      .height(60)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 20 }) {
          // 欢迎卡片
          Column({ space: 16 }) {
            Text('欢迎使用鸿绘图片编辑器')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')

            Text('专业的图片编辑工具，支持多人协同创作')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .opacity(0.9)

            Button('开始编辑')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#FFFFFF')
              .fontColor('#007DFF')
              .borderRadius(24)
              .height(48)
              .width(160)
              .onClick(() => {
                this.selectImage()
              })
          }
          .width('100%')
          .padding(24)
          .borderRadius(16)
          .linearGradient({
            angle: 135,
            colors: [[0x007DFF, 0.0], [0x0A59F7, 1.0]]
          })

          // 功能卡片
          Column({ space: 12 }) {
            Text('主要功能')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .alignSelf(ItemAlign.Start)

            Grid() {
              GridItem() {
                this.FeatureCard('✏️', '绘图', '自由绘制线条和形状')
              }
              GridItem() {
                this.FeatureCard('✂️', '裁剪', '裁剪和调整图片')
              }
              GridItem() {
                this.FeatureCard('☀️', '调节', '亮度和对比度')
              }
              GridItem() {
                this.FeatureCard('🏷️', '水印', '添加文字水印')
              }
              GridItem() {
                this.FeatureCard('↻', '旋转', '旋转和翻转')
              }
              GridItem() {
                this.FeatureCard('👥', '协同', '多人实时编辑')
              }
            }
            .columnsTemplate('1fr 1fr 1fr')
            .rowsGap(12)
            .columnsGap(12)
            .width('100%')
          }
          .width('100%')

          // 最近编辑
          if (this.recentImages.length > 0) {
            Column({ space: 12 }) {
              Text('最近编辑')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .alignSelf(ItemAlign.Start)

              List({ space: 12 }) {
                ForEach(this.recentImages, (image: string, index: number) => {
                  ListItem() {
                    Row({ space: 12 }) {
                      Image(image)
                        .width(80)
                        .height(80)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)

                      Column({ space: 4 }) {
                        Text(`图片 ${index + 1}`)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#1A1A1A')

                        Text('最近编辑')
                          .fontSize(12)
                          .fontColor('#999999')
                      }
                      .alignItems(HorizontalAlign.Start)

                      Blank()

                      Button('继续编辑')
                        .fontSize(14)
                        .height(32)
                        .backgroundColor('#007DFF')
                    }
                    .width('100%')
                    .padding(12)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(12)
                    .shadow({
                      radius: 8,
                      color: '#10000000',
                      offsetY: 2
                    })
                  }
                })
              }
              .width('100%')
            }
            .width('100%')
          }

          // 使用提示
          if (this.showTips) {
            Column({ space: 12 }) {
              Row() {
                Text('💡 使用提示')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')

                Blank()

                Text('×')
                  .fontSize(20)
                  .fontColor('#999999')
                  .onClick(() => {
                    this.showTips = false
                  })
              }
              .width('100%')

              Text('• 点击"开始编辑"选择图片开始创作\n• 使用"协同编辑"邀请他人一起编辑\n• 支持撤销/重做功能\n• 编辑完成后可一键分享')
                .fontSize(14)
                .fontColor('#666666')
                .lineHeight(22)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFF9E6')
            .borderRadius(12)
            .border({ width: 1, color: '#FFE58F' })
          }
        }
        .padding(20)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }

  // 功能卡片组件
  @Builder
  FeatureCard(icon: string, title: string, desc: string) {
    Column({ space: 8 }) {
      Text(icon)
        .fontSize(32)

      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')

      Text(desc)
        .fontSize(10)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height(120)
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .justifyContent(FlexAlign.Center)
    .shadow({
      radius: 8,
      color: '#10000000',
      offsetY: 2
    })
  }
}

