// 水印管理器 - 添加文字水印
export interface TextWatermarkOptions {
  fontSize?: number
  fontColor?: string
  opacity?: number
  fontFamily?: string
  rotation?: number
}

export interface RepeatWatermarkOptions {
  fontSize?: number
  fontColor?: string
  opacity?: number
  spacing?: number
  rotation?: number
}

export interface TextSize { width: number; height: number }

export class WatermarkManager {
  // 在Canvas上绘制文字水印
  static drawTextWatermark(
    ctx: CanvasRenderingContext2D,
    text: string,
    x: number,
    y: number,
    options?: TextWatermarkOptions
  ): void {
    const fontSize = options?.fontSize || 24
    const fontColor = options?.fontColor || '#FFFFFF'
    const opacity = options?.opacity || 0.8
    const fontFamily = options?.fontFamily || 'sans-serif'
    const rotation = options?.rotation || 0

    ctx.save()

    // 设置字体样式
    ctx.font = `${fontSize}px ${fontFamily}`
    ctx.fillStyle = fontColor
    ctx.globalAlpha = opacity
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'

    // 如果需要旋转
    if (rotation !== 0) {
      ctx.translate(x, y)
      ctx.rotate(rotation * Math.PI / 180)
      ctx.fillText(text, 0, 0)
    } else {
      ctx.fillText(text, x, y)
    }

    ctx.restore()
  }

  // 在Canvas上绘制重复水印（铺满整个画布）
  static drawRepeatedWatermark(
    ctx: CanvasRenderingContext2D,
    text: string,
    canvasWidth: number,
    canvasHeight: number,
    options?: RepeatWatermarkOptions
  ): void {
    const fontSize = options?.fontSize || 24
    const fontColor = options?.fontColor || '#CCCCCC'
    const opacity = options?.opacity || 0.3
    const spacing = options?.spacing || 200
    const rotation = options?.rotation || -45

    ctx.save()

    ctx.font = `${fontSize}px sans-serif`
    ctx.fillStyle = fontColor
    ctx.globalAlpha = opacity
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'

    // 计算需要绘制的行列数
    const cols = Math.ceil(canvasWidth / spacing) + 2
    const rows = Math.ceil(canvasHeight / spacing) + 2

    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        const x = col * spacing
        const y = row * spacing

        ctx.save()
        ctx.translate(x, y)
        ctx.rotate(rotation * Math.PI / 180)
        ctx.fillText(text, 0, 0)
        ctx.restore()
      }
    }

    ctx.restore()
  }

  // 测量文字尺寸
  static measureText(
    ctx: CanvasRenderingContext2D,
    text: string,
    fontSize: number
  ): TextSize {
    ctx.save()
    ctx.font = `${fontSize}px sans-serif`
    const metrics = ctx.measureText(text)
    ctx.restore()

    return {
      width: metrics.width,
      height: fontSize // 近似高度
    }
  }
}


