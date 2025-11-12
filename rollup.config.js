// 1. 导入所有需要的插件
import typescript from '@rollup/plugin-typescript'; // 处理 ArkTS/TypeScript
import image from '@rollup/plugin-image'; // 处理图片（如 .png、.jpg）
import postcss from 'rollup-plugin-postcss'; // 处理 CSS 样式文件

// 2. 导出 Rollup 配置（整个文件只能有一个 export default）
export default {
    // 入口文件：根据你的项目实际路径修改（通常是 main.ets 的位置）
    input: "entry/src/main/ets/main.ets",

    // 输出配置
    output: {
        file: "dist/bundle.js", // 打包后的输出文件路径
        format: "esm" // 鸿蒙项目推荐使用 ESM 模块格式
    },

    // 3. 注册插件（按顺序整合所有插件）
    plugins: [
        // 先处理 TypeScript/ArkTS 代码（核心插件，放在前面）
        typescript({
            tsconfig: "./tsconfig.json", // 关联 tsconfig.json 配置
            extensions: [".ts", ".ets"], // 支持 .ets（ArkTS）和 .ts 文件
            compilerOptions: {
                experimentalDecorators: true, // 必须启用，支持 ArkTS 的 @Component 等装饰器
                target: "ESNext", // 目标 JavaScript 版本
                module: "ESNext", // 模块格式
                strict: false // 关闭严格模式，避免 ArkTS 语法被误判
            }
        }),

        // 处理 CSS 样式文件（如果项目中有 .css 导入）
        postcss(),

        // 处理图片文件（如果项目中有图片导入，如 import img from './xxx.png'）
        image()
    ]
};