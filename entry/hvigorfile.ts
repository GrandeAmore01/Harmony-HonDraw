// 保留鸿蒙 HAP 模块内置核心任务（不可修改）
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
// 导入 Rollup 必需插件（与 rollup.config.js 保持一致）
import typescript from '@rollup/plugin-typescript';
import image from '@rollup/plugin-image';
import postcss from 'rollup-plugin-postcss';

// 完整配置：路径、插件均适配你的项目结构
export default {
  system: hapTasks, /* 内置构建任务，不可删除或修改 */
  plugins: [],       /* 自定义插件扩展（当前无需添加，保留空数组） */

  // Rollup 插件配置（核心：解决语法解析和资源处理问题）
  rollupOptions: {
    plugins: [
      // 处理 ArkTS/TypeScript：使用绝对路径指向 tsconfig.json，避免歧义
      typescript({
        tsconfig: "D:\\HongHui1\\tsconfig.json", // 精准指向项目根目录的 tsconfig 文件
        extensions: [".ts", ".ets"], // 支持 ArkTS（.ets）和 TypeScript（.ts）文件
        compilerOptions: {
          experimentalDecorators: true, // 必须启用：支持 @Component、@Entry 等 ArkTS 装饰器
          target: "ESNext", // 适配最新 JavaScript 语法
          module: "ESNext", // 模块格式：兼容鸿蒙 ESM 规范
          strict: false, // 关闭严格模式：避免 ArkTS 语法被误判为错误
          skipLibCheck: true // 跳过库文件类型检查：提升构建速度
        }
      }),

      // 处理 CSS 样式文件（如有 .css 导入则保留，无则可删除以下 2 行）
      postcss(),

      // 处理图片文件（如有 .png/.jpg 等导入则保留，无则可删除以下 2 行）
      image()
    ]
  }
};