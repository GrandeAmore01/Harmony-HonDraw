import { webSocket } from '@kit.NetworkKit'
import { DrawingOperation, CollaboratorInfo } from '../model/DrawingOperation'

// 协同编辑消息类型
export enum MessageType {
  JOIN = 'JOIN',
  LEAVE = 'LEAVE',
  DRAW = 'DRAW',
  UNDO = 'UNDO',
  REDO = 'REDO',
  CURSOR_MOVE = 'CURSOR_MOVE',
  SYNC_REQUEST = 'SYNC_REQUEST',
  SYNC_RESPONSE = 'SYNC_RESPONSE'
}

// 协同编辑消息
export interface CollaborationMessage {
  type: MessageType
  sessionCode: string
  userId: string
  userName: string
  userColor: string
  timestamp: number
  data?: CollaborationPayload
}

type CollaborationPayload = DrawingOperation | { x: number; y: number } | DrawingOperation[];

// 协同编辑管理器
export class CollaborationManager {
  private ws: webSocket.WebSocket | null = null
  private sessionCode: string = ''
  private userId: string = ''
  private userName: string = ''
  private userColor: string = ''
  private isConnected: boolean = false
  private serverUrl: string = 'ws://localhost:8080' // 实际应用中应配置真实的WebSocket服务器地址

  // 回调函数
  onOperationReceived?: (operation: DrawingOperation) => void
  onCollaboratorJoined?: (collaborator: CollaboratorInfo) => void
  onCollaboratorLeft?: (userId: string) => void
  onCursorMoved?: (userId: string, x: number, y: number) => void
  onSyncReceived?: (operations: DrawingOperation[]) => void
  onError?: (error: string) => void

  constructor(serverUrl?: string) {
    if (serverUrl) {
      this.serverUrl = serverUrl
    }
  }

  // 连接到协同编辑会话
  async connect(
    sessionCode: string,
    userId: string,
    userName: string,
    userColor: string
  ): Promise<boolean> {
    try {
      this.sessionCode = sessionCode
      this.userId = userId
      this.userName = userName
      this.userColor = userColor

      // 创建WebSocket连接
      this.ws = webSocket.createWebSocket()

      // 设置事件监听
      this.ws.on('open', () => {
        console.log('WebSocket连接已建立')
        this.isConnected = true

        // 发送加入会话消息
        this.sendMessage({
          type: MessageType.JOIN,
          sessionCode: this.sessionCode,
          userId: this.userId,
          userName: this.userName,
          userColor: this.userColor,
          timestamp: Date.now()
        })

        // 请求同步历史操作
        this.requestSync()
      })

      this.ws.on('message', (err, value) => {
        if (err) {
          console.error('接收消息失败:', err)
          return
        }

        try {
          const message = JSON.parse(value.toString()) as CollaborationMessage
          this.handleMessage(message)
        } catch (e) {
          console.error('解析消息失败:', e)
        }
      })

      this.ws.on('close', (err, reason) => {
        console.log('WebSocket连接已关闭:', reason)
        this.isConnected = false
      })

      this.ws.on('error', (err) => {
        console.error('WebSocket错误:', err)
        this.isConnected = false
        if (this.onError) {
          this.onError(JSON.stringify(err))
        }
      })

      // 连接到服务器
      await this.ws.connect(`${this.serverUrl}/session/${sessionCode}`)

      return true
    } catch (err) {
      console.error('连接失败:', JSON.stringify(err))
      if (this.onError) {
        this.onError('连接失败: ' + JSON.stringify(err))
      }
      return false
    }
  }

  // 断开连接
  disconnect(): void {
    if (this.ws && this.isConnected) {
      // 发送离开消息
      this.sendMessage({
        type: MessageType.LEAVE,
        sessionCode: this.sessionCode,
        userId: this.userId,
        userName: this.userName,
        userColor: this.userColor,
        timestamp: Date.now()
      })

      this.ws.close()
      this.isConnected = false
    }
  }

  // 广播绘图操作
  broadcastOperation(operation: DrawingOperation): void {
    if (!this.isConnected) return

    this.sendMessage({
      type: MessageType.DRAW,
      sessionCode: this.sessionCode,
      userId: this.userId,
      userName: this.userName,
      userColor: this.userColor,
      timestamp: Date.now(),
      data: operation
    })
  }

  // 广播撤销操作
  broadcastUndo(): void {
    if (!this.isConnected) return

    this.sendMessage({
      type: MessageType.UNDO,
      sessionCode: this.sessionCode,
      userId: this.userId,
      userName: this.userName,
      userColor: this.userColor,
      timestamp: Date.now()
    })
  }

  // 广播重做操作
  broadcastRedo(): void {
    if (!this.isConnected) return

    this.sendMessage({
      type: MessageType.REDO,
      sessionCode: this.sessionCode,
      userId: this.userId,
      userName: this.userName,
      userColor: this.userColor,
      timestamp: Date.now()
    })
  }

  // 广播光标移动
  broadcastCursorMove(x: number, y: number): void {
    if (!this.isConnected) return

    this.sendMessage({
      type: MessageType.CURSOR_MOVE,
      sessionCode: this.sessionCode,
      userId: this.userId,
      userName: this.userName,
      userColor: this.userColor,
      timestamp: Date.now(),
      data: { x, y }
    })
  }

  // 请求同步历史操作
  requestSync(): void {
    if (!this.isConnected) return

    this.sendMessage({
      type: MessageType.SYNC_REQUEST,
      sessionCode: this.sessionCode,
      userId: this.userId,
      userName: this.userName,
      userColor: this.userColor,
      timestamp: Date.now()
    })
  }

  // 发送消息
  private sendMessage(message: CollaborationMessage): void {
    if (!this.ws || !this.isConnected) {
      console.warn('WebSocket未连接，无法发送消息')
      return
    }

    try {
      const jsonStr = JSON.stringify(message)
      this.ws.send(jsonStr)
    } catch (err) {
      console.error('发送消息失败:', err)
    }
  }

  // 处理接收到的消息
  private handleMessage(message: CollaborationMessage): void {
    // 忽略自己发送的消息
    if (message.userId === this.userId) {
      return
    }

    switch (message.type) {
      case MessageType.JOIN:
        // 新协作者加入
        if (this.onCollaboratorJoined) {
          const collaborator = new CollaboratorInfo()
          collaborator.userId = message.userId
          collaborator.userName = message.userName
          collaborator.userColor = message.userColor
          this.onCollaboratorJoined(collaborator)
        }
        break

      case MessageType.LEAVE:
        // 协作者离开
        if (this.onCollaboratorLeft) {
          this.onCollaboratorLeft(message.userId)
        }
        break

      case MessageType.DRAW:
        // 接收到绘图操作
        if (this.onOperationReceived && message.data) {
          const operation = message.data as DrawingOperation
          this.onOperationReceived(operation)
        }
        break

      case MessageType.CURSOR_MOVE:
        // 光标移动
        if (this.onCursorMoved && message.data) {
          this.onCursorMoved(message.userId, message.data.x, message.data.y)
        }
        break

      case MessageType.SYNC_RESPONSE:
        // 同步历史操作
        if (this.onSyncReceived && message.data) {
          const operations = message.data as DrawingOperation[]
          this.onSyncReceived(operations)
        }
        break

      case MessageType.UNDO:
      case MessageType.REDO:
        // 撤销/重做操作可以根据需要处理
        console.log(`收到${message.type}操作`)
        break
    }
  }

  // 检查连接状态
  isConnectedToSession(): boolean {
    return this.isConnected
  }
}


