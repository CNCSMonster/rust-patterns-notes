# Rust Anti-Patterns 学习笔记

> 来源：[Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/anti-patterns.html)
>
> 原文版本：`main@f279f35` (2026-03-29 查验)
>
> 部分：Part 3 - Anti-Patterns (反模式)

---

## 概述

Anti-Patterns 是**应该避免**的做法。这些模式看似能解决问题，但实际上会造成更多问题。

**共 3 个小节**

---

## 目录

- [4.1 Clone to satisfy the borrow checker](#41-clone-to-satisfy-the-borrow-checker)
- [4.2 #[deny(warnings)]](#42-denywarnings)
- [4.3 Deref Polymorphism](#43-deref-polymorphism)

---

## 4.1 Clone to satisfy the borrow checker

> **状态**: ✅ 已完成

**核心**：借用检查器报错时，用 `.clone()` 来让代码编译通过，但这会导致数据不同步和性能开销。

**问题示例**:

```rust
// ❌ 反模式：clone 了一个新值，不是原来的 x
let mut x = 5;
let y = &mut (x.clone());  // 克隆了一个新值
*y += 1;                   // 修改的是克隆的值，不是 x
```

**后果**:
- 两个变量数据不同步
- 不必要的性能开销
- 掩盖了对所有权的理解不足

**例外情况**（可以接受）:
- `Rc<T>` 和 `Arc<T>` 的智能克隆（引用计数，非深拷贝）
- 学习阶段/原型
- 性能不关键的场景

**正确做法**:
```rust
// ✅ 能借用时尽量借用
let mut x = 5;
let y = &mut x;  // 直接借用
*y += 1;
```

**关键总结**:
- 反模式 = 常见但错误的做法
- clone 应该是**有意为之**，不是为了绕过借用检查
- 怀疑时用 `cargo clippy` 检查

**一句话总结**:
> 能借用时尽量借用，clone 应该是有意为之，不是为了绕过借用检查。

---

## 4.2 #[deny(warnings)]

> **状态**: ✅ 已完成

**核心**：在 crate 根使用 `#![deny(warnings)]` 来确保代码无警告编译，但这会破坏 Rust 的稳定性保证。

**问题**:

1. **破坏 Rust 的稳定性保证**：
   - Rust 有时会用新的 lint 警告某些问题
   - 经过一段时间后才变成 `deny`（硬错误）
   - `#![deny(warnings)]` 会**立即**把这些警告变成错误

2. **无法灵活处理警告**：
   - API 废弃会发出警告
   - 新版本引入新 lint 时可能编译失败

3. **无法使用 clippy 等工具**

**替代方案**:

1. **命令行设置**（推荐）：
   ```bash
   RUSTFLAGS="-D warnings" cargo build
   ```

2. **明确指定要 deny 的 lint**：
   ```rust
   #![deny(
       bad_style,
       dead_code,
       unused,
       // 只 deny 你确定要严格执行的
   )]
   ```

**关键总结**:
- `#![deny(warnings)]` = 把所有现在和未来的警告都变成错误
- 更好的做法：命令行设置或明确列出要 deny 的 lint

**一句话总结**:
> 不要用 `#![deny(warnings)]` blanket 禁止所有警告，应该明确列出要 deny 的 lint 或用命令行设置。

---

## 4.3 Deref Polymorphism

> **状态**: ✅ 已完成

**核心**：滥用 `Deref` trait 来模拟结构体之间的"继承"，从而复用方法。

**问题示例**:

```rust
// ❌ 反模式：用 Deref 模拟继承
use std::ops::Deref;

struct Foo {}

impl Foo {
    fn m(&self) { /* ... */ }
}

struct Bar {
    f: Foo,
}

impl Deref for Bar {
    type Target = Foo;
    fn deref(&self) -> &Foo {
        &self.f
    }
}

fn main() {
    let b = Bar { f: Foo {} };
    b.m();  // 通过 Deref 自动解引用调用 Foo 的方法
}
```

**为什么是反模式**：

| 原因 | 说明 |
|------|------|
| **违反直觉** | `Deref` 设计目的是指针解引用，不是类型转换 |
| **不支持子类型** | `Foo` 的 trait 不会自动为 `Bar` 实现 |
| **语义差异** | `self` 指向定义方法的类型，不是实际对象 |
| **功能有限** | 只支持单"继承"，无接口/隐私等概念 |

**`Deref` 的正确用途**：
- `Box<T>` → `T`
- `Rc<T>` → `T`
- `String` → `str`
- 自定义智能指针

**替代方案**：

1. **手动转发**（推荐）：
   ```rust
   impl Bar {
       fn m(&self) {
           self.f.m()  // 清晰明确
       }
   }
   ```

2. **使用 trait 抽象**

3. **使用委托 crate**：
   - [`delegate`](https://crates.io/crates/delegate)
   - [`ambassador`](https://crates.io/crates/ambassador)

**关键总结**:
- `Deref` 设计目的：自定义指针类型，不是类型转换
- 反模式原因：违反直觉、不支持子类型、语义差异
- 替代方案：手动转发 / trait / 委托 crate

**一句话总结**:
> 不要用 `Deref` 模拟继承来复用方法，应该手动转发或使用 trait/委托 crate。

---

## 本部分学习总结

### 核心收获

1. **借用优先于 clone**
   - clone 应该是有意为之的数据拷贝决策
   - 能借用时尽量借用

2. **警告管理的正确方式**
   - 不用 `#![deny(warnings)]` blanket 禁止
   - 用命令行或明确列出具体 lint

3. **Deref 的正确用途**
   - 只用于智能指针解引用
   - 不用来模拟继承

### 实践指导

| 场景 | 推荐做法 |
|------|----------|
| 借用检查报错 | 先想借用，再考虑 clone |
| CI 严格要求 | `RUSTFLAGS="-D warnings"` |
| 方法复用 | 手动转发 / trait / 委托宏 |
| 智能指针 | 正确使用 `Deref` |
