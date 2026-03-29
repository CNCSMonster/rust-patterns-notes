# Rust Design Patterns 学习笔记

> 来源：[Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/patterns.html)
>
> 原文版本：`main@f279f35` (2026-03-29 查验)
>
> 部分：Part 2 - Design Patterns (设计模式)

---

## 概述

设计模式是解决常见编程问题的经典方法。本章分为 4 个类别：

- **Behavioural (行为型)**: 对象间的通信和职责分配
- **Creational (创建型)**: 对象的创建机制
- **Structural (结构型)**: 如何组合类和结构体
- **FFI**: 与其他语言交互的模式

**共 14 个小节**

---

## 目录

### Behavioural Patterns

- [3.1.1 Command](#311-command)
- [3.1.2 Interpreter](#312-interpreter)
- [3.1.3 Newtype](#313-newtype)
- [3.1.4 RAII Guards](#314-raii-guards)
- [3.1.5 Strategy](#315-strategy)
- [3.1.6 Visitor](#316-visitor)

### Creational Patterns

- [3.2.1 Builder](#321-builder)
- [3.2.2 Fold](#322-fold)

### Structural Patterns

- [3.3.1 Compose Structs](#331-compose-structs)
- [3.3.2 Prefer Small Crates](#332-prefer-small-crates)
- [3.3.3 Contain unsafety in small modules](#333-contain-unsafety-in-small-modules)
- [3.3.4 Avoid complex type bounds with custom traits](#334-avoid-complex-type-bounds-with-custom-traits)

### FFI Patterns

- [3.4.1 Object-Based APIs](#341-object-based-apis)
- [3.4.2 Type Consolidation into Wrappers](#342-type-consolidation-into-wrappers)

---

## Behavioural Patterns

### 3.1.1 Command

**核心**：把请求封装成对象，Rust 中用 trait 或闭包实现。

**代码示例**:

```rust
// trait 方式
trait Command {
    fn execute(&self);
}
let cmds: Vec<Box<dyn Command>> = vec![...];

// 闭包方式（更 Rust）
type Cmd = Box<dyn Fn()>;
let cmds: Vec<Cmd> = vec![...];
```

**应用**：任务队列、撤销/重做、宏录制

---

### 3.1.2 Interpreter

**核心**：用枚举 + 递归实现 DSL 解释器。

**代码示例**:

```rust
// 枚举 + 递归实现 DSL
enum Expr {
    Number(i32),
    Add(Box<Expr>, Box<Expr>),
    // ...
}

impl Expr {
    fn interpret(&self) -> i32 {
        match self { /* 递归求值 */ }
    }
}
```

**循环引用处理方案**:

| 方案 | 适用场景 |
|------|----------|
| `Box` | 小型 DSL，简单递归 |
| 索引 + Arena | 大型 AST，需要序列化 |
| 静态检查禁止循环 | 配置类 DSL，规则引擎 |
| 索引 + 两阶段构建 | 复杂 DSL，类型系统 |

---

### 3.1.3 Newtype

**核心**：用元组结构体包装类型，获得类型安全和自定义能力。

**代码示例**:

```rust
// 类型安全
struct UserId(u32);
struct OrderId(u32);
// 不能混用！

// 为外部类型实现 trait
struct CommaSeparated(Vec<String>);
impl Display for CommaSeparated { }

// 封装验证
struct Email(String);
Email::new("test@example.com")?;  // 创建即保证有效
```

**使用场景**:
- 防止类型混淆（UserId vs OrderId）
- 为外部类型实现 trait
- 封装验证逻辑（类型保证有效性）
- 语义清晰
- 隔离不同领域

---

### 3.1.4 RAII Guards

**核心**：用守卫对象在作用域结束时自动释放资源。

**代码示例**:

```rust
// 并发保护
let guard = mutex.lock();  // 自动解锁

// 运行时借用检查
let borrow = refcell.borrow();  // 运行时验证借用规则

// 作用域清理
let guard = ScopeGuard::new(|| cleanup());
```

**Guard 的三层含义**:
- 并发保护：`MutexGuard`
- 借用检查：`Ref`/`RefMut`（运行时借用验证）
- 作用域清理：`ScopeGuard`

---

### 3.1.5 Strategy

**核心**：定义可互换的算法族，Rust 中用 trait 实现。

**代码示例**:

```rust
// 用户推荐做法：为闭包实现 trait
trait Strategy {
    fn execute(&self);
}

// 为具体类型实现
struct MyStrategy;
impl Strategy for MyStrategy { }

// 为闭包实现
impl<F: Fn()> Strategy for F {
    fn execute(&self) { self() }
}

// 使用：两种方式都可以
fn run_strategy(s: &dyn Strategy) {
    s.execute();
}

run_strategy(&MyStrategy);
run_strategy(&|| println!("Hello"));
```

**实现方式对比**:

| 方式 | 优点 | 缺点 |
|------|------|------|
| trait 对象 | 运行时切换 | 虚表调用 |
| 泛型 | 性能优，内联 | 编译时确定 |
| 闭包 + trait | 两者兼得 | 需要额外定义 |

---

### 3.1.6 Visitor

**核心**：Visitor 封装了一个操作异构对象集合的算法，可以在不修改数据的情况下添加新算法。

**代码示例**:

```rust
// 1. 数据结构 (AST)
pub enum Expr {
    IntLit(i64),
    Add(Box<Expr>, Box<Expr>),
    Sub(Box<Expr>, Box<Expr>),
}

// 2. 抽象 Visitor trait
pub trait Visitor<T> {
    fn visit_expr(&mut self, e: &Expr) -> T;
}

// 3. 具体 Visitor (解释器)
struct Interpreter;
impl Visitor<i64> for Interpreter {
    fn visit_expr(&mut self, e: &Expr) -> i64 {
        match *e {
            Expr::IntLit(n) => n,
            Expr::Add(ref lhs, ref rhs) =>
                self.visit_expr(lhs) + self.visit_expr(rhs),
            Expr::Sub(ref lhs, ref rhs) =>
                self.visit_expr(lhs) - self.visit_expr(rhs),
        }
    }
}

// 4. 可选：walk_* 函数复用遍历逻辑
pub fn walk_expr<V: Visitor<i64>>(visitor: &mut V, e: &Expr) {
    match *e {
        Expr::Add(ref lhs, ref rhs) => {
            visitor.visit_expr(lhs);
            visitor.visit_expr(rhs);
        }
        // ...
    }
}
```

**核心价值**:
- 复用遍历逻辑
- 减少样板代码
- 解耦数据与算法
- 切面插入（调试/监控）

**Visitor 组合用法**:

```rust
// 1. 链式处理（Pipeline）
let ast = TypeChecker.visit(ast);
let ast = Optimizer.visit(ast);
let code = CodeGen.visit(ast);

// 2. 包装器（Decorator）
let visitor = LoggingVisitor {
    inner: CachedVisitor {
        inner: Optimizer,
    }
};

// 3. serde 中的 Visitor
impl<'de> Visitor<'de> for MyTypeVisitor {
    type Value = MyType;
    fn visit_map<V>(self, mut map: V) -> Result<MyType, V::Error> { }
}
```

**适用**：异构数据 + 多算法；Rust 实现：trait + walk_*；主要场景：serde 等序列化库

---

## Creational Patterns

### 3.2.1 Builder

**核心**：用 builder helper 构造对象，解决 Rust 无构造函数重载/默认参数的问题。

**代码示例**:

```rust
// 简单：普通构造方法
impl Foo {
    fn new(bar: String) -> Self {
        Foo { bar }
    }
}

// 中等：手写 Builder
struct FooBuilder { bar: Option<String> }
impl FooBuilder {
    fn bar(mut self, b: String) -> Self { 
        self.bar = Some(b); 
        self 
    }
    fn build(self) -> Foo { 
        Foo { bar: self.bar.unwrap() } 
    }
}

// 复杂：bon crate（推荐）
use bon::Builder;
#[derive(Builder)]
struct Foo {
    bar: String,
    #[builder(default = 42)]
    count: u32,
}
```

**使用场景分级**:

| 复杂度 | 方案 |
|--------|------|
| 简单 | 普通 `new()` 方法 |
| 中等 | 手写 Builder |
| 复杂 | `bon` crate |

---

### 3.2.2 Fold

**核心**：对 AST 递归转换，创建新数据结构。

**重要区分**：`Iterator::fold()` ≠ Fold 模式

```rust
// Iterator::fold() - 聚合成单个值（和 Fold 模式无关！）
let sum = vec![1, 2, 3].iter().fold(0, |acc, x| acc + x);  // 6

// Fold 模式 - 数据结构转换
let hir_ast = folder.fold_expr(ast_expr);  // 新 AST
```

**代码示例**:

```rust
// 实际场景：常量折叠
struct ConstantFolder;
impl Folder for ConstantFolder {
    fn fold_expr(&mut self, e: Box<Expr>) -> Box<Expr> {
        match *e {
            // 1 + 2 → 3
            Expr::Binary(Op::Add, 
                Box::new(Expr::Int(a)), 
                Box::new(Expr::Int(b))) => {
                Box::new(Expr::Int(a + b))
            }
            _ => e,
        }
    }
}

// syn 库（过程宏）用类似模式
use syn::visit_mut::{self, VisitMut};
impl VisitMut for MyTransform {
    fn visit_expr_mut(&mut self, e: &mut Expr) { }
}
```

**实际场景**:
- 编译器 AST → HIR 转换
- 宏展开
- 常量折叠优化

---

## Structural Patterns

### 3.3.1 Compose Structs

**核心**：将大结构体拆分成多个小结构体再组合，实现独立借用字段。

**⚠️ 原文示例问题**:

```rust
// 原文示例：拆分后函数签名也变了
fn print_database(
    connection_str: ConnectionString,  // 不再是 &Database
    timeout: Timeout,
    pool_size: PoolSize,
) { }
```

> 💭 笔记作者观点：
> - 通过改变函数签名来"解决"问题，不是真正的解决方案
> - 如果函数参数仍是 `&Database`，借用冲突依然存在
> - **本质是借用检查的基本技巧，不是设计模式**

**更实用的做法**:

```rust
// ✅ 更地道的做法：destructuring
fn process(db: &mut Database) {
    let Database { connection_string, timeout, pool_size } = db;
    // 或直接用 &db.field1, &db.field2
}

// ✅ Rust 本身支持字段独立借用
let x = &mut d.a;
let y = &d.b;  // 完全可以
```

**真正需要拆分的场景**:
- 需要为字段实现不同 trait
- 类型安全（Newtype）
- 模块封装需求
- 字段本身有复杂逻辑

---

### 3.3.2 Prefer Small Crates

**核心**：优先使用小而专注的 crate，每个 crate 做好一件事。

**优势**:
- 小 crate 更易理解，鼓励模块化
- 支持跨项目复用
- 多 crate 可并行编译

**劣势**:
- 依赖地狱：版本冲突（如 `url:1.0` vs `url:0.5` 类型不兼容）
- 缺乏审核：crates.io 不审核，可能质量差或恶意
- 性能损失：默认无 LTO，优化差

**用户实践原则**：如无必要则不拆，要拆则精心设计

1. **不主动拆分**：
   - 避免过度工程化
   - 减少依赖管理复杂度

2. **需要拆分时**：
   - 做好完善的设计（清晰的 API 边界）
   - 完善的测试（减少版本冲突风险）
   - 考虑语义化版本（semver）兼容性

3. **拆分时机**：
   - 功能真正独立且可复用
   - 有明确的责任边界
   - 可能被其他项目使用

**示例**:

```
// 好的拆分：
my-lib/
├── Cargo.toml
├── my-lib-core/    # 核心逻辑，独立
├── my-lib-http/    # HTTP 相关，可选
└── my-lib-cli/     # CLI 工具，可选

// 避免的拆分：
my-lib/
├── Cargo.toml
├── my-lib-types/   # 只有几个类型定义 ❌
├── my-lib-utils/   # 只有几个工具函数 ❌
└── my-lib/         # 主 crate
```

**原则**：如无必要则不拆，要拆则完善设计 + 测试，减少版本冲突风险

---

### 3.3.3 Contain unsafety in small modules

**核心**：将 `unsafe` 代码限制在尽可能小的模块内，构建最小的安全接口。

**代码示例**:

```rust
// 内层：最小 unsafe 模块
mod unsafe_impl {
    pub struct RawBuffer { ptr: *mut u8, len: usize }
    impl RawBuffer {
        pub unsafe fn new(ptr: *mut u8, len: usize) -> Self { }
        pub unsafe fn get(&self, idx: usize) -> u8 { }
    }
}

// 外层：安全接口
pub mod safe_api {
    pub struct SafeBuffer { inner: RawBuffer }
    impl SafeBuffer {
        pub fn new(data: Vec<u8>) -> Self { }
        pub fn get(&self, idx: usize) -> Option<u8> { }
    }
}
```

**用户观点**:
- 这是 Rust 本身提供两套语法（safe/unsafe）而产生的模式
- **要点**：
  1. unsafe 代码集中起来
  2. 集中检查和提供安全保证
  3. 明确安全和不安全的边界
  4. 同时通过 unsafe 提供足够的底层掌控和性能优化空间

**场景**：FFI/原始指针/并发原语；标准库例子：Vec/String/Cell/Mutex

---

### 3.3.4 Avoid complex type bounds with custom traits

**核心**：当 trait bounds 过于复杂时，引入新 trait 来简化。

**代码示例**:

```rust
// ❌ 复杂 bounds
struct Value<
    G: FnMut() -> Result<T, Error>,
    S: Fn(&T) -> Status,
    T: Display
> { /* ... */ }

// ✅ 用 trait 简化
trait Getter {
    type Output: Display;
    fn get_value(&mut self) -> Result<Self::Output, Error>;
}

impl<F: FnMut() -> Result<T, Error>, T: Display> Getter for F {
    type Output = T;
    fn get_value(&mut self) -> Result<Self::Output, Error> { self() }
}

struct Value<G: Getter, S: Fn(&G::Output) -> Status> { /* ... */ }
```

**核心价值**:
- 类型参数：3 个 → 2 个
- 可读性：`FnMut() -> Result<T, Error>` → `Getter`
- 类型擦除：容易 (`Box<dyn Getter>`)

**用户观点**：用一个 trait 来把复杂的 trait bound 中若干约束集中到一起

---

## FFI Patterns

### 3.4.1 Object-Based APIs

**核心**：设计 FFI API 时，采用"基于对象的 API"模式，明确所有权和生命周期边界。

**设计原则**:

| 类型 | 所有权 | 管理 | 可见性 |
|------|--------|------|--------|
| Encapsulated | Rust 拥有 | 用户管理 | 不透明 |
| Transactional | 用户拥有 | 用户管理 | 透明 |

**例子**: POSIX DBM API

```c
// C 语言视角
struct DBM;  // 不透明类型
typedef struct { void *dptr; size_t dsize; } datum;  // 透明类型

DBM* dbm_open(...);           // Rust 拥有
datum dbm_firstkey(DBM*);     // 生命周期绑定
void dbm_close(DBM*);
```

**代码示例**:

```rust
// Rust 内部 - safe 代码
pub struct Dbm {
    data: Vec<i32>,  // Rust 完全拥有
}

impl Dbm {
    // ✅ 完全是 safe Rust
    pub fn process(&mut self) {
        for x in &mut self.data { *x *= 2; }
    }
}

// FFI 边界 - 只负责转换
#[no_mangle]
pub extern "C" fn dbm_process(db: *mut Dbm) {
    unsafe { (*db).process() }  // unsafe 只在这一行
}
```

**核心**：Encapsulated(Rust 拥有) + Transactional(用户拥有)；unsafe 只在边界，内部 safe

---

### 3.4.2 Type Consolidation into Wrappers

**核心**：将多个相关类型合并到一个"包装器类型"中，最小化内存不安全的风险。

**问题背景**:
- Rust 的生命周期保证内存安全
- 导出到 FFI 时，类型变成指针，生命周期信息丢失
- 用户需要管理生命周期，容易出现 use-after-free

**代码示例**:

```rust
// ✅ 包装器模式 - 生命周期绑定在一起
struct MySetWrapper {
    myset: MySet,
    iter_next: usize,  // 迭代状态内嵌（只是索引，无生命周期）
}

impl MySetWrapper {
    pub fn first_key(&mut self) -> Option<&Key> {
        self.iter_next = 0;
        self.next_key()
    }

    pub fn next_key(&mut self) -> Option<&Key> {
        // 每次调用重新创建迭代器，从当前位置继续
        if let Some(next) = self.myset.keys().nth(self.iter_next) {
            self.iter_next += 1;
            Some(next)
        } else {
            None
        }
    }
}
```

**用户理解**:
- 相当于自己实现一个跨 FFI 的没有生命周期的迭代器
- 核心技巧：把"持有引用的迭代器"变成"带状态的索引"

**⚠️ 局限性**（原文承认）:
- 依赖 `nth()` 的高效实现
- 对于 `HashSet`/`HashMap` 等容器，每次 `nth()` 是 O(n)，总体 O(n²)
- 仅适用于支持随机访问的容器（如 `Vec`）
- 原文：真正安全的实现 "incredibly difficult"

---

## 本部分学习总结

### 核心收获

1. **类型安全思维**（Newtype）
   - 用类型系统把隐式假设变成显式保证
   - 零开销抽象

2. **资源管理思维**（RAII）
   - 同步资源用 Drop
   - async 资源用显式 close

3. **安全边界思维**（Contain unsafety + FFI 模式）
   - unsafe 集中到最小模块，对外提供安全接口
   - FFI 中数据在 Rust 内部，unsafe 只在边界
   - 把"持有引用的迭代器"变成"带状态索引的包装器"

### 模式质量评价

**真正重要的模式**：
- Newtype、RAII Guards、Contain unsafety —— 充分利用 Rust 安全特性

**特定场景有用**：
- Visitor、Strategy、Builder —— 经典设计模式的 Rust 实现

**有争议的模式**：
- Compose Structs —— 本质是借用检查基本技巧，不是设计模式
- 部分示例为了模式而模式，没有清晰对比优劣

### Idioms vs Patterns 区别

| 方面 | Idioms | Patterns |
|------|--------|----------|
| 定位 | 日常编码习惯 | 设计模板 |
| Rust 特色 | 借用、所有权 | 类型系统、安全边界 |
| 使用频率 | 高 | 中/低 |

### 实践指导

| 场景 | 推荐模式 |
|------|----------|
| 防止类型混淆 | Newtype |
| 资源清理 | RAII / 显式 close |
| 包装 unsafe | Contain unsafety |
| 复杂对象构建 | Builder（bon crate） |
| AST 处理 | Visitor / Fold |
| FFI 库设计 | Object-Based APIs + Type Consolidation |
