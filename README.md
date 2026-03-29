# Rust Patterns 学习笔记

[![Deploy](https://github.com/YOUR_USERNAME/rust-patterns-notes/actions/workflows/deploy.yml/badge.svg)](https://github.com/YOUR_USERNAME/rust-patterns-notes/actions/workflows/deploy.yml)

> 📚 学习来源：[Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/)
>
> ✅ 完成日期：2026-03-29

---

## 📖 关于

本笔记是基于 [Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/) 一书的学习记录，涵盖了 Rust 编程中的习惯用法、设计模式、反模式以及函数式编程等内容。

## 🌐 在线阅读

👉 **[https://YOUR_USERNAME.github.io/rust-patterns-notes/](https://YOUR_USERNAME.github.io/rust-patterns-notes/)**

## 📁 项目结构

```
rust-patterns-notes/
├── README.md               # 项目说明
├── DEPLOY.md               # 部署指南
├── book.toml               # mdBook 配置
├── setup.sh                # 安装脚本
├── .gitignore
└── src/
    ├── SUMMARY.md          # mdBook 导航文件
    ├── README.md           # 书籍整体结构梳理
    ├── idioms.md           # Part 1: 习惯用法
    ├── design-patterns.md  # Part 2: 设计模式
    ├── anti-patterns.md    # Part 3: 反模式
    ├── functional.md       # Part 4: 函数式编程
    └── supplementary.md    # Part 5: 补充资源
```

## 📁 内容结构

| 部分 | 文档 | 内容 | 小节数 |
|------|------|------|--------|
| 概述 | [src/README.md](./src/README.md) | 书籍整体结构梳理 | - |
| Part 1 | [src/idioms.md](./src/idioms.md) | 习惯用法 - Rust 编码规范 | 15 |
| Part 2 | [src/design-patterns.md](./src/design-patterns.md) | 设计模式 | 14 |
| Part 3 | [src/anti-patterns.md](./src/anti-patterns.md) | 反模式 | 3 |
| Part 4 | [src/functional.md](./src/functional.md) | 函数式编程 | 3 |
| Part 5 | [src/supplementary.md](./src/supplementary.md) | 补充资源 | 2 |
| **总计** | | | **37** |

## 🚀 本地构建

### 安装 mdBook

```bash
# 使用 cargo-binstall（推荐）
cargo binstall mdbook

# 或直接从源码安装
cargo install mdbook
```

### 构建和预览

```bash
cd rust-patterns-notes

# 构建
mdbook build

# 开发服务器（自动重载）
mdbook serve --open
```

构建输出在 `book/` 目录。

## 📊 笔记统计

| 类型 | 文件数 |
|------|--------|
| 导航文件 | 1 (SUMMARY.md) |
| 项目文档 | 2 (README.md, DEPLOY.md) |
| 纯笔记文档 | 6 (src/README.md + 5 个部分) |
| **总计** | **9** |

## 🔗 相关资源

- **原书**: https://rust-unofficial.github.io/patterns/
- **Rust API Guidelines**: https://rust-lang.github.io/api-guidelines/
- **Rust 官方文档**: https://doc.rust-lang.org/book/

## 📄 许可证

本笔记采用与原作者相同的许可协议。
