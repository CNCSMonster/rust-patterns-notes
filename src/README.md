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
