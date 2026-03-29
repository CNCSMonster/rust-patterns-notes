# 补充资源笔记 - Refactoring & Design Principles

> 学习来源：[Rust Patterns - Additional Resources](https://rust-unofficial.github.io/patterns/additional.html)
>
> 原文版本：`main@f279f35` (2026-03-29 查验)
>
> 创建日期：2026-03-29

---

## 📋 设计原则速查表

| # | 缩写 | 全称 | 一句话介绍 |
|---|------|------|-----------|
| 1 | SRP | Single Responsibility Principle | 一个模块只有一个引起它变化的原因 |
| 2 | OCP | Open/Closed Principle | 对扩展开放，对修改关闭 |
| 3 | LSP | Liskov Substitution Principle | Rust 中体现为实现同一 trait 的类型应遵守 trait 的语义约定 |
| 4 | ISP | Interface Segregation Principle | 多个小接口优于一个大接口 |
| 5 | DIP | Dependency Inversion Principle | 依赖抽象而非具体实现 |
| 6 | CRP | Composition Reuse Principle | 优先使用组合而非继承来复用代码 |
| 7 | DRY | Don't Repeat Yourself | 每份知识只有一个表示 |
| 8 | KISS | Keep It Simple, Stupid | 简单应该是设计的关键目标 |
| 9 | LoD | Law of Demeter | 只和直接朋友交谈，不和朋友的朋友交谈 |
| 10 | DbC | Design by Contract | 用类型系统定义明确的接口规范 |
| 11 | - | Encapsulation | 隐藏内部实现，暴露受控接口 |
| 12 | CQS | Command-Query Separation | 查询无副作用，命令不返回值 |
| 13 | POLA | Principle of Least Astonishment | 行为应符合用户预期 |
| 14 | - | Uniform Access | 统一访问方式，不暴露存储还是计算 |
| 15 | - | Single-Choice | 选项列表只在一处定义 |
| 16 | - | Self-Documentation | 代码即文档，命名表达意图 |
| 17 | - | Linguistic-Modular-Units | 模块对应语言的语法单元 |
| 18 | - | Persistence-Closure | 存储对象时同时存储其依赖对象 |

---

## Refactoring（重构）

### 核心要点

重构是将好代码变成优秀代码的关键过程。

### 关键原则

| 原则 | 说明 |
|------|------|
| **使用设计模式** | 用设计模式来 DRY 代码，泛化抽象 |
| **避免反模式** | 反模式虽然诱人，但弊大于利 |
| **使用 Idioms** | 用习惯用法组织代码结构 |

### 重构的实践原则

| 原则 | 说明 |
|------|------|
| **先设计再重构** | 有整体视角和最终目标，避免盲目重构 |
| **无测试不重构** | 测试是重构的安全网 |
| **拆分环节** | 把整个重构过程拆分成可验证的小环节 |
| **多个检查点** | 每个环节完成后可以验证，确保正确 |

### 重构流程

```
1. 整体设计（目标视角）
       ↓
2. 拆分环节（可验证的小步骤）
       ↓
3. 设置检查点（测试、编译验证）
       ↓
4. 逐个小步重构（Small changes）
       ↓
5. 每个环节验证（Tests）
       ↓
6. 完成重构
```

### 关键名言

> "Shortcuts make for long days."（捷径导致长路）

---

## SOLID 原则

### SRP - Single Responsibility Principle（单一职责原则）

**含义**：一个模块应该只有一个引起它变化的原因。

**Rust 体现**：
- 小模块、小 crate
- 一个函数只做一件事

**例子**：

```rust
// ❌ 违反 SRP
fn process_user_data(user: &User) {
    validate(user);
    db.save(user);
    send_email(&user.email);
    log.info("user processed");
}

// ✅ 遵循 SRP
fn validate_user(user: &User) -> Result<()> { ... }
fn save_user(user: &User) -> Result<()> { ... }
fn send_welcome_email(email: &str) -> Result<()> { ... }
```

---

### OCP - Open/Closed Principle（开闭原则）

**含义**：软件实体应该对扩展开放，对修改关闭。

**Rust 体现**：
- trait 扩展，无需修改现有代码
- 泛型允许编译时扩展

**例子**：

```rust
trait Shape {
    fn area(&self) -> f64;
    fn draw(&self);
}

// 添加新形状不需要修改现有代码
struct Triangle { base: f64, height: f64 }
impl Shape for Triangle {
    fn area(&self) -> f64 { (self.base * self.height) / 2.0 }
    fn draw(&self) { println!("Drawing triangle"); }
}
```

**与 ISP 的关系**：
- ISP 是 OCP 的前提：没有小接口，无法优雅扩展
- OCP 是 ISP 的目标：拆分接口是为了更容易扩展

---

### LSP - Liskov Substitution Principle（里氏替换原则）

**Rust 中的正确理解**：

> Rust 中没有传统 OOP 的里氏替换原则（因为没有类继承）。
> 
> Rust 中体现为：**实现同一 trait 的类型应该在相关行为上遵守 trait 的语义约定**。

**例子**：

```rust
// Eq trait 隐含的契约
// 实现 Eq 的类型必须满足等价关系的三个性质：
// 1. 自反性：a == a 总是 true
// 2. 对称性：a == b 等价于 b == a
// 3. 传递性：a == b 且 b == c 则 a == c

#[derive(Eq, PartialEq)]
struct UserId(u32);  // ✅ 正确的实现
```

---

### ISP - Interface Segregation Principle（接口隔离原则）

**含义**：多个专门的接口比一个通用的接口更好。

**Rust 体现**：
- 小 trait 优于大 trait
- 不应该强迫实现不需要的方法

**例子**：

```rust
// ❌ 违反 ISP
trait Worker {
    fn work(&self);
    fn eat(&self);
    fn sleep(&self);
}

// ✅ 遵循 ISP
trait Workable { fn work(&self); }
trait Eatable { fn eat(&self); }
trait Sleepable { fn sleep(&self); }
```

---

### DIP - Dependency Inversion Principle（依赖倒置原则）

**含义**：依赖抽象，而不是具体实现。

**"倒置"的含义**：
- 从"抽象依赖实现细节" 倒置为 "实现细节依赖抽象，同时上层业务逻辑也依赖抽象"

**Rust 体现**：
- 依赖 trait 而非具体类型
- `dyn Trait` 或泛型参数

**例子**：

```rust
trait Database {
    fn save_user(&self, user: &User) -> Result<()>;
}

struct UserService {
    db: Box<dyn Database>,  // 依赖抽象
}
```

---

## 其他设计原则

### CRP - Composition Reuse Principle（组合复用原则）

**别名**：Composition over Inheritance（组合优于继承）

**含义**：优先使用对象组合，而不是类继承来复用代码。

**Rust 体现**：
- Rust 没有类继承，天然支持 CRP
- struct 组合 + trait

**例子**：

```rust
trait Engine {
    fn start(&self);
    fn drive(&self);
}

struct Car {
    engine: Box<dyn Engine>,  // 组合
    door_count: u32,
}

// 可以动态改变行为
car.engine = Box::new(ElectricEngine);
```

---

### DRY - Don't Repeat Yourself（不要重复自己）

**含义**：系统中的每一份知识应该只有一个表示。

**实践方法**：
- 使用 CCD 工具（如 clippy）检测代码克隆
- 提取公共函数、公共类型
- 使用泛型、宏消除重复

**Rust 工具**：

| 工具 | 用途 |
|------|------|
| **函数** | 提取重复逻辑 |
| **泛型** | 提取重复的类型模式 |
| **trait** | 提取重复的行为 |
| **宏** | 提取重复的代码模式 |

**例子**：

```rust
// ✅ 用泛型消除重复
fn print_vec<T: std::fmt::Display>(v: &[T]) {
    for item in v {
        println!("{}", item);
    }
}

// ✅ 用宏消除重复
macro_rules! impl_display {
    ($struct:ident, $unit:literal) => {
        impl std::fmt::Display for $struct {
            fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
                write!(f, "{} {}", self.0, $unit)
            }
        }
    };
}
```

---

### KISS - Keep It Simple, Stupid（保持简单）

**含义**：简单应该是设计的关键目标，应该避免不必要的复杂性。

**与 DRY 的平衡**：
- DRY 和 KISS 需要平衡
- 过度 DRY 会违反 KISS
- 有时适当重复比过度抽象更好

---

### LoD - Law of Demeter（迪米特法则/最少知识原则）

**含义**：一个对象应该对其他对象有尽可能少的了解。

**通俗理解**：只和你的"直接朋友"交谈，不要和"朋友的朋友"交谈。

**例子**：

```rust
// ❌ 违反 LoD：链式调用
let city = user.profile.address.city;

// ✅ 遵循 LoD：委托访问
impl User {
    fn get_city(&self) -> &str {
        &self.profile.address.city
    }
}
let city = user.get_city();
```

---

### DbC - Design by Contract（契约设计）

**含义**：定义正式的接口规范，包括前置条件、后置条件和不变量。

**核心**：利用类型系统，通过设计良好的类型提供约束。

**完整架构**：

```
Design by Contract (Rust)
│
├── 类型系统（最强约束 - 编译时保证）
│   ├── 新类型模式 (Newtype)
│   ├── 类型状态模式 (Type State)
│   └── 生命周期约束
│
├── 返回类型（表达契约 - 编译时强制处理）
│   ├── Result<T, E> - 可能失败
│   ├── Option<T> - 可能为空
│   └── T - 保证成功
│
├── 运行时检查（辅助验证）
│   ├── assert!() - 总是检查
│   ├── debug_assert!() - 仅调试模式
│   └── panic!() - 违反契约
│
└── 测试（验证契约）
    ├── 单元测试 - 单个函数契约
    ├── 集成测试 - 模块间契约
    ├── 属性测试 (proptest) - 验证不变量
    └── 文档测试 - API 示例验证
```

**契约三要素**：

| 要素 | 含义 | 责任方 |
|------|------|--------|
| **前置条件** | 调用前必须满足的条件 | 调用者负责 |
| **后置条件** | 调用后保证的结果 | 实现者负责 |
| **不变量** | 始终成立的条件 | 双方共同维护 |

---

### Encapsulation（封装）

**含义**：隐藏内部实现，暴露受控接口。

**分层封装策略**：

```
封装严格程度
│
├── 对外 API（最严格）
│   └── 私有字段 + 公共方法
│
├── 库内可见 pub(crate)（中等）
│   └── 模块间自由访问，对外隐藏
│
└── 模块内部（最宽松）
    └── 非 pub struct + pub 字段（纯数据载体）
```

---

### CQS - Command-Query Separation（命令查询分离）

**含义**：查询不应该有副作用，命令不应该返回值。

**Rust 体现**：
- `&self` 方法 = 查询（无副作用）
- `&mut self` 方法 = 命令（有副作用）

**例子**：

```rust
impl Stack<T> {
    // 查询
    fn len(&self) -> usize { self.items.len() }
    fn is_empty(&self) -> bool { self.items.is_empty() }
    
    // 命令
    fn push(&mut self, item: T) { self.items.push(item); }
    fn pop(&mut self) -> Option<T> { self.items.pop() }
}
```

---

### POLA - Principle of Least Astonishment（最少惊讶原则）

**含义**：组件的行为应该符合大多数用户的预期。

**Rust 体现**：
- 遵循命名约定（`new()` 创建新实例）
- 运算符符合数学直觉
- 参考标准库的设计

---

### Uniform Access（统一访问原则）

**含义**：所有服务应该通过统一的符号访问，不暴露是存储还是计算。

**Rust 体现**：
- 私有字段 + 公共 getter 方法
- 无参 getter 方法名与字段同名

**例子**：

```rust
struct Circle {
    radius: f64,  // 私有
}

impl Circle {
    pub fn radius(&self) -> f64 { self.radius }
    pub fn area(&self) -> f64 { std::f64::consts::PI * self.radius * self.radius }
}
// 调用者不关心哪些是字段，哪些是计算的
```

---

### Single-Choice（单一选择原则）

**含义**：当系统需要支持一组替代方案时，应该只有一个模块知道它们的完整列表。

**Rust 体现**：
- enum 集中定义所有变体
- match 穷尽检查

**例子**：

```rust
pub enum PaymentMethod {
    CreditCard,
    PayPal,
    BankTransfer,
    // 添加新选项只需改这里
}
```

---

### Self-Documentation（自文档化）

**含义**：代码即文档，命名表达意图。

**实现方法**：
- 清晰的命名
- 类型即文档
- 函数签名清晰
- 文档注释（rustdoc）

---

### Linguistic-Modular-Units（语言模块单元）

**含义**：模块应该对应于所用语言的语法单元。

**Rust 体现**：
- `mod` 定义模块
- 目录/文件对应模块
- `pub` 控制可见性

---

### Persistence-Closure（持久化闭包）

**含义**：存储对象时同时存储其依赖对象，检索时也必须检索其依赖对象。

**通俗理解**：完整存储对象以及对象依赖的数据。

**例子**：

```rust
// ✅ 遵循：完整存储
struct User {
    name: String,
    address: Address,  // 嵌套对象
}

// 序列化时自动包含 address
let json = serde_json::to_string(&user)?;
```

**例外场景（何时不遵循）**：

| 场景 | 原因 | 替代方案 |
|------|------|----------|
| **缓存行敏感** | 避免超过 64B 导致伪共享 | 用 ID/句柄引用冷数据 |
| **延迟加载需求** | 避免初始化慢、内存占用大 | 按需加载 |
| **循环依赖** | 无法完整存储 | 用 ID 打破循环 |
| **大数据集** | 无法一次性加载 | 流式处理 |
| **跨服务边界** | 数据所有权不清晰 | 用 ID 引用 |
| **共享数据** | 多个对象共享同一数据 | 独立存储 |

**决策框架**：

```
Persistence-Closure
       │
       ├── 遵循：数据完整性优先
       │    └── 小数据、强一致性、简单对象图
       │
       └── 不遵循：性能/灵活性优先
            └── 缓存敏感、延迟加载、循环依赖、大数据
```

---

## Additional Resources（额外资源）

### Talks（演讲）

| 演讲 | 演讲者 | 场合 |
|------|--------|------|
| Design Patterns in Rust | Nicholas Cameron | PDRust 2016 |
| Writing Idiomatic Libraries in Rust | Pascal Hertleif | RustFest 2017 |
| Rust Programming Techniques | Nicholas Cameron | LinuxConfAu 2018 |

### Books (Online)

| 资源 | 链接 |
|------|------|
| The Rust API Guidelines | [https://rust-lang.github.io/api-guidelines](https://rust-lang.github.io/api-guidelines) |

---

## 📝 学习总结

### 重构原则

- 先设计再重构（整体视角）
- 无测试不重构
- 拆分环节，设置检查点
- 小步迭代

### SOLID 原则

| 原则 | Rust 体现 |
|------|----------|
| SRP | 小模块、小 crate |
| OCP | trait 扩展 |
| LSP | trait 契约一致性 |
| ISP | 小 trait |
| DIP | 依赖 trait |

### 其他核心原则

| 原则 | 关键点 |
|------|--------|
| CRP | Rust 无类继承，天然支持组合 |
| DRY | 用泛型/宏/trait 减少重复 |
| KISS | 简单优先，与 DRY 平衡 |
| LoD | 委托访问，避免链式调用 |
| DbC | 类型系统表达契约 |
| 封装 | 分层策略（对外严格，对内宽松） |
| CQS | `&self` vs `&mut self` |
| POLA | 符合预期，遵循约定 |
| Uniform Access | getter 方法统一访问 |
| Single-Choice | enum 集中定义选项 |
| Self-Documentation | 代码即文档 |
| Persistence-Closure | 完整存储对象图（有例外） |
