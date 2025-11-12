import { fileIo } from '@kit.CoreFileKit'
import { picker } from '@kit.CoreFileKit'
import { image } from '@kit.ImageKit'
import { common } from '@kit.AbilityKit'

// 图片管理器 - 处理图片的打开、保存、加载
export class ImageManager {
  // 打开图片
  static async openImage(): Promise<string | null> {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions()
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1

      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.select(photoSelectOptions)

      if (result && result.photoUris && result.photoUris.length > 0) {
        return result.photoUris[0]
      }
      return null
    } catch (err) {
      console.error('打开图片失败:', JSON.stringify(err))
      return null
    }
  }

  // 保存图片到相册
  static async saveImageToGallery(pixelMap: image.PixelMap, fileName: string): Promise<boolean> {
    try {
      // 创建ImagePacker
      const imagePackerApi = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 95
      }

      // 打包PixelMap为buffer
      const data = await imagePackerApi.packing(pixelMap, packOpts)

      // 使用PhotoAccessHelper保存到相册
      const context = getContext() as common.UIAbilityContext
      const fileUri = await ImageManager.saveToAlbum(context, data, fileName)

      return fileUri !== null
    } catch (err) {
      console.error('保存图片失败:', JSON.stringify(err))
      return false
    }
  }

  // 保存到相册
  private static async saveToAlbum(
    context: common.UIAbilityContext,
    data: ArrayBuffer,
    fileName: string
  ): Promise<string | null> {
    try {
      // 使用FilePicker保存
      const photoSaveOptions = new picker.PhotoSaveOptions()
      photoSaveOptions.newFileNames = [fileName]

      const photoPicker = new picker.PhotoViewPicker()
      const result = await photoPicker.save(photoSaveOptions)

      if (result && result.length > 0) {
        const fileUri = result[0]
        // 写入文件内容
        const file = fileIo.openSync(fileUri, fileIo.OpenMode.WRITE_ONLY)
        fileIo.writeSync(file.fd, data)
        fileIo.closeSync(file)
        return fileUri
      }
      return null
    } catch (err) {
      console.error('保存到相册失败:', JSON.stringify(err))
      return null
    }
  }

  // 加载图片到PixelMap
  static async loadImagePixelMap(uri: string): Promise<image.PixelMap | null> {
    try {
      const imageSource = image.createImageSource(uri)
      const pixelMap = await imageSource.createPixelMap()
      return pixelMap
    } catch (err) {
      console.error('加载图片失败:', JSON.stringify(err))
      return null
    }
  }

  // 获取图片尺寸
  export interface ImageSize { width: number; height: number }

  static async getImageSize(uri: string): Promise<ImageSize | null> {
    try {
      const imageSource = image.createImageSource(uri)
      const imageInfo = await imageSource.getImageInfo()
      const size: ImageSize = {
        width: imageInfo.size.width,
        height: imageInfo.size.height
      }
      return size
    } catch (err) {
      console.error('获取图片尺寸失败:', JSON.stringify(err))
      return null
    }
  }
}


