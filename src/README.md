# Rust Patterns 学习笔记

> 基于 [Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/) 的学习笔记
>
> 原文版本：`main@f279f35` (2026-03-29 查验)

---

## 📖 关于

本笔记记录笔者学习 Rust Design Patterns 的理解和心得，包括：

- ✅ **认同的观点** - 原文的核心思想和最佳实践
- 💡 **补充示例** - 笔者觉得更好的代码示例
- ⚠️ **批评意见** - 笔者认为不严谨或有误的地方（标注为 `💭 笔记作者观点`）

---

## 📚 笔记导航

> **📝 编号说明**：原文没有数字编号，笔记中的编号（如 2.1、3.1.1）是为了方便引用而自创的。

| 部分 | 文档 | 内容 | 小节数 |
|------|------|------|--------|
| 导航 | [SUMMARY.md](./SUMMARY.md) | mdBook 导航文件 | - |
| Part 1 | [idioms.md](./idioms.md) | 习惯用法 - Rust 编码规范 | 15 |
| Part 2 | [design-patterns.md](./design-patterns.md) | 设计模式 | 14 |
| Part 3 | [anti-patterns.md](./anti-patterns.md) | 反模式 | 3 |
| Part 4 | [functional.md](./functional.md) | 函数式编程 | 3 |
| Part 5 | [supplementary.md](./supplementary.md) | 补充资源（重构 + 设计原则） | 2 |
| **总计** | | | **37** |

---

## 📖 术语表

| 英文 | 中文翻译 | 说明 |
|------|----------|------|
| Idioms | 习惯用法 | Rust 社区的编码规范和最佳实践 |
| Borrow Checker | 借用检查器 | Rust 编译器中负责检查借用规则的组件 |
| Trait | trait | Rust 中的接口/特征机制（不翻译） |
| Monomorphization | 单体化 | 编译时为每个具体类型生成独立代码 |
| RAII | RAII | 资源获取即初始化，Rust 的资源管理模式 |
| Move Semantics | Move 语义 | 赋值时转移所有权而非拷贝 |

完整术语表见 [主项目 README](../README.md#术语表)。

---

## 📅 学习记录

| 日期 | 内容 | 备注 |
|------|------|------|
| 2026-03-22 | 整体结构梳理完成 | 创建索引和计划 |
| 2026-03-22 | Idioms 部分完成 | 15/15 小节 |
| 2026-03-25 | Design Patterns 部分完成 | 14/14 小节 |
| 2026-03-26 | Anti-Patterns 部分完成 | 3/3 小节 |
| 2026-03-28 | Functional Programming 部分完成 | 3/3 小节 |
| 2026-03-28 | **全书学习完成** | 35/35 小节 ✅ |
| 2026-03-29 | Supplementary 部分完成 | 2/2 小节 |
| 2026-03-29 | **全部内容完成** | 37/37 小节 ✅ |

---

## 🎉 核心收获

### Idioms (习惯用法)
- 借用优先：参数用 `&T`，避免不必要的所有权转移
- format! 宏：字符串拼接首选
- Default trait：无参构造的最佳实践
- RAII：同步资源用 Drop，async 资源用显式 close
- mem 工具：`replace`/`take` 用于所有权交换

### Design Patterns (设计模式)
- Newtype：类型安全和显式保证
- RAII Guards：作用域结束时自动释放资源
- Builder：多参数构造用 Builder，复杂场景用 bon crate
- Visitor：封装操作异构对象的算法
- Contain unsafety：unsafe 代码集中到小模块

### Anti-Patterns (反模式)
- 借用优先于 clone：clone 应该是有意为之
- 警告管理：不用 `#![deny(warnings)]` blanket 禁止
- Deref 正确用途：只用于智能指针，不模拟继承

### Functional Programming (函数式编程)
- 命令式 vs 声明式：Rust 鼓励声明式
- 泛型单体化：编译时为每个类型生成独立代码
- Serde 三层架构：Deserialize + Visitor + Deserializer

### Supplementary (补充资源)
- 重构原则：先设计再重构，无测试不重构，拆分环节设置检查点
- SOLID 原则：Rust 中的新理解（LSP = trait 契约一致性）
- 其他设计原则：18 个原则的 Rust 体现和实践

---

## 🔗 相关链接

- **原书**: [Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/)
- **GitHub**: [rust-unofficial/patterns](https://github.com/rust-unofficial/patterns)
- **Rust API Guidelines**: [https://rust-lang.github.io/api-guidelines](https://rust-lang.github.io/api-guidelines)
