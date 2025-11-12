import { router } from '@kit.ArkUI'
import { picker } from '@kit.CoreFileKit'
import { promptAction } from '@kit.ArkUI'

// 协同编辑页面 - 创建或加入协同编辑会话
@Entry
@Component
struct CollaborationPage {
  @State sessionCode: string = ''
  @State userName: string = ''
  @State showCreateSession: boolean = true

  // 生成随机会话码
  generateSessionCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    let code = ''
    for (let i = 0; i < 6; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length))
    }
    return code
  }

  // 创建协同会话
  async createSession() {
    if (!this.userName || this.userName.trim() === '') {
      promptAction.showToast({
        message: '请输入用户名',
        duration: 2000
      })
      return
    }

    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)

      if (result && result.photoUris && result.photoUris.length > 0) {
        const imageUri = result.photoUris[0]
        const sessionCode = this.generateSessionCode()

        // 跳转到协同编辑器
        router.pushUrl({
          url: 'pages/CollaborativeEditorPage',
          params: {
            imageUri: imageUri,
            sessionCode: sessionCode,
            userName: this.userName,
            isHost: true
          }
        })
      }
    } catch (err) {
      console.error('创建会话失败:', JSON.stringify(err))
    }
  }

  // 加入协同会话
  joinSession() {
    if (!this.userName || this.userName.trim() === '') {
      promptAction.showToast({
        message: '请输入用户名',
        duration: 2000
      })
      return
    }

    if (!this.sessionCode || this.sessionCode.trim() === '') {
      promptAction.showToast({
        message: '请输入会话码',
        duration: 2000
      })
      return
    }

    // 跳转到协同编辑器
    router.pushUrl({
      url: 'pages/CollaborativeEditorPage',
      params: {
        sessionCode: this.sessionCode.toUpperCase(),
        userName: this.userName,
        isHost: false
      }
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor('#1A1A1A')
          .onClick(() => {
            router.back()
          })

        Text('协同编辑')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .shadow({
        radius: 4,
        color: '#10000000',
        offsetY: 2
      })

      Scroll() {
        Column({ space: 24 }) {
          // 协同编辑说明
          Column({ space: 12 }) {
            Text('👥 多人实时协同编辑')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')

            Text('邀请他人一起编辑图片，实时查看编辑效果')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(22)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 用户名输入
          Column({ space: 8 }) {
            Text('用户名')
              .fontSize(14)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            TextInput({ placeholder: '请输入您的用户名' })
              .height(48)
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.userName = value
              })
          }
          .width('100%')

          // 创建/加入选项卡
          Row() {
            Button('创建会话')
              .fontSize(16)
              .fontWeight(this.showCreateSession ? FontWeight.Bold : FontWeight.Normal)
              .height(44)
              .layoutWeight(1)
              .backgroundColor(this.showCreateSession ? '#007DFF' : '#FFFFFF')
              .fontColor(this.showCreateSession ? '#FFFFFF' : '#666666')
              .onClick(() => {
                this.showCreateSession = true
              })

            Button('加入会话')
              .fontSize(16)
              .fontWeight(!this.showCreateSession ? FontWeight.Bold : FontWeight.Normal)
              .height(44)
              .layoutWeight(1)
              .backgroundColor(!this.showCreateSession ? '#007DFF' : '#FFFFFF')
              .fontColor(!this.showCreateSession ? '#FFFFFF' : '#666666')
              .onClick(() => {
                this.showCreateSession = false
              })
          }
          .width('100%')
          .borderRadius(8)
          .backgroundColor('#FFFFFF')
          .shadow({
            radius: 4,
            color: '#10000000',
            offsetY: 2
          })

          // 创建会话面板
          if (this.showCreateSession) {
            Column({ space: 16 }) {
              Column({ space: 12 }) {
                Text('📱 创建新的协同编辑会话')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')
                  .alignSelf(ItemAlign.Start)

                Text('选择一张图片开始，系统将生成会话码分享给其他人')
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .alignSelf(ItemAlign.Start)
              }

              Button('选择图片并创建会话')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .height(48)
                .width('100%')
                .backgroundColor('#007DFF')
                .borderRadius(24)
                .onClick(() => {
                  this.createSession()
                })

              // 功能说明
              Column({ space: 8 }) {
                this.FeatureItem('✓ 实时同步编辑操作')
                this.FeatureItem('✓ 显示协作者光标位置')
                this.FeatureItem('✓ 冲突自动解决')
                this.FeatureItem('✓ 支持最多5人同时编辑')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F0F7FF')
              .borderRadius(12)
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({
              radius: 8,
              color: '#10000000',
              offsetY: 2
            })
          }

          // 加入会话面板
          if (!this.showCreateSession) {
            Column({ space: 16 }) {
              Column({ space: 12 }) {
                Text('🔗 加入已有的协同编辑会话')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1A1A1A')
                  .alignSelf(ItemAlign.Start)

                Text('输入会话码即可加入他人创建的编辑会话')
                  .fontSize(14)
                  .fontColor('#666666')
                  .lineHeight(22)
                  .alignSelf(ItemAlign.Start)
              }

              Column({ space: 8 }) {
                Text('会话码')
                  .fontSize(14)
                  .fontColor('#333333')
                  .alignSelf(ItemAlign.Start)

                TextInput({ placeholder: '请输入6位会话码' })
                  .height(48)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .maxLength(6)
                  .onChange((value: string) => {
                    this.sessionCode = value.toUpperCase()
                  })
              }

              Button('加入会话')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .height(48)
                .width('100%')
                .backgroundColor('#52C41A')
                .borderRadius(24)
                .onClick(() => {
                  this.joinSession()
                })
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({
              radius: 8,
              color: '#10000000',
              offsetY: 2
            })
          }

          // 使用提示
          Column({ space: 12 }) {
            Text('💡 温馨提示')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#E6A23C')

            Text('• 确保您与协作者在同一网络环境\n• 会话码在创建后24小时内有效\n• 主持人退出后会话将自动结束\n• 所有编辑操作实时同步')
              .fontSize(13)
              .fontColor('#666666')
              .lineHeight(22)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFF9E6')
          .borderRadius(12)
          .border({ width: 1, color: '#FFE58F' })
        }
        .padding(20)
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }

  // 功能项
  @Builder
  FeatureItem(text: string) {
    Row({ space: 8 }) {
      Text(text)
        .fontSize(14)
        .fontColor('#333333')
    }
    .width('100%')
  }
}

