# 大决定 - 高保真原型

这是一个帮助用户做决定的应用原型，当用户面临两个选择犹豫不决时，可以输入选项A和选项B的内容，以及一些附加信息，通过大语言模型分析两个选项的利弊，给出科学中肯的建议。

## 项目结构

```
BigDecision_protoTypes/
├── css/
│   └── styles.css          # 全局样式文件
├── js/
│   └── app.js              # JavaScript 功能实现
├── images/                 # 图片资源目录
├── pages/                  # 页面目录
│   ├── welcome.html        # 欢迎页
│   ├── home.html           # 主页
│   ├── create.html         # 创建决定页
│   ├── additional_info.html # 补充信息页
│   ├── result.html         # 分析结果页
│   ├── history.html        # 历史记录页
│   ├── settings.html       # 设置页
│   └── template.html       # 页面模板
└── index.html              # 入口文件，展示所有页面
```

## 使用方法

1. 直接打开 `index.html` 文件，可以看到所有页面的预览
2. 每个页面都是独立的 HTML 文件，可以单独查看
3. 页面之间的跳转逻辑在实际应用中需要通过 JavaScript 实现

## 页面说明

1. **欢迎页 (welcome.html)**：应用的引导页面，介绍应用的主要功能
2. **主页 (home.html)**：展示最近的决定和快速操作入口
3. **创建决定页 (create.html)**：输入决定标题、选项A和选项B的内容
4. **补充信息页 (additional_info.html)**：输入决定类型、补充信息等
5. **分析结果页 (result.html)**：展示AI分析的结果和建议
6. **历史记录页 (history.html)**：查看和管理历史决定
7. **设置页 (settings.html)**：应用设置和用户信息

## 技术栈

- HTML5
- CSS3
- Tailwind CSS (通过CDN引入)
- Font Awesome (图标库)
- JavaScript (基础交互)

## 设计特点

1. 遵循 iOS 设计规范，包括状态栏和底部导航栏
2. 使用现代化的 UI 元素，如卡片、圆角按钮等
3. 配色方案以紫色为主色调，简洁明快
4. 响应式设计，适配移动设备
5. 动画效果增强用户体验

## 开发说明

这是一个高保真原型，可以直接用于开发参考。在实际开发中，需要：

1. 实现页面之间的跳转逻辑
2. 连接后端API，实现数据持久化
3. 对接大语言模型API，实现决定分析功能
4. 完善用户认证和数据同步功能

## 预览

打开 `index.html` 文件可以看到所有页面的预览，每个页面都模拟了 iPhone 15 Pro 的尺寸和外观。 