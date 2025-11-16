import { fileIo } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'

/**
 * 将相册/媒体库返回的 file://media/... URI 复制到应用缓存，
 * 返回可被 image.createImageSource 读取的真实文件路径（file:///xxx）。
 */
export async function copyPhotoToCache(mediaUri: string): Promise<string | null> {
  try {
    const context: common.UIAbilityContext = getContext() as common.UIAbilityContext
    
    // 尝试多种路径转换方式
    let filePath: string = mediaUri
    
    // 1. 去掉 file:// 前缀
    if (filePath.startsWith('file://')) {
      filePath = filePath.substring('file://'.length)
    }
    
    // 2. 如果路径是 /media/... 开头，尝试转换为 /storage/media/...
    if (filePath.startsWith('/media/')) {
      filePath = '/storage' + filePath
      console.info('[UriResolver] 转换路径为:', filePath)
    } else if (filePath.startsWith('media/')) {
      filePath = '/storage/' + filePath
      console.info('[UriResolver] 转换路径为:', filePath)
    }
    
    // 3. 尝试打开文件，如果失败则尝试备用路径
    let file: fileIo.File | null = null
    try {
      file = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY)
    } catch (openErr) {
      console.warn('[UriResolver] 无法打开文件:', filePath)
      // 尝试其他可能的路径
      if (filePath.includes('/media/')) {
        const altPath = filePath.replace('/storage/media/', '/storage/emulated/0/')
        try {
          file = fileIo.openSync(altPath, fileIo.OpenMode.READ_ONLY)
          filePath = altPath
          console.info('[UriResolver] 使用备用路径:', filePath)
        } catch {
          // 如果还是失败，返回 null
          console.error('[UriResolver] 所有路径尝试均失败')
          return null
        }
      } else {
        return null
      }
    }
    
    if (!file) {
      return null
    }
    
    // 4. 读取文件内容
    const stat = fileIo.statSync(filePath)
    const bytes = new Uint8Array(stat.size)
    fileIo.readSync(file.fd, bytes)
    fileIo.closeSync(file)
    
    // 5. 写入缓存目录
    const cachePath: string = `${context.cacheDir}/import_${Date.now()}.jpg`
    const cacheFile: fileIo.File = fileIo.openSync(cachePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
    fileIo.writeSync(cacheFile.fd, bytes)
    fileIo.closeSync(cacheFile)
    
    const realPath = `file://${cachePath}`
    console.info('[UriResolver] 已复制到缓存:', realPath)
    return realPath
  } catch (err) {
    console.error('[UriResolver] 复制失败:', JSON.stringify(err))
    return null
  }
}
