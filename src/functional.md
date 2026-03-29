# Rust Functional Programming 学习笔记

> 来源：[Rust Unofficial Patterns](https://rust-unofficial.github.io/patterns/functional-intro.html)
>
> 原文版本：`main@f279f35` (2026-03-29 查验)
>
> 部分：Part 4 - Functional Programming (函数式编程)

---

## 概述

函数式编程范式在 Rust 中的应用和实践。

**共 3 个小节**

---

## 目录

- [5.1 Programming paradigms](#51-programming-paradigms)
- [5.2 Generics as Type Classes](#52-generics-as-type-classes)
- [5.3 Functional Optics](#53-functional-optics)

---

## 5.1 Programming paradigms

> **状态**: ✅ 已完成

**核心**：**命令式**描述"如何做"，**声明式**描述"做什么"。

**命令式示例**：
```rust
let mut sum = 0;
for i in 1..11 {
    sum += i;
}
println!("{sum}");
```
- 需要像编译器一样逐步跟踪状态变化
- 这是大多数人学习编程的起点

**声明式示例**：
```rust
println!("{}", (1..11).fold(0, |a, b| a + b));
```
- `fold` 是函数组合（来自 Haskell 的约定）
- 描述"对 1 到 10 进行累加"，而非具体步骤

**关键对比**：

| 方面 | 命令式 | 声明式 |
|------|--------|--------|
| 描述 | **how** 如何做 | **what** 做什么 |
| 状态 | 显式跟踪变化 | 隐藏状态变化 |
| 思维 | 步骤序列 | 函数组合 |
| Rust 中的体现 | `for`/`while` 循环 | `iter().map().fold()` |

**关键总结**:
- 命令式：描述如何做，显式状态变化
- 声明式：描述做什么，函数组合
- Rust 鼓励声明式：Iterator 链式调用

**一句话总结**:
> 命令式描述如何做，声明式描述做什么。

---

## 5.2 Generics as Type Classes

> **状态**: ✅ 已完成

**核心**：Rust 的泛型设计更像函数式语言（如 Haskell），泛型参数实际上是**类型类约束**，不同的泛型参数会创建**不同的类型**。

**关键概念 - Monomorphization（单体化/单态化）**：
- 编译时将泛型代码转换为多个具体类型的独立版本
- `Vec<i32>` 和 `Vec<char>` 是**两个不同的类型**
- 编译器会为每个具体类型生成独立代码
- 优点：运行时无开销；缺点：代码膨胀

**三种语言泛型机制对比**：

| 特性 | Java | C++ | Rust |
|------|------|-----|------|
| **实现机制** | 类型擦除（Type Erasure） | 模板单体化 | 泛型单体化 |
| **运行时泛型信息** | ❌ 无（擦除为 Object） | ❌ 无 | ❌ 无 |
| **代码生成** | 一份代码，运行时转换 | 每个类型生成一份 | 每个类型生成一份 |
| **二进制大小** | ✅ 小 | ❌ 大 | ❌ 大 |
| **运行效率** | ⚠️ 有类型转换开销 | ✅ 无间接层 | ✅ 无间接层 |
| **特化方法** | ❌ 不支持 | ✅ 模板特化 | ✅ 多个 `impl` 块 |
| **类型安全** | 编译时 + 运行时转换 | 编译时 | 编译时 |

**验证结论**：
- **书中表述有误**：将 C++ 和 Java 混为一谈，两者机制**完全不同**
- **C++ 和 Rust 泛型本质相同**：都是编译时单体化
- **Java 泛型 = 类型擦除**：运行时不存在泛型信息，用 `Object` 替代
- **Rust 的优势**：`impl` 块语法比 C++ 模板特化更简洁，与 trait 系统深度整合

**问题示例 - 运行时 vs 编译时决策**：

```rust
// ❌ 运行时决策：用枚举包装
enum AuthInfo {
    Nfs(crate::nfs::AuthInfo),
    Bootp(crate::bootp::AuthInfo),
}

struct FileDownloadRequest {
    file_name: PathBuf,
    authentication: AuthInfo,
    mount_point: Option<PathBuf>,  // 只有 NFS 需要
}

// 调用者必须处理 None
fn mount_point(&self) -> Option<&Path> {
    self.mount_point.as_ref()
}
```

**✅ 泛型解决方案 - 编译时分离 API**：

```rust
// 1. 定义协议 trait
pub(crate) trait ProtoKind {
    type AuthInfo;
    fn auth_info(&self) -> Self::AuthInfo;
}

// 2. 具体协议类型
pub struct Nfs { /* ... */ }
impl ProtoKind for Nfs { /* ... */ }

pub struct Bootp;
impl ProtoKind for Bootp { /* ... */ }

// 3. 泛型请求类型
struct FileDownloadRequest<P: ProtoKind> {
    file_name: PathBuf,
    protocol: P,
}

// 4. 通用方法
impl<P: ProtoKind> FileDownloadRequest<P> {
    fn file_path(&self) -> &Path { &self.file_name }
    fn auth_info(&self) -> P::AuthInfo { self.protocol.auth_info() }
}

// 5. 特定协议方法
impl FileDownloadRequest<Nfs> {
    fn mount_point(&self) -> &Path { self.protocol.mount_point() }
}
```

**使用效果**：

```rust
// ❌ 编译错误：Bootp 没有 mount_point() 方法
let request: FileDownloadRequest<Bootp> = ...;
request.mount_point();  // ❌ 编译错误！
```

**优势**：
- 编译时错误检测，而非运行时检查
- 共享字段去重
- impl 块按状态组织，更清晰

**劣势**：
- 增加二进制大小（单体化导致）

**实际应用场景**：
| 场景 | 例子 |
|------|------|
| 标准库 | `Vec<u8>` 可从 `CString` 转换 |
| 嵌入式 | `embedded-hal` 静态验证引脚配置 |
| HTTP | `hyper` 不同连接器有不同方法 |
| Type State 模式 | 对象基于内部状态获得/失去 API |

**替代方案**：
- 需要"分割 API" → 考虑 Builder Pattern
- API 相同仅行为不同 → 考虑 Strategy Pattern

**关键总结**：
- 泛型 = 类型类约束，不同参数 = 不同类型
- 优势：编译时检查、代码组织清晰
- 代价：二进制大小增加
- 应用：Type State、嵌入式、HTTP 客户端等

**一句话总结**：
> 用泛型将运行时决策移到编译时，让类型系统帮你检查错误，代价是二进制大小增加。

---

## 5.3 Functional Optics

> **状态**: ✅ 已完成

**核心**：Optics（光学/透镜）是函数式语言的 API 设计模式，用于组合行为和属性。Rust 不直接支持 Optics，但这个概念有助于理解某些 API（如 Serde）。

### 三种 Optics

#### 1. The Iso（同构）

最简单的值转换器，一对函数在两个类型间转换。

```rust
struct ConcordanceSerde {}
impl ConcordanceSerde {
    fn serialize(value: Concordance) -> String { /* A → B */ }
    fn deserialize(value: String) -> Concordance { /* B → A */ }
}
```

**特点**：两个固定类型之间的转换。

#### 2. The Poly Iso（多态同构）

允许泛型类型，返回单一类型。

```rust
// 标准库中的例子
pub trait FromStr: Sized {
    type Err;
    fn from_str(s: &str) -> Result<Self, Self::Err>;
}

pub trait ToString {
    fn to_string(&self) -> String;
}
```

**问题**：
- `to_string` 不指明格式（JSON? XML?）
- 每个类型都要手写实现，难以扩展

#### 3. The Prism（棱镜）

"更高一层"的泛型，支持多种格式。

```text
Serde[T, F]:
  serialize: T, F -> String
  deserialize: String, F -> Result[T, Error]
```

- `T` = 数据类型（User, Product, Order...）
- `F` = 格式类型（JSON, YAML, XML, CBOR...）

### Serde 的三层架构

| 层级 | Trait | 职责 | 谁实现 |
|------|-------|------|--------|
| **顶层** | `Serialize`/`Deserialize` | 用户数据类型 | 用户（宏生成） |
| **中层** | `Visitor` | 构造/析构逻辑 | 宏生成 |
| **底层** | `Serializer`/`Deserializer` | 格式特定实现 | 格式库 |

```
┌─────────────────────────────────────┐
│ 顶层：Deserialize                  │ ← User::deserialize()
│   #[derive(Deserialize)]           │   创建 Visitor 并传递
│   struct User { ... }              │
├─────────────────────────────────────┤
│ 中层：Visitor                      │ ← UserVisitor::visit_map()
│   visit_map, visit_str, visit_u64  │   被 Deserializer 驱动
├─────────────────────────────────────┤
│ 底层：Deserializer                 │ ← JsonDeserializer
│   解析 JSON 字节，调用 Visitor      │   解析格式，反向调用
└─────────────────────────────────────┘
```

### 数据访问层：两种形式

**形式 1：基础类型直接传值**

```rust
pub trait Visitor<'de> {
    // 基础类型：直接传递值
    fn visit_bool<E>(self, v: bool) -> Result<Self::Value, E>;
    fn visit_u64<E>(self, v: u64) -> Result<Self::Value, E>;
    fn visit_str<E>(self, v: &str) -> Result<Self::Value, E>;
    fn visit_i64<E>(self, v: i64) -> Result<Self::Value, E>;
}
```

**形式 2：复杂类型用访问 trait**

```rust
pub trait Visitor<'de> {
    // 复杂类型：需要中间访问层
    fn visit_map<V>(self, visitor: V) -> Result<Self::Value, V::Error>
    where V: MapAccess<'de>;
    
    fn visit_seq<V>(self, visitor: V) -> Result<Self::Value, V::Error>
    where V: SeqAccess<'de>;
    
    fn visit_enum<V>(self, visitor: V) -> Result<Self::Value, V::Error>
    where V: EnumAccess<'de>;
}
```

**为什么有这种区分**：
- 基础类型：值已解析完成，直接传递
- 复杂类型：需要进一步访问，按需解析

### 中间访问层：MapAccess

**为什么需要 MapAccess**：

| 问题 | 没有 MapAccess | 有 MapAccess |
|------|---------------|--------------|
| **耦合度** | Visitor 绑定具体 Deserializer | Visitor 只依赖 trait |
| **实现次数** | N 类型 × M 格式 = N×M 次 | N 类型 + M 格式 = N+M 次 |
| **解析方式** | 一次性加载所有数据 | 按需解析，流式支持 |

**MapAccess trait 定义**：

```rust
pub trait MapAccess<'de> {
    type Error: Error;
    
    // 方法级泛型：每次调用可以是不同类型
    fn next_key<K>(&mut self) -> Result<Option<K>, Self::Error>
    where K: Deserialize<'de>;
    
    fn next_value<V>(&mut self) -> Result<V, Self::Error>
    where V: Deserialize<'de>;
}
```

**类型约束关系**：

| 类型参数 | 级别 | 绑定到 | 谁决定 |
|----------|------|--------|--------|
| `'de` | trait 级 | `MapAccess<'de>` | Deserializer 实现 |
| `type Error` | 关联类型 | `MapAccess` 实现 | Deserializer 实现 |
| `V` (visit_map 的泛型) | 方法级 | `visit_map` 方法 | Deserializer 调用时 |
| `K` (next_key 的泛型) | 方法级 | `next_key` 方法 | Visitor 调用时 |
| `V` (next_value 的泛型) | 方法级 | `next_value` 方法 | Visitor 调用时 |

**具体实现**（由 Deserializer 决定）：

| 格式库 | `V` 的具体类型 |
|--------|---------------|
| serde_json | `JsonMapAccess<'de>` |
| serde_yaml | `YamlMapAccess<'de>` |
| serde_cbor | `CborMapAccess<'de>` |
| serde_xml | `XmlMapAccess<'de>` |

### 完整交互流程

```rust
// 用户代码
let user: User = serde_json::from_str(json)?;

// 内部调用序列：
// 1. from_str 创建 JsonDeserializer
// 2. User::deserialize(deserializer) 被调用
//    - 创建 UserVisitor
//    - deserializer.deserialize_map(UserVisitor)
// 3. Deserializer 解析 JSON，创建 JsonMapAccess
// 4. Deserializer 调用 visitor.visit_map(JsonMapAccess)
// 5. Visitor 调用 map.next_key::<String>() 和 map.next_value::<u32>()
// 6. Visitor 构造并返回 User
```

**核心机制 - 控制反转**：

| 组件 | 职责 | 不关心 |
|------|------|--------|
| **Deserialize** | 知道如何构造自己 | 数据格式 |
| **Visitor** | 定义构造步骤 | 数据格式 |
| **Deserializer** | 解析格式，驱动 Visitor | 目标类型 |
| **MapAccess** | 抽象 map 访问接口 | 具体格式 |

**优势**：N 个数据类型 × M 个格式 = N + M 次实现（而非 N×M）

**关键总结**：
- Optics 是函数式 API 设计模式
- Rust 通过 trait + 泛型间接实现
- Serde 用 Prism 概念分离关注点
- 数据访问层：基础类型直接传值，复杂类型用访问 trait
- MapAccess 解耦 Visitor 和 Deserializer，支持按需解析
- 核心机制：Deserializer 反向调用 Visitor

**一句话总结**：
> Optics 是函数式的组合 API 模式，Serde 通过三层架构（Deserialize + Visitor + Deserializer）和数据访问层（基础类型直传 + MapAccess 等 trait）实现 Prism，让数据类型和格式解耦，Deserializer 反向调用 Visitor 是核心机制。

---

## 本部分学习总结

### 核心收获

1. **命令式 vs 声明式**
   - 命令式：描述**how**如何做（for 循环 + 状态变化）
   - 声明式：描述**what**做什么（fold 函数组合）
   - Rust 鼓励声明式：Iterator 链式调用

2. **泛型作为类型类约束**
   - **Java 泛型 = 类型擦除**：运行时不存在泛型信息，用 `Object` 替代
   - **C++ 和 Rust 泛型 = 单体化**：编译时为每个类型生成独立代码
   - **书中表述有误**：C++ 和 Java 机制完全不同
   - Rust 的 `impl` 块语法比 C++ 模板特化更简洁
   - 应用：Type State 模式，用泛型将运行时检查移到编译时

3. **Functional Optics**
   - Iso：两固定类型转换
   - Poly Iso：泛型转换
   - Prism：支持多格式（Serde 的核心）
   - Serde 三层架构：Deserialize + Visitor + Deserializer
   - 数据访问层：
     - 基础类型：直接传值（`visit_u64`, `visit_str`）
     - 复杂类型：访问 trait（`MapAccess`, `SeqAccess`, `EnumAccess`）
   - 核心机制：Deserializer 反向调用 Visitor
   - MapAccess 解耦 Visitor 和 Deserializer，支持按需解析

### 实践指导

| 场景 | 推荐做法 |
|------|----------|
| 编程思维 | 优先声明式（Iterator 链式调用） |
| 复杂对象构建 | 用泛型分离 API（Type State 模式） |
| 序列化/反序列化 | 使用 Serde，理解三层架构 |
| API 设计 | 用 trait 解耦，支持扩展 |
