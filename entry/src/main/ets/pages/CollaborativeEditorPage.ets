import { router } from '@kit.ArkUI'
import { ToolType } from '../model/ToolbarItem'
import { DrawingOperation, OperationType, CollaboratorInfo } from '../model/DrawingOperation'
import { HistoryManager } from '../utils/HistoryManager'
import { CollaborationManager } from '../utils/CollaborationManager'
import { EditorToolbar } from '../components/EditorToolbar'
import { ColorPicker } from '../components/ColorPicker'
import { BrushSettings } from '../components/BrushSettings'
import { CollaboratorCursor } from '../components/CollaboratorCursor'
import { WatermarkDialog } from '../components/WatermarkDialog'
import { WatermarkManager } from '../utils/WatermarkManager'
import { promptAction } from '@kit.ArkUI'
import { common } from '@kit.AbilityKit'

interface WatermarkParams {
  text: string;
  fontSize: number;
  fontColor: string;
  opacity: number;
  position: string;
}

// 协同编辑器页面
@Entry
@Component
struct CollaborativeEditorPage {
  @State imageUri: string = ''
  @State sessionCode: string = ''
  @State userName: string = ''
  @State isHost: boolean = false
  @State selectedTool: ToolType = ToolType.NONE
  @State currentColor: string = '#000000'
  @State strokeWidth: number = 3
  @State brushOpacity: number = 1.0
  @State showColorPicker: boolean = false
  @State showBrushSettings: boolean = false
  @State operations: DrawingOperation[] = []
  @State collaborators: CollaboratorInfo[] = []
  @State showCollaborators: boolean = true
  @State canUndo: boolean = false
  @State canRedo: boolean = false

  private historyManager: HistoryManager = new HistoryManager()
  private canvasContext: CanvasRenderingContext2D | null = null
  private isDrawing: boolean = false
  private startX: number = 0
  private startY: number = 0
  private currentOperation: DrawingOperation | null = null
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private myColor: string = '#FF0000'
  private collaboratorColors: string[] = ['#00FF00', '#0000FF', '#FFA500', '#800080', '#00FFFF']
  private collaborationManager: CollaborationManager = new CollaborationManager()
  private myUserId: string = ''
  private watermarkDialogController: CustomDialogController | null = null

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>
    if (params) {
      this.imageUri = (params['imageUri'] as string) || ''
      this.sessionCode = (params['sessionCode'] as string) || ''
      this.userName = (params['userName'] as string) || ''
      this.isHost = (params['isHost'] as boolean) || false
    }

    // 生成用户ID
    this.myUserId = `user_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`

    // 分配用户颜色
    this.myColor = this.collaboratorColors[Math.floor(Math.random() * this.collaboratorColors.length)]

    // 连接协同编辑会话
    this.connectToSession()
  }

  aboutToDisappear() {
    // 断开连接
    this.collaborationManager.disconnect()
  }

  // 连接到协同编辑会话
  async connectToSession() {
    // 设置回调
    this.collaborationManager.onOperationReceived = (operation: DrawingOperation) => {
      this.operations.push(operation)
      this.redrawCanvas()
    }

    this.collaborationManager.onCollaboratorJoined = (collaborator: CollaboratorInfo) => {
      this.collaborators.push(collaborator)
      promptAction.showToast({
        message: `${collaborator.userName} 加入了编辑`,
        duration: 2000
      })
    }

    this.collaborationManager.onCollaboratorLeft = (userId: string) => {
      const index = this.collaborators.findIndex(c => c.userId === userId)
      if (index >= 0) {
        const name = this.collaborators[index].userName
        this.collaborators.splice(index, 1)
        promptAction.showToast({
          message: `${name} 离开了编辑`,
          duration: 2000
        })
      }
    }

    this.collaborationManager.onCursorMoved = (userId: string, x: number, y: number) => {
      const collaborator = this.collaborators.find(c => c.userId === userId)
      if (collaborator) {
        collaborator.cursorX = x
        collaborator.cursorY = y
      }
    }

    this.collaborationManager.onSyncReceived = (operations: DrawingOperation[]) => {
      this.operations = operations
      this.redrawCanvas()
    }

    this.collaborationManager.onError = (error: string) => {
      promptAction.showToast({
        message: '连接失败，请重试',
        duration: 2000
      })
    }

    // 连接
    const connected = await this.collaborationManager.connect(
      this.sessionCode,
      this.myUserId,
      this.userName,
      this.myColor
    )

    if (connected) {
      promptAction.showToast({
        message: '已加入协同编辑',
        duration: 2000
      })
    }
  }

  // 处理工具选择
  onToolSelected(tool: ToolType) {
    this.selectedTool = tool
    this.showColorPicker = false
    this.showBrushSettings = false

    if (tool === ToolType.PEN || tool === ToolType.LINE ||
      tool === ToolType.RECT || tool === ToolType.CIRCLE ||
      tool === ToolType.ELLIPSE || tool === ToolType.TEXT) {
      this.showColorPicker = true
      this.showBrushSettings = true
    } else if (tool === ToolType.ERASER) {
      this.showBrushSettings = true
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
    if (!this.canvasContext) return

    let x = 0
    let y = 0

    // 根据位置计算坐标
    switch (params.position) {
      case 'center':
        x = 400 - params.text.length * params.fontSize / 4
        y = 300 - params.fontSize / 2
        break
      case 'topLeft':
        x = 20
        y = 20
        break
      case 'topRight':
        x = 780 - params.text.length * params.fontSize / 2
        y = 20
        break
      case 'bottomLeft':
        x = 20
        y = 580 - params.fontSize
        break
      case 'bottomRight':
        x = 780 - params.text.length * params.fontSize / 2
        y = 580 - params.fontSize
        break
      case 'repeat':
        WatermarkManager.drawRepeatedWatermark(
          this.canvasContext,
          params.text,
          800,
          600,
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

  // 处理触摸开始
  handleTouchStart(event: TouchEvent) {
    if (this.selectedTool === ToolType.NONE) return

    this.isDrawing = true
    this.startX = event.touches[0].x
    this.startY = event.touches[0].y

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
    this.currentOperation.userName = this.userName
    this.currentOperation.userColor = this.myColor
    this.currentOperation.points.push({ x: this.startX, y: this.startY })
  }

  // 处理触摸移动
  handleTouchMove(event: TouchEvent) {
    if (!this.isDrawing || !this.currentOperation) return

    const x = event.touches[0].x
    const y = event.touches[0].y

    if (this.selectedTool === ToolType.PEN || this.selectedTool === ToolType.ERASER) {
      this.currentOperation.points.push({ x, y })
    } else {
      if (this.currentOperation.points.length > 1) {
        this.currentOperation.points[1] = { x, y }
      } else {
        this.currentOperation.points.push({ x, y })
      }
    }

    // 广播光标位置（限制频率）
    this.collaborationManager.broadcastCursorMove(x, y)

    this.redrawCanvas()
  }

  // 处理触摸结束
  handleTouchEnd(event: TouchEvent) {
    if (!this.isDrawing || !this.currentOperation) return

    this.isDrawing = false

    this.historyManager.addOperation(this.currentOperation)
    this.operations.push(this.currentOperation)

    // 广播绘制完成事件
    const operation = this.currentOperation
    this.collaborationManager.broadcastOperation(operation)

    this.currentOperation = null
    this.updateUndoRedoState()
    this.redrawCanvas()
  }

  // 重绘画布
  redrawCanvas() {
    if (!this.canvasContext) return

    this.canvasContext.clearRect(0, 0, 800, 600)

    // 绘制所有操作
    this.operations.forEach((op: DrawingOperation) => {
      this.drawOperation(op)
    })

    // 绘制当前操作
    if (this.currentOperation) {
      this.drawOperation(this.currentOperation)
    }
  }

  // 绘制单个操作
  drawOperation(op: DrawingOperation) {
    if (!this.canvasContext || op.points.length === 0) return

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
        this.canvasContext.moveTo(op.points[0].x, op.points[0].y)
        for (let i = 1; i < op.points.length; i++) {
          this.canvasContext.lineTo(op.points[i].x, op.points[i].y)
        }
        this.canvasContext.stroke()
        break

      case OperationType.DRAW_LINE:
        if (op.points.length >= 2) {
          this.canvasContext.moveTo(op.points[0].x, op.points[0].y)
          this.canvasContext.lineTo(op.points[1].x, op.points[1].y)
          this.canvasContext.stroke()
        }
        break

      case OperationType.DRAW_RECT:
        if (op.points.length >= 2) {
          const width = op.points[1].x - op.points[0].x
          const height = op.points[1].y - op.points[0].y
          this.canvasContext.strokeRect(op.points[0].x, op.points[0].y, width, height)
        }
        break

      case OperationType.DRAW_CIRCLE:
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
      // 广播撤销操作
      this.collaborationManager.broadcastUndo()
    }
  }

  // 重做
  redo() {
    const op = this.historyManager.redo()
    if (op) {
      this.operations.push(op)
      this.updateUndoRedoState()
      this.redrawCanvas()
      // 广播重做操作
      this.collaborationManager.broadcastRedo()
    }
  }

  // 更新撤销/重做状态
  updateUndoRedoState() {
    this.canUndo = this.historyManager.canUndo()
    this.canRedo = this.historyManager.canRedo()
  }

  // 复制会话码
  copySessionCode() {
    // TODO: 实现复制到剪贴板
    promptAction.showToast({
      message: `会话码 ${this.sessionCode} 已复制`,
      duration: 2000
    })
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

          Column({ space: 2 }) {
            Text('协同编辑')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')

            Row({ space: 4 }) {
              Text(`会话: ${this.sessionCode}`)
                .fontSize(12)
                .fontColor('#666666')

              Text('📋')
                .fontSize(12)
                .onClick(() => {
                  this.copySessionCode()
                })
            }
          }
          .alignItems(HorizontalAlign.Start)
        }

        Blank()

        Row({ space: 8 }) {
          // 协作者头像列表
          Row({ space: -8 }) {
            // 我的头像
            Text(this.userName.charAt(0).toUpperCase())
              .fontSize(14)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .width(32)
              .height(32)
              .textAlign(TextAlign.Center)
              .backgroundColor(this.myColor)
              .borderRadius(16)
              .border({ width: 2, color: '#FFFFFF' })

            // 其他协作者
            ForEach(this.collaborators, (collab: CollaboratorInfo) => {
              Text(collab.userName.charAt(0).toUpperCase())
                .fontSize(14)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
                .width(32)
                .height(32)
                .textAlign(TextAlign.Center)
                .backgroundColor(collab.userColor)
                .borderRadius(16)
                .border({ width: 2, color: '#FFFFFF' })
            })
          }

          Button('撤销')
            .fontSize(12)
            .height(28)
            .padding({ left: 8, right: 8 })
            .backgroundColor(this.canUndo ? '#007DFF' : '#E5E5E5')
            .fontColor(this.canUndo ? '#FFFFFF' : '#999999')
            .enabled(this.canUndo)
            .onClick(() => {
              this.undo()
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

        // 协作者光标
        ForEach(this.collaborators, (collab: CollaboratorInfo) => {
          CollaboratorCursor({ collaborator: collab })
        })

        // 设置面板
        if (this.showColorPicker || this.showBrushSettings) {
          Column({ space: 12 }) {
            if (this.showColorPicker) {
              ColorPicker({ selectedColor: $currentColor })
            }

            if (this.showBrushSettings) {
              BrushSettings({
                strokeWidth: $strokeWidth,
                brushOpacity: $brushOpacity
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

        // 在线用户列表
        if (this.showCollaborators && this.collaborators.length > 0) {
          Column({ space: 8 }) {
            Text('在线协作者')
              .fontSize(12)
              .fontColor('#666666')
              .fontWeight(FontWeight.Medium)

            ForEach(this.collaborators, (collab: CollaboratorInfo) => {
              Row({ space: 8 }) {
                Circle({ width: 8, height: 8 })
                  .fill(collab.userColor)

                Text(collab.userName)
                  .fontSize(12)
                  .fontColor('#333333')

                if (collab.isDrawing) {
                  Text('绘制中...')
                    .fontSize(10)
                    .fontColor('#999999')
                }
              }
            })
          }
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .shadow({
            radius: 8,
            color: '#20000000',
            offsetY: 2
          })
          .margin({ top: 16, left: 16 })
          .alignSelf(ItemAlign.Start)
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
}

