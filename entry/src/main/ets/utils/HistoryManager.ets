import { DrawingOperation } from '../model/DrawingOperation'

// 历史记录管理器 - 实现撤销/重做功能
export class HistoryManager {
  private operations: DrawingOperation[] = []
  private currentIndex: number = -1
  private maxHistorySize: number = 50

  // 添加新操作
  addOperation(operation: DrawingOperation): void {
    // 删除当前索引之后的所有操作
    if (this.currentIndex < this.operations.length - 1) {
      this.operations = this.operations.slice(0, this.currentIndex + 1)
    }

    // 添加新操作
    this.operations.push(operation)
    this.currentIndex++

    // 限制历史记录大小
    if (this.operations.length > this.maxHistorySize) {
      this.operations.shift()
      this.currentIndex--
    }
  }

  // 撤销
  undo(): DrawingOperation | null {
    if (this.canUndo()) {
      const operation = this.operations[this.currentIndex]
      this.currentIndex--
      return operation
    }
    return null
  }

  // 重做
  redo(): DrawingOperation | null {
    if (this.canRedo()) {
      this.currentIndex++
      const operation = this.operations[this.currentIndex]
      return operation
    }
    return null
  }

  // 是否可以撤销
  canUndo(): boolean {
    return this.currentIndex >= 0
  }

  // 是否可以重做
  canRedo(): boolean {
    return this.currentIndex < this.operations.length - 1
  }

  // 获取当前所有有效操作
  getCurrentOperations(): DrawingOperation[] {
    return this.operations.slice(0, this.currentIndex + 1)
  }

  // 清空历史
  clear(): void {
    this.operations = []
    this.currentIndex = -1
  }
}

