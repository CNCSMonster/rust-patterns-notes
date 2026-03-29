# 🚀 部署到 GitHub Pages 指南

## 步骤 1: 创建新仓库

在 GitHub 上创建一个新仓库，例如：

```
https://github.com/YOUR_USERNAME/rust-patterns-notes
```

## 步骤 2: 初始化 Git 并提交

```bash
cd rust-patterns-notes

# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: Rust Patterns Notes"

# 添加远程仓库（替换为你的仓库 URL）
git remote add origin https://github.com/YOUR_USERNAME/rust-patterns-notes.git

# 推送到 main 分支
git branch -M main
git push -u origin main
```

## 步骤 3: 配置 GitHub Pages

1. 进入仓库的 **Settings** → **Pages**
2. 在 **Build and deployment** 部分：
   - **Source**: 选择 `GitHub Actions`
3. 保存后，GitHub Actions 会自动触发构建

## 步骤 4: 更新配置文件

编辑以下文件，替换 `YOUR_USERNAME` 为你的 GitHub 用户名：

### book.toml
```toml
site-url = "/rust-patterns-notes/"
git-repository-url = "https://github.com/YOUR_USERNAME/rust-patterns-notes"
edit-url-template = "https://github.com/YOUR_USERNAME/rust-patterns-notes/edit/main/{path}"
```

### README.md
将 `YOUR_USERNAME` 替换为你的用户名。

### .github/workflows/deploy.yml
通常不需要修改，除非你想自定义部署流程。

## 步骤 5: 访问网站

部署完成后（约 2-5 分钟），访问：

```
https://YOUR_USERNAME.github.io/rust-patterns-notes/
```

## 本地开发

### 安装 mdBook

```bash
# 方法 1: 使用 cargo-binstall（推荐，更快）
cargo binstall mdbook

# 方法 2: 使用 cargo install
cargo install mdbook
```

### 运行开发服务器

```bash
cd rust-patterns-notes

# 自动打开浏览器
mdbook serve --open

# 或在指定端口运行
mdbook serve -p 8000
```

### 构建静态文件

```bash
mdbook build
# 输出在 ./book/ 目录
```

## 更新内容

1. 编辑 `src/` 目录下的 Markdown 文件
2. 提交并推送：

```bash
git add .
git commit -m "Update: 描述你的修改"
git push
```

GitHub Actions 会自动重新部署。

## 自定义主题（可选）

如需自定义 mdBook 主题：

```bash
cd rust-patterns-notes
mdbook init --theme
```

这会创建 `theme/` 目录，可以自定义：
- `theme/index.hbs` - HTML 模板
- `theme/css/general.css` - 样式
- `theme/book.js` - JavaScript

## 故障排除

### 构建失败

检查 GitHub Actions 日志：
```
https://github.com/YOUR_USERNAME/rust-patterns-notes/actions
```

### 404 错误

确保：
1. `book.toml` 中的 `site-url` 正确
2. 等待 5-10 分钟让 CDN 刷新
3. 检查 GitHub Pages 设置

### 本地预览正常，部署后样式丢失

通常是 `site-url` 配置问题。确保：
```toml
site-url = "/rust-patterns-notes/"
```

与仓库名一致。

## 高级配置

### 添加自定义域名

1. 在 GitHub Pages 设置中添加自定义域名
2. 在项目根目录创建 `CNAME` 文件：

```
your-domain.com
```

### 启用搜索

mdBook 默认启用搜索，无需额外配置。

### 启用代码折叠

已在 `book.toml` 中配置：

```toml
[output.html.fold]
enable = true
level = 1
```

## 资源

- [mdBook 官方文档](https://rust-lang.github.io/mdBook/)
- [GitHub Pages 文档](https://docs.github.com/en/pages)
- [mdBook 主题示例](https://github.com/rust-lang/mdBook/tree/master/examples)
