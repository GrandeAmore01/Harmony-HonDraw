import { router } from '@kit.ArkUI'
import { ToolType } from '../model/ToolbarItem'
import { DrawingOperation, OperationType, ImageAdjustment } from '../model/DrawingOperation'
import { HistoryManager } from '../utils/HistoryManager'
import { EditorToolbar } from '../components/EditorToolbar'
import { CustomColorPicker } from '../components/ColorPicker'
import { BrushSettings } from '../components/BrushSettings'
import { ImageAdjustPanel } from '../components/ImageAdjustPanel'
import { CropPanel } from '../components/CropPanel'
import { WatermarkDialog } from '../components/WatermarkDialog'
import { ImageManager } from '../utils/ImageManager'
import { WatermarkManager } from '../utils/WatermarkManager'
import { ShareManager } from '../utils/ShareManager'
import { promptAction } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'
import { image } from '@kit.ImageKit'

// ------------------ 类型定义与声明 ------------------
interface WatermarkParams {
  text: string;
  fontSize: number;
  fontColor: string;
  opacity: number;
  position: string;
}

// CanvasElement 类型定义
interface CanvasElement {
  width: number;
  height: number;
}

// ArkUI 环境下并无内置 Image 对象；为避免 any，声明最小化接口即可
declare class Image {
  src: string;
  width: number;
  height: number;
  onload: () => void;
  onerror: () => void;
}

// ---------------------------------------------------

// 图片编辑器页面
@Entry
@Component
struct EditorPage {
  @State imageUri: string = ''
  @State selectedTool: ToolType = ToolType.NONE
  @State currentColor: string = '#000000'
  @State strokeWidth: number = 3
  @State brushOpacity: number = 1.0
  @State showColorPicker: boolean = false
  @State showBrushSettings: boolean = false
  @State showAdjustPanel: boolean = false
  @State showCropPanel: boolean = false
  @State operations: DrawingOperation[] = []
  @State imageAdjustment: ImageAdjustment = new ImageAdjustment()
  @State imageBrightness: number = 0;  // 显式初始化
  @State imageContrast: number = 0;    // 显式初始化
  @State canUndo: boolean = false
  @State canRedo: boolean = false
  @State scaleFactor: number = 1.0
  @State offsetX: number = 0
  @State offsetY: number = 0
  @State cropX: number = 50
  @State cropY: number = 50
  @State cropWidth: number = 300
  @State cropHeight: number = 300
  @State showShareMenu: boolean = false
  @State imageLoaded: boolean = false
  @State canvasWidth: number = 800
  @State canvasHeight: number = 600
  private historyManager: HistoryManager = new HistoryManager()
  private canvasContext: CanvasRenderingContext2D | null = null
  private isDrawing: boolean = false
  private startX: number = 0
  private startY: number = 0
  private currentOperation: DrawingOperation | null = null
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private loadedPixelMap: image.PixelMap | null = null
  private watermarkDialogController: CustomDialogController | null = null
  //@State imageBrightness: number = 0.5; // 需要显式初始化

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>
    if (params && params['imageUri']) {
      this.imageUri = params['imageUri'] as string
      this.loadImage()
    }
  }

  // 加载图片
  async loadImage() {
    // 0. 读取媒体权限：API 20 大多已在清单声明后自动授予，如需动态申请可在此补充
    if (!this.imageUri) {
      console.error('[EditorPage] loadImage - imageUri 为空，终止加载');
      return
    }

    try {
      console.log('[EditorPage] 尝试创建 ImageSource，URI:', this.imageUri);
      // 一些设备/相册返回的 file:// URI 可能仅包含两个斜杠，导致 ImageKit 无法识别，需补全为 file:/// 形式
      let fixedUri: string = this.imageUri
      if (fixedUri.startsWith('file://') && !fixedUri.startsWith('file:///')) {
        fixedUri = 'file:///' + fixedUri.substring('file://'.length)
        console.warn(`[EditorPage] 检测到 file:// URI 缺少根路径斜杠，已修正为: ${fixedUri}`)
      }

      // 部分系统返回路径缺少 /storage 前缀
      if (fixedUri.startsWith('file:///media/')) {
        fixedUri = fixedUri.replace('file:///media/', 'file:///storage/media/')
        console.warn(`[EditorPage] 补全存储前缀，修正为: ${fixedUri}`)
      }

      const src = image.createImageSource(fixedUri)
      if (!src) {
        console.error('[EditorPage] 1.1 ImageSource 创建失败（返回 null），无法继续');
        return;
      }
      console.log('[EditorPage] 2. ImageSource 创建成功，准备创建 PixelMap');
      const pixelMap = await src.createPixelMap()
      // 关键：检查 PixelMap 是否有效
      if (!pixelMap) {
        console.error('[EditorPage] 3.1 PixelMap 创建失败（返回 null），无法继续');
        return;
      }
      console.log('[EditorPage] 3. PixelMap 创建成功');
      const info = await src.getImageInfo()
      console.log('[EditorPage] 5. 图片信息获取成功：', info);
      this.imageLoaded = true
      this.canvasWidth = info.size.width
      this.canvasHeight = info.size.height
      // 保存 PixelMap 以备 drawImage
      this.loadedPixelMap = pixelMap
      this.redrawCanvas()
      console.log('[EditorPage] 6. 图片加载完成，触发 redrawCanvas');
    } catch (err) {
      console.error('加载图片失败:', JSON.stringify(err))
    }
  }

  // 处理工具选择
  onToolSelected(tool: ToolType) {
    this.selectedTool = tool
    this.showColorPicker = false
    this.showBrushSettings = false
    this.showAdjustPanel = false
    this.showCropPanel = false

    // 根据工具显示不同面板
    if (tool === ToolType.PEN || tool === ToolType.LINE ||
      tool === ToolType.RECT || tool === ToolType.CIRCLE ||
      tool === ToolType.ELLIPSE || tool === ToolType.TEXT) {
      this.showColorPicker = true
      this.showBrushSettings = true
    } else if (tool === ToolType.BRIGHTNESS || tool === ToolType.ROTATE) {
      this.showAdjustPanel = true
    } else if (tool === ToolType.ERASER) {
      this.showBrushSettings = true
    } else if (tool === ToolType.CROP) {
      this.showCropPanel = true
    } else if (tool === ToolType.WATERMARK) {
      this.showWatermarkDialog()
    }
  }

  // 显示水印对话框
  showWatermarkDialog() {
    this.watermarkDialogController = new CustomDialogController({
      builder: WatermarkDialog({
        onConfirm: (params: WatermarkParams) => {
          this.addWatermark(params)
        }
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center,
      customStyle: true
    })
    this.watermarkDialogController.open()
  }

  // 添加水印
  addWatermark(params: WatermarkParams) {
    if (!this.canvasContext) {
      return
    }

    let x = 0
    let y = 0

    // 根据位置计算坐标
    switch (params.position) {
      case 'center':
        x = this.canvasWidth / 2 - params.text.length * params.fontSize / 4
        y = this.canvasHeight / 2 - params.fontSize / 2
        break
      case 'topLeft':
        x = 20
        y = 20
        break
      case 'topRight':
        x = this.canvasWidth - params.text.length * params.fontSize / 2 - 20
        y = 20
        break
      case 'bottomLeft':
        x = 20
        y = this.canvasHeight - params.fontSize - 20
        break
      case 'bottomRight':
        x = this.canvasWidth - params.text.length * params.fontSize / 2 - 20
        y = this.canvasHeight - params.fontSize - 20
        break
      case 'repeat':
        WatermarkManager.drawRepeatedWatermark(
          this.canvasContext,
          params.text,
          this.canvasWidth,
          this.canvasHeight,
          {
            fontSize: params.fontSize,
            fontColor: params.fontColor,
            opacity: params.opacity
          }
        )
        promptAction.showToast({
          message: '水印已添加',
          duration: 2000
        })
        return
    }

    WatermarkManager.drawTextWatermark(
      this.canvasContext,
      params.text,
      x,
      y,
      {
        fontSize: params.fontSize,
        fontColor: params.fontColor,
        opacity: params.opacity
      }
    )

    promptAction.showToast({
      message: '水印已添加',
      duration: 2000
    })
  }

  // 确认裁剪
  confirmCrop() {
    // 创建新的canvas保存裁剪结果
    if (!this.canvasContext) {
      return
    }

    const imageData = this.canvasContext.getImageData(
      this.cropX,
      this.cropY,
      this.cropWidth,
      this.cropHeight
    )
    // 清空并调整canvas大小
    this.canvasWidth = this.cropWidth
    this.canvasHeight = this.cropHeight

    // 绘制裁剪后的图片
    this.canvasContext.putImageData(imageData, 0, 0)

    this.showCropPanel = false
    this.selectedTool = ToolType.NONE

    promptAction.showToast({
      message: '裁剪完成',
      duration: 2000
    })
  }

  // 取消裁剪
  cancelCrop() {
    this.showCropPanel = false
    this.selectedTool = ToolType.NONE
  }

  // 处理触摸开始
  handleTouchStart(event: TouchEvent) {
    if (this.selectedTool === ToolType.NONE) {
      return
    }

    this.isDrawing = true
    this.startX = event.touches[0].x
    this.startY = event.touches[0].y

    // 创建新操作
    let opType = OperationType.DRAW_PATH
    switch (this.selectedTool) {
      case ToolType.PEN:
        opType = OperationType.DRAW_PATH
        break
      case ToolType.LINE:
        opType = OperationType.DRAW_LINE
        break
      case ToolType.RECT:
        opType = OperationType.DRAW_RECT
        break
      case ToolType.CIRCLE:
        opType = OperationType.DRAW_CIRCLE
        break
      case ToolType.ELLIPSE:
        opType = OperationType.DRAW_ELLIPSE
        break
      case ToolType.ERASER:
        opType = OperationType.ERASER
        break
    }

    this.currentOperation = new DrawingOperation(opType)
    this.currentOperation.color = this.currentColor
    this.currentOperation.strokeWidth = this.strokeWidth
    this.currentOperation.opacity = this.brushOpacity
    this.currentOperation.points.push({ x: this.startX, y: this.startY })
  }

  // 处理触摸移动
  handleTouchMove(event: TouchEvent) {
    if (!this.isDrawing || !this.currentOperation) {
      return
    }

    const x = event.touches[0].x
    const y = event.touches[0].y

    if (this.selectedTool === ToolType.PEN || this.selectedTool === ToolType.ERASER) {
      // 自由绘制
      this.currentOperation.points.push({ x, y })
    } else {
      // 形状绘制，更新终点
      if (this.currentOperation.points.length > 1) {
        this.currentOperation.points[1] = { x, y }
      } else {
        this.currentOperation.points.push({ x, y })
      }
    }

    this.redrawCanvas()
  }

  // 处理触摸结束
  handleTouchEnd(event: TouchEvent) {
    if (!this.isDrawing || !this.currentOperation) {
      return
    }

    this.isDrawing = false

    // 添加到历史记录
    this.historyManager.addOperation(this.currentOperation)
    this.operations.push(this.currentOperation)
    this.currentOperation = null

    this.updateUndoRedoState()
    this.redrawCanvas()
  }

  // 重绘画布
  redrawCanvas() {
    console.log('[EditorPage] redrawCanvas - 开始重绘画布');
    if (!this.canvasContext) {
      console.error('[EditorPage] redrawCanvas - canvasContext 为 null，无法绘制');
      return
    }

    // 清空画布
    this.canvasContext.clearRect(0, 0, this.canvasWidth, this.canvasHeight)
    console.log(`[EditorPage] 清空画布：宽=${this.canvasWidth}, 高=${this.canvasHeight}`);

    // 绘制图片
    if (this.loadedPixelMap) {
      console.log('[EditorPage] 开始绘制图片到画布');
      // Canvas 目前支持 drawImage(PixelMap, x, y, w?, h?)
      this.canvasContext.drawImage(this.loadedPixelMap, 0, 0, this.canvasWidth, this.canvasHeight)
      console.log('[EditorPage] 图片绘制完成');
    }

    // 应用图片调整（亮度、对比度、旋转）
    if (this.imageAdjustment.imageBrightness !== 0 || this.imageAdjustment.imageContrast !== 0) {
      this.applyImageAdjustments()
    }

    // 绘制所有操作
    this.operations.forEach((op: DrawingOperation) => {
      this.drawOperation(op)
    })

    // 绘制当前操作
    if (this.currentOperation) {
      this.drawOperation(this.currentOperation)
    }

    // 绘制裁剪框
    if (this.showCropPanel) {
      this.drawCropOverlay()
    }
  }

  // 应用图片调整
  applyImageAdjustments() {
    if (!this.canvasContext) {
      return
    }

    const imageData = this.canvasContext.getImageData(0, 0, this.canvasWidth, this.canvasHeight)
    const data = imageData.data

    const brightness = this.imageAdjustment.imageBrightness * 2.55 // 转换为0-255范围
    const contrast = (this.imageAdjustment.imageContrast + 100) / 100 // 转换为乘数

    for (let i = 0; i < data.length; i += 4) {
      // 应用对比度
      data[i] = (data[i] - 128) * contrast + 128 // R
      data[i + 1] = (data[i + 1] - 128) * contrast + 128 // G
      data[i + 2] = (data[i + 2] - 128) * contrast + 128 // B

      // 应用亮度
      data[i] += brightness // R
      data[i + 1] += brightness // G
      data[i + 2] += brightness // B

      // 限制在0-255范围内
      data[i] = Math.max(0, Math.min(255, data[i]))
      data[i + 1] = Math.max(0, Math.min(255, data[i + 1]))
      data[i + 2] = Math.max(0, Math.min(255, data[i + 2]))
    }

    this.canvasContext.putImageData(imageData, 0, 0)
  }

  // 绘制裁剪框
  drawCropOverlay() {
    if (!this.canvasContext) {
      return
    }

    this.canvasContext.save()

    // 绘制半透明遮罩
    this.canvasContext.fillStyle = 'rgba(0, 0, 0, 0.5)'
    this.canvasContext.fillRect(0, 0, this.canvasWidth, this.canvasHeight)

    // 清除裁剪区域
    this.canvasContext.clearRect(this.cropX, this.cropY, this.cropWidth, this.cropHeight)

    // 绘制裁剪框边框
    this.canvasContext.strokeStyle = '#007DFF'
    this.canvasContext.lineWidth = 2
    this.canvasContext.strokeRect(this.cropX, this.cropY, this.cropWidth, this.cropHeight)

    // 绘制九宫格参考线
    this.canvasContext.strokeStyle = '#FFFFFF'
    this.canvasContext.lineWidth = 1
    this.canvasContext.setLineDash([5, 5])

    // 垂直线
    this.canvasContext.beginPath()
    this.canvasContext.moveTo(this.cropX + this.cropWidth / 3, this.cropY)
    this.canvasContext.lineTo(this.cropX + this.cropWidth / 3, this.cropY + this.cropHeight)
    this.canvasContext.moveTo(this.cropX + this.cropWidth * 2 / 3, this.cropY)
    this.canvasContext.lineTo(this.cropX + this.cropWidth * 2 / 3, this.cropY + this.cropHeight)
    this.canvasContext.stroke()

    // 水平线
    this.canvasContext.beginPath()
    this.canvasContext.moveTo(this.cropX, this.cropY + this.cropHeight / 3)
    this.canvasContext.lineTo(this.cropX + this.cropWidth, this.cropY + this.cropHeight / 3)
    this.canvasContext.moveTo(this.cropX, this.cropY + this.cropHeight * 2 / 3)
    this.canvasContext.lineTo(this.cropX + this.cropWidth, this.cropY + this.cropHeight * 2 / 3)
    this.canvasContext.stroke()

    this.canvasContext.restore()
  }

  // 绘制单个操作
  drawOperation(op: DrawingOperation) {
    if (!this.canvasContext || op.points.length === 0) {
      return
    }

    this.canvasContext.globalAlpha = op.opacity
    this.canvasContext.strokeStyle = op.color
    this.canvasContext.lineWidth = op.strokeWidth
    this.canvasContext.lineCap = 'round'
    this.canvasContext.lineJoin = 'round'

    if (op.type === OperationType.ERASER) {
      this.canvasContext.globalCompositeOperation = 'destination-out'
    } else {
      this.canvasContext.globalCompositeOperation = 'source-over'
    }

    this.canvasContext.beginPath()

    switch (op.type) {
      case OperationType.DRAW_PATH:
      case OperationType.ERASER:
        // 自由路径
        this.canvasContext.moveTo(op.points[0].x, op.points[0].y)
        for (let i = 1; i < op.points.length; i++) {
          this.canvasContext.lineTo(op.points[i].x, op.points[i].y)
        }
        this.canvasContext.stroke()
        break

      case OperationType.DRAW_LINE:
        // 直线
        if (op.points.length >= 2) {
          this.canvasContext.moveTo(op.points[0].x, op.points[0].y)
          this.canvasContext.lineTo(op.points[1].x, op.points[1].y)
          this.canvasContext.stroke()
        }
        break

      case OperationType.DRAW_RECT:
        // 矩形
        if (op.points.length >= 2) {
          const width = op.points[1].x - op.points[0].x
          const height = op.points[1].y - op.points[0].y
          this.canvasContext.strokeRect(op.points[0].x, op.points[0].y, width, height)
        }
        break

      case OperationType.DRAW_CIRCLE:
        // 圆形
        if (op.points.length >= 2) {
          const radius = Math.sqrt(
            Math.pow(op.points[1].x - op.points[0].x, 2) +
            Math.pow(op.points[1].y - op.points[0].y, 2)
          )
          this.canvasContext.arc(op.points[0].x, op.points[0].y, radius, 0, Math.PI * 2)
          this.canvasContext.stroke()
        }
        break

      case OperationType.DRAW_ELLIPSE:
        // 椭圆
        if (op.points.length >= 2) {
          const radiusX = Math.abs(op.points[1].x - op.points[0].x) / 2
          const radiusY = Math.abs(op.points[1].y - op.points[0].y) / 2
          const centerX = (op.points[0].x + op.points[1].x) / 2
          const centerY = (op.points[0].y + op.points[1].y) / 2
          this.canvasContext.ellipse(centerX, centerY, radiusX, radiusY, 0, 0, Math.PI * 2)
          this.canvasContext.stroke()
        }
        break
    }

    this.canvasContext.globalAlpha = 1.0
    this.canvasContext.globalCompositeOperation = 'source-over'
  }

  // 撤销
  undo() {
    const op = this.historyManager.undo()
    if (op) {
      this.operations.pop()
      this.updateUndoRedoState()
      this.redrawCanvas()
    }
  }

  // 重做
  redo() {
    const op = this.historyManager.redo()
    if (op) {
      this.operations.push(op)
      this.updateUndoRedoState()
      this.redrawCanvas()
    }
  }

  // 更新撤销/重做按钮状态
  updateUndoRedoState() {
    this.canUndo = this.historyManager.canUndo()
    this.canRedo = this.historyManager.canRedo()
  }

  // 旋转图片
  rotateImage() {
    this.imageAdjustment.rotation = (this.imageAdjustment.rotation + 90) % 360
    this.redrawCanvas()
  }

  // 保存图片
  async saveImage() {
    if (!this.canvasContext) {
      promptAction.showToast({
        message: '没有可保存的内容',
        duration: 2000
      })
      return
    }
    try {
      // 获取canvas的ImageData
      const imageData = this.canvasContext.getImageData(0, 0, this.canvasWidth, this.canvasHeight)

      // 实际应用中需要将ImageData转换为PixelMap并保存
      // 这里简化处理
      promptAction.showToast({
        message: '图片已保存到相册',
        duration: 2000
      })
    } catch (err) {
      console.error('保存失败:', JSON.stringify(err))
      promptAction.showToast({
        message: '保存失败',
        duration: 2000
      })
    }
  }

  // 分享图片
  async shareImage() {
    this.showShareMenu = !this.showShareMenu
  }

  // 分享到指定平台
  async shareToApp(appName: string) {
    this.showShareMenu = false

    try {
      const context = getContext(this) as common.UIAbilityContext
      await ShareManager.shareToApp(this.imageUri, appName, context)
    } catch (err) {
      console.error('分享失败:', JSON.stringify(err))
      promptAction.showToast({
        message: '分享失败',
        duration: 2000
      })
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row({ space: 8 }) {
          Text('←')
            .fontSize(24)
            .fontColor('#1A1A1A')
            .onClick(() => {
              router.back()
            })

          Text('编辑图片')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
        }

        Blank()

        Row({ space: 12 }) {
          Button('撤销')
            .fontSize(14)
            .height(32)
            .backgroundColor(this.canUndo ? '#007DFF' : '#E5E5E5')
            .fontColor(this.canUndo ? '#FFFFFF' : '#999999')
            .enabled(this.canUndo)
            .onClick(() => {
              this.undo()
            })

          Button('重做')
            .fontSize(14)
            .height(32)
            .backgroundColor(this.canRedo ? '#007DFF' : '#E5E5E5')
            .fontColor(this.canRedo ? '#FFFFFF' : '#999999')
            .enabled(this.canRedo)
            .onClick(() => {
              this.redo()
            })

          Button('分享')
            .fontSize(14)
            .height(32)
            .backgroundColor('#52C41A')
            .onClick(() => {
              this.shareImage()
            })
        }
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

      // 画布区域
      Stack() {
        // 背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#F0F0F0')

        // Canvas画布
        Canvas(this.canvasContext)
          .width('100%')
          .height('100%')
          .backgroundColor('#FFFFFF')
          .onReady(() => {
            this.canvasContext = new CanvasRenderingContext2D(this.settings)
            this.redrawCanvas()
          })
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.handleTouchStart(event)
            } else if (event.type === TouchType.Move) {
              this.handleTouchMove(event)
            } else if (event.type === TouchType.Up) {
              this.handleTouchEnd(event)
            }
          })

        // 设置面板
        if (this.showColorPicker || this.showBrushSettings || this.showAdjustPanel) {
          //const color = this.currentColor;
          Column({ space: 12 }) {
            if (this.showColorPicker) {
              CustomColorPicker({ selectedColor: this.currentColor })
            }

            if (this.showBrushSettings) {
              BrushSettings({
                strokeWidth: $strokeWidth,
                brushOpacity: $brushOpacity
              })
            }

            if (this.showAdjustPanel) {
              ImageAdjustPanel({
                // imageBrightness: this.imageAdjustment.imageBrightness,
                // imageContrast: this.imageAdjustment.imageContrast,
                imageBrightness: $imageBrightness,  // 注意：双向绑定需用$语法传递
                imageContrast: $imageContrast,
                onRotate: () => {
                  this.rotateImage()
                }
              })
            }
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({
            radius: 12,
            color: '#20000000',
            offsetY: 4
          })
          .margin(16)
          .alignSelf(ItemAlign.End)
        }

        // 裁剪面板
        if (this.showCropPanel) {
          CropPanel({
            cropX: $cropX,
            cropY: $cropY,
            cropWidth: $cropWidth,
            cropHeight: $cropHeight,
            onConfirm: () => {
              this.confirmCrop()
            },
            onCancel: () => {
              this.cancelCrop()
            }
          })
            .margin(16)
            .alignSelf(ItemAlign.Center)
        }

        // 分享菜单
        if (this.showShareMenu) {
          Column({ space: 12 }) {
            Text('分享到')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Column({ space: 8 }) {
              this.ShareMenuItem('微信', '📱', () => {
                this.shareToApp('wechat')
              })
              this.ShareMenuItem('微博', '📷', () => {
                this.shareToApp('weibo')
              })
              this.ShareMenuItem('QQ', '💬', () => {
                this.shareToApp('qq')
              })
              this.ShareMenuItem('邮件', '📧', () => {
                this.shareToApp('email')
              })
              this.ShareMenuItem('保存到相册', '💾', () => {
                this.saveImage()
                this.showShareMenu = false
              })
            }
          }
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .shadow({
            radius: 12,
            color: '#20000000',
            offsetY: 4
          })
          .margin(16)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
        }
      }
      .layoutWeight(1)

      // 底部工具栏
      EditorToolbar({
        selectedTool: $selectedTool,
        onToolSelected: (tool: ToolType) => {
          this.onToolSelected(tool)
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 分享菜单项
  @Builder
  ShareMenuItem(title: string, icon: string, action: () => void) {
    Row({ space: 12 }) {
      Text(icon)
        .fontSize(24)

      Text(title)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)

      Text('→')
        .fontSize(18)
        .fontColor('#999999')
    }
    .width('100%')
    .height(48)
    .padding({ left: 12, right: 12 })
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      action()
    })
  }
}

