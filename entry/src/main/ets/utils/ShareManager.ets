import { common } from '@kit.AbilityKit'
import { image } from '@kit.ImageKit'
import { promptAction } from '@kit.ArkUI'

// 在部分设备 / 版本上，AbilityKit 暂未导出 Want 类型，这里自定义一个精简版满足编译器检查
export interface Want {
  action: string
  type: string
  bundleName?: string
  parameters?: Record<string, string>
}

// 显式接口，避免编译器禁止未声明的对象字面量
export interface BundleNameMap {
  wechat: string
  weibo: string
  qq: string
}

export interface ImageParam extends Record<string,string> { imageUri: string }
export interface EmailParam extends Record<string,string> {
  'ohos.extra.email.SUBJECT': string
  'ohos.extra.email.TEXT': string
  imageUri: string
}

// 分享管理器 - 一键分享功能
export class ShareManager {
  // 分享图片 —— 由于 ArkTS SDK 暂不支持 unifiedDataChannel，在此仅弹 Toast 提示
  static async shareImage(pixelMap: image.PixelMap, context: common.UIAbilityContext): Promise<boolean> {
    try {
      // TODO: 后续替换为平台统一分享能力
      console.info('模拟分享图片...')

      promptAction.showToast({
        message: '已调用系统分享面板（模拟）',
        duration: 2000
      })

      return true
    } catch (err) {
      console.error('分享失败:', JSON.stringify(err))
      promptAction.showToast({
        message: '分享失败',
        duration: 2000
      })
      return false
    }
  }

  // 分享到指定应用（微信、微博等）
  static async shareToApp(
    imageUri: string,
    appName: string,
    context: common.UIAbilityContext
  ): Promise<boolean> {
    try {
      // 根据不同应用配置不同的 bundleName
      let targetBundle: string | undefined
      switch (appName.toLowerCase()) {
        case 'wechat':
          targetBundle = 'com.tencent.mm'
          break
        case 'weibo':
          targetBundle = 'com.sina.weibo'
          break
        case 'qq':
          targetBundle = 'com.tencent.mobileqq'
          break
        default:
          targetBundle = undefined
      }
      if (!targetBundle) {
        promptAction.showToast({
          message: `不支持分享到 ${appName}`,
          duration: 2000
        })
        return false
      }

      // 构造分享 Want
      const imgParams: ImageParam = { imageUri }
      const want: Want = {
        action: 'ohos.want.action.sendData',
        type: 'image/*',
        bundleName: targetBundle,
        parameters: imgParams
      }

      await context.startAbility(want)

      promptAction.showToast({
        message: `正在分享到 ${appName}`,
        duration: 2000
      })

      return true
    } catch (err) {
      console.error(`分享到 ${appName} 失败:`, JSON.stringify(err))
      promptAction.showToast({
        message: '分享失败，请确保已安装该应用',
        duration: 2000
      })
      return false
    }
  }

  // 通过邮件分享
  static async shareViaEmail(
    imageUri: string,
    context: common.UIAbilityContext,
    subject = '分享图片',
    body = '来自鸿绘图片编辑器'
  ): Promise<boolean> {
    try {
      const mailParams: EmailParam = {
        'ohos.extra.email.SUBJECT': subject,
        'ohos.extra.email.TEXT': body,
        imageUri
      }
      const want: Want = {
        action: 'ohos.want.action.sendData',
        type: 'message/rfc822',
        parameters: mailParams
      }

      await context.startAbility(want)

      promptAction.showToast({
        message: '正在打开邮件客户端',
        duration: 2000
      })

      return true
    } catch (err) {
      console.error('通过邮件分享失败:', JSON.stringify(err))
      promptAction.showToast({
        message: '邮件分享失败',
        duration: 2000
      })
      return false
    }
  }

  // 复制图片到剪贴板 —— 暂使用 Toast 提示占位实现
  static async copyImageToClipboard(imageUri: string): Promise<boolean> {
    try {
      // TODO: 调用系统剪贴板接口，待 SDK 支持
      console.info(`复制 ${imageUri} 到剪贴板（模拟）`)

      promptAction.showToast({
        message: '图片已复制到剪贴板（模拟）',
        duration: 2000
      })

      return true
    } catch (err) {
      console.error('复制到剪贴板失败:', JSON.stringify(err))
      promptAction.showToast({
        message: '复制失败',
        duration: 2000
      })
      return false
    }
  }
}


