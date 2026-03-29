# Rust Design Patterns - 整体结构梳理

> 来源：[Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/)
>
> 原文版本：`main@f279f35` (2026-03-29 查验)
>
> 整理日期：2026-03-22
> 完成日期：2026-03-29

---

## 📖 书籍概述

**Rust Design Patterns** 是一本关于 Rust 设计模式和习惯用法的开源书籍，旨在帮助开发者编写更地道、更高效的 Rust 代码。

### 核心概念

书籍内容分为三大类：

| 类型 | 说明 |
|------|------|
| **Idioms（习惯用法）** | Rust 社区的编码规范，代表社区共识的最佳实践。除非有充分理由，否则应遵循。 |
| **Design Patterns（设计模式）** | 解决常见编程问题的方法和模式。 |
| **Anti-Patterns（反模式）** | 看似能解决问题，但实际上会造成更多问题的做法，应避免。 |

---

## 📚 完整目录结构

### 1. Introduction（引言）
- 1.1 Translations（翻译版本）

---

### 2. Idioms（习惯用法）

> 日常编码中应遵循的 Rust 最佳实践

| 编号 | 主题 | 说明 |
|------|------|------|
| 2.1 | Use borrowed types for arguments | 参数使用借用类型 |
| 2.2 | Concatenating Strings with format! | 使用 format! 拼接字符串 |
| 2.3 | Constructor | 构造函数模式 |
| 2.4 | The Default Trait | Default trait 的使用 |
| 2.5 | Collections Are Smart Pointers | 集合是智能指针 |
| 2.6 | Finalisation in Destructors | 析构函数中的收尾工作 |
| 2.7 | mem::{take(_), replace(_)} | 内存操作工具 |
| 2.8 | On-Stack Dynamic Dispatch | 栈上动态分发 |
| 2.9 | Foreign function interface (FFI) | FFI 相关习惯 |
| 2.9.1 | └─ Idiomatic Errors | 习惯性的错误处理 |
| 2.9.2 | └─ Accepting Strings | 接收字符串 |
| 2.9.3 | └─ Passing Strings | 传递字符串 |
| 2.10 | Iterating over an Option | 遍历 Option |
| 2.11 | Pass Variables to Closure | 向闭包传递变量 |
| 2.12 | Privacy For Extensibility | 为可扩展性设计隐私 |
| 2.13 | Easy doc initialization | 简易文档初始化 |
| 2.14 | Temporary mutability | 临时可变性 |
| 2.15 | Return consumed arg on error | 错误时返回已消费参数 |

---

### 3. Design Patterns（设计模式）

#### 3.1 Behavioural Patterns（行为型模式）

| 编号 | 主题 | 说明 |
|------|------|------|
| 3.1.1 | Command | 命令模式 |
| 3.1.2 | Interpreter | 解释器模式 |
| 3.1.3 | Newtype | 新类型模式 |
| 3.1.4 | RAII Guards | RAII 守卫模式 |
| 3.1.5 | Strategy | 策略模式 |
| 3.1.6 | Visitor | 访问者模式 |

#### 3.2 Creational Patterns（创建型模式）

| 编号 | 主题 | 说明 |
|------|------|------|
| 3.2.1 | Builder | 构建者模式 |
| 3.2.2 | Fold | 折叠模式 |

#### 3.3 Structural Patterns（结构型模式）

| 编号 | 主题 | 说明 |
|------|------|------|
| 3.3.1 | Compose Structs | 组合结构体 |
| 3.3.2 | Prefer Small Crates | 优先使用小 crate |
| 3.3.3 | Contain unsafety in small modules | 在小模块中封装 unsafe |
| 3.3.4 | Avoid complex type bounds with custom traits | 使用自定义 trait 避免复杂类型约束 |

#### 3.4 Foreign Function Interface (FFI)

| 编号 | 主题 | 说明 |
|------|------|------|
| 3.4.1 | Object-Based APIs | 基于对象的 API |
| 3.4.2 | Type Consolidation into Wrappers | 类型整合到包装器 |

---

### 4. Anti-Patterns（反模式）

> 应避免的常见错误做法

| 编号 | 主题 | 说明 |
|------|------|------|
| 4.1 | Clone to satisfy the borrow checker | 用 Clone 绕过借用检查器 |
| 4.2 | #[deny(warnings)] | 使用 #[deny(warnings)] |
| 4.3 | Deref Polymorphism | Deref 多态 |

---

### 5. Functional Programming（函数式编程）

| 编号 | 主题 | 说明 |
|------|------|------|
| 5.1 | Programming paradigms | 编程范式 |
| 5.2 | Generics as Type Classes | 泛型作为类型类 |
| 5.3 | Functional Optics | 函数式光学 |

---

### 6. Additional Resources（额外资源）

| 编号 | 主题 | 说明 |
|------|------|------|
| 6.1 | Design principles | 设计原则 |

---

## 📊 统计概览

| 类别 | 小节数量 |
|------|----------|
| Idioms | 15 |
| Design Patterns - Behavioural | 6 |
| Design Patterns - Creational | 2 |
| Design Patterns - Structural | 4 |
| Design Patterns - FFI | 2 |
| Anti-Patterns | 3 |
| Functional Programming | 3 |
| Additional Resources | 1 |
| **总计** | **36** |

---

## 📅 更新记录

- **2025-12-14**: 新增模式 - *Use custom traits to avoid complex type bounds*
- **2024-03-17**: 新增 PDF 下载格式

---

## 🔗 相关链接

- 官方网站：[Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/)
- GitHub 仓库：[rust-unofficial/patterns](https://github.com/rust-unofficial/patterns)

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
