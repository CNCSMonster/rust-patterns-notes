# Rust Idioms 学习笔记

> 📚 来源：[Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/idioms.html)
>
> ✅ 完成日期：2026-03-22

---

## 概述

Idioms 是 Rust 社区的编码规范和最佳实践，代表"地道的 Rust 写法"。除非有充分理由，否则应遵循这些习惯。

**共 15 个小节**

---

## 2.1 Use borrowed types for arguments

### 核心原则

**函数只读取数据时用借用 (`&T`)，需要存储/消耗时用所有权。**

### 代码对比

```rust
// ❌ 获取所有权 - 调用者无法继续使用
fn print_name(name: String) {
    println!("Name: {}", name);
}

let my_name = String::from("Alice");
print_name(my_name);
// println!("{}", my_name);  // ❌ 编译错误

// ✅ 借用 - 调用者可继续使用
fn print_name(name: &str) {
    println!("Name: {}", name);
}

let my_name = String::from("Alice");
print_name(&my_name);
println!("{}", my_name);  // ✅ 可以继续使用
```

### 进阶：使用 `AsRef` 提高通用性

```rust
fn process_path<P: AsRef<std::path::Path>>(path: P) {
    let path_ref = path.as_ref();
}
```

### 关键总结

| 场景 | 推荐 |
|------|------|
| 只读参数 | `&T` / `&str` |
| 需要存储 | 所有权 `T` |
| 通用 API | `AsRef<T>` |
| 需要修改 | `&mut T` |

### 实践讨论

- **原型阶段**：优先用 `&T`，简单直接
- **成熟阶段**：可升级为 `AsRef<T>` 提高通用性

---

## 2.2 Concatenating Strings with format!

### 核心原则

**优先使用 `format!` 宏进行字符串拼接和格式化。**

### 代码对比

```rust
// ❌ 使用 + 操作符 - 需要 clone，不优雅
let s = "Hello".to_string() + ", " + &name;

// ✅ 使用 format! - 清晰简洁
let s = format!("Hello, {}!", name);

// ✅ 多行字符串 - indoc crate
use indoc::indoc;
let sql = indoc! {r#"
    SELECT * FROM users
    WHERE id = $1
"#};
```

### 关键总结

| 场景 | 推荐 |
|------|------|
| 字符串插值 | `format!` |
| 多行文本 | `indoc!` |
| 大量拼接 | `String::with_capacity` + `push_str` |
| 性能敏感 | `write!` 到预分配 buffer |

---

## 2.3 Constructor

### 核心原则

**构造函数命名遵循约定，无参构造优先用 Default。**

### 构造函数模式

| 模式 | 用法 | 适用场景 |
|------|------|----------|
| `new()` | `T::new(args)` | 标准构造函数 |
| `default()` | `T::default()` | 使用 Default trait |
| `from()` | `T::from(other)` | 类型转换（Into/From trait） |
| `with_xxx()` | `T::with_name(x)` | 变体构造函数 |
| `builder()` | `T::builder().x().y().build()` | 复杂对象构建 |

### 实践讨论

- **无参数 + 非 async** → 不定义 `new()`，只实现 `Default::default()`（Clippy 推荐）
- **参数多** → 使用 `bon` crate 的 Builder 宏

```rust
// ✅ 无参构造 - 只用 Default
#[derive(Default)]
struct Config {
    value: u32,
}

// ✅ 多参数 - bon crate
use bon::Builder;

#[derive(Builder)]
struct User {
    name: String,
    #[builder(default = 18)]
    age: u32,
    email: Option<String>,
}
```

---

## 2.4 The Default Trait

### 核心原则

**优先 derive Default，需要自定义时手动实现。**

### 实现方式

```rust
// ✅ 自动派生（字段都有 Default）
#[derive(Default)]
struct Config {
    host: String,  // ""
    port: u16,     // 0
}

// ✅ 手动实现（自定义默认值）
impl Default for Config {
    fn default() -> Self {
        Self {
            host: String::from("localhost"),
            port: 8080,
        }
    }
}

// ✅ 使用 ..Default::default()
let config = Config {
    host: String::from("example.com"),
    ..Default::default()
};
```

### 关键总结

| 场景 | 推荐 |
|------|------|
| 字段都有 Default | `#[derive(Default)]` |
| 自定义默认值 | 手动实现 `Default` |
| 部分自定义 | `..Default::default()` |
| 配置类结构体 | 必备 Default |

---

## 2.5 Collections Are Smart Pointers

### 核心原则

**集合类型是"拥有者句柄"，赋值=Move，传参用借用。**

### 关键理解

```rust
// ✅ Move 语义
let v1 = vec![1, 2, 3];
let v2 = v1;  // v1 失效

// ✅ 传参用借用
fn process_vec(v: &[i32]) { }
fn process_map(m: &HashMap<String, i32>) { }

// ✅ 需要拷贝显式 clone
let v3 = v2.clone();
```

### 类型对比

| 类型 | Move 语义 | Deref | 说明 |
|------|----------|-------|------|
| `Vec<T>` | ✅ | ✅ → `[T]` | 真正的智能指针 |
| `String` | ✅ | ✅ → `str` | 真正的智能指针 |
| `HashMap<K,V>` | ✅ | ❌ | 只有 Move 语义 |

### 关键总结

- 集合赋值 = Move（不是 Copy）
- 函数参数用 `&Collection`
- 需要拷贝用 `.clone()`

---

## 2.6 Finalisation in Destructors

### 核心原则

**利用 Drop trait 实现 RAII，自动清理资源。**

### RAII 模式

```rust
// ✅ 经典例子：文件自动关闭
struct FileHandle {
    fd: i32,
}

impl Drop for FileHandle {
    fn drop(&mut self) {
        println!("Closing file descriptor {}", self.fd);
    }
}

fn main() {
    let file = FileHandle { fd: 42 };
}  // ← drop() 自动调用
```

### async 资源清理

```rust
// ✅ async 资源 - 显式 close 方法
struct AsyncResource {
    conn: Connection,
}

impl AsyncResource {
    async fn close(self) -> Result<()> {
        self.conn.close().await
    }
}

// 使用
resource.close().await?;
// 保护机制：测试 + Code Review
```

### 关键总结

| 场景 | 推荐 |
|------|------|
| 同步资源 | RAII + Drop |
| async 清理 | 显式 `close()` 方法 |
| 保护机制 | 测试 + Review |
| Drop 中 | 不要 panic |

---

## 2.7 mem::{take, replace}

### 核心原则

**所有权交换，不拷贝地替换值。**

### 函数对比

| 函数 | 作用 | 等价于 |
|------|------|--------|
| `mem::replace(&mut a, b)` | 用 b 替换 a，返回旧 a | - |
| `mem::take(&mut a)` | 拿走 a，留下 `default()` | `replace(&mut a, Default::default())` |
| `Option::take()` | 拿走 Option，留下 `None` | `replace(&mut opt, None)` |

### 使用场景

```rust
// 1. 状态机中拿走状态
let data = mem::take(&mut self.data);

// 2. Option 取值
let value = opt.take().unwrap_or_default();

// 3. 重新配置时替换
let old = mem::replace(&mut self.config, new_config);
```

### 关系图

```
mem::replace  ← 最底层
       ↑
       │
   ┌───┴───┐
   │       │
mem::take  Option::take()
```

---

## 2.8 On-Stack Dynamic Dispatch

### 核心原则

**临时批量处理时用栈上借用，避免堆分配。**

### 代码对比

```rust
// ❌ 堆上动态分发
let traits: Vec<Box<dyn Trait>> = vec![
    Box::new(A),
    Box::new(B),
];

// ✅ 栈上动态分发
let a = A;
let b = B;
let traits: [&dyn Trait; 2] = [&a, &b];
```

### 关键总结

| 场景 | 推荐 |
|------|------|
| 临时批量 | `&[&dyn Trait]` |
| 需要所有权 | `Box<dyn Trait>` |
| 性能敏感 | 优先栈上 |
| 不能返回栈上引用 | 生命周期限制 |

---

## 2.9 Foreign function interface (FFI)

### 核心原则

**安全地与 C 等语言交互。**

### 关键要点

```rust
// 1. 字符串转换
use std::ffi::CString;

let rust_str = "hello";
let c_str = CString::new(rust_str).unwrap();
let c_ptr = c_str.as_ptr();  // *const i8

// 2. 错误处理
// C 的 errno → Rust 的 Result
```

### 关键总结

| 场景 | 推荐 |
|------|------|
| 字符串转换 | `CString`/`CStr` |
| 错误处理 | 包装为 Result |
| 类型安全 | Rust 包装层 |

---

## 2.10 Iterating over an Option

### 核心原则

**Option 可以当迭代器用。**

### 代码示例

```rust
// ✅ Some 时执行一次，None 时不执行
for x in Some(5) {
    println!("{}", x);
}

// ✅ 链式调用
let result: Vec<i32> = Some(5)
    .into_iter()
    .map(|x| x * 2)
    .collect();  // [10]
```

---

## 2.11 Pass Variables to Closure

### 核心原则

**理解闭包捕获变量的方式。**

### 捕获方式

```rust
// 1. 借用捕获（默认）
let x = 5;
let closure = || println!("{}", x);

// 2. move 捕获
let x = vec![1, 2, 3];
let closure = move || println!("{:?}", x);

// 3. 可变借用
let mut x = 5;
let mut closure = || x += 1;
```

---

## 2.12 Privacy For Extensibility

### 核心原则

**用隐私控制实现可扩展的 API。**

### 代码示例

```rust
pub struct Config {
    inner: InnerConfig,  // 私有字段
}

impl Config {
    pub fn new() -> Self { }  // 公开构造方法
}
```

---

## 2.13 Easy doc Initialization

### 核心原则

**使用 `..Default::default()` 简化初始化。**

### 代码示例

```rust
let config = Config {
    name: String::from("test"),
    port: 8080,
    ..Default::default()
};
```

> 详见 [2.4 The Default Trait](#24-the-default-trait)

---

## 2.14 Temporary mutability

### 核心原则

**让可变性尽可能局部。**

### 代码示例

```rust
let mut buffer = String::new();
buffer.push_str("hello");
buffer.push_str(" world");
let result = buffer;  // 之后不再需要 mut
```

---

## 2.15 Return consumed arg on error

### 核心原则

**错误时返回原始输入，让调用者决定如何处理。**

### 代码示例

```rust
fn parse(s: String) -> Result<i32, String> {
    s.parse().map_err(|_| s)  // 返回原字符串
}
```

---

## 本部分学习总结

### 核心收获

1. **借用优先** - 参数用 `&T`，避免不必要的所有权转移
2. **format! 宏** - 字符串拼接首选
3. **Default trait** - 无参构造的最佳实践
4. **Move 语义** - 集合类型赋值会转移所有权
5. **RAII** - 同步资源用 Drop，async 资源用显式 close
6. **mem 工具** - `replace`/`take` 用于所有权交换
7. **栈上分发** - 临时批量处理避免堆分配

### 最佳实践

| 场景 | 推荐做法 |
|------|----------|
| 函数参数 | `&T` 或 `AsRef<T>` |
| 字符串 | `format!` / `indoc` |
| 构造 | `new()` / `Default` / `bon` |
| 资源清理 | RAII / 显式 `close()` |
| 集合传参 | `&Vec` / `&HashMap` |

### 常见陷阱

- ❌ 忘记集合是 Move 语义
- ❌ async 资源在 Drop 中无法清理
- ❌ 返回栈上的 trait object 引用
