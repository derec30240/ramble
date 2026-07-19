# Ramble

移动端 AI 对话客户端。每个会话是一棵 git 式消息树——重新生成、编辑重发、从历史节点续发都会产生分叉；内建 GitLens 式树状视图用于浏览与回溯全部对话历史。**对话树只记录有效内容，不是操作日志。**

## 概述

- **项目类型**：Flutter 跨平台 App（v1 仅 Android）
- **核心理念**：会话 = 消息树（非线性聊天历史）；配置与树结构正交；不静默替用户做决定
- **技术栈**：Flutter 3.12+ / Dart / Drift (SQLite) / Riverpod v3 / freezed / gen_l10n
- **架构**：四层单向依赖 — `ui → application → data → domain`（反向 import 一律禁止）

### 架构分层的具体职责

**`domain/`** — 纯 Dart 算法层，零 Flutter、零 IO 依赖。实体（freezed 不可变类）+ 树算法（分叉规则、HEAD 迁移、级联删除、分支名推进、轨道分配），全部行为单测验证。

**`data/`** — 持久化与网络层。Drift schema + DAO、Provider 仓库（密钥走 Keystore、轻设置走 shared_preferences）、ChatAdapter 协议适配器（OpenAI 兼容 / Anthropic）、SSE 流解析。

**`application/`** — 编排层。生成管线状态机、草稿解析、原子建会话、checkout/删除/快照覆盖、"保存为默认"引导——全部以 Riverpod provider 暴露。

**`ui/`** — 仅消费 provider。chat / tree / session / settings / l10n 五个模块。

## 开发命令

```bash
# 安装依赖（含代码生成）
flutter pub get && dart run build_runner build --delete-conflicting-outputs

# 静态分析
flutter analyze

# 运行所有测试
flutter test

# 单测（跳过 widget）
dart run test

# 指定文件
flutter test test/domain/tree/
flutter test test/data/platform/

# 在已连接设备上启动
flutter run

# 构建 Android APK
flutter build apk --debug
```

## 项目结构

```
lib/
├── main.dart                 # 入口
├── domain/
│   ├── model/                # 不可变实体：Session / Node / SessionConfig /
│   │                         #     GenerationSnapshot / Usage / Provider
│   └── tree/                 # 纯函数：分叉规则 / HEAD迁移 / 级联删除 /
│                             #     分支名推进 / 轨道分配
├── data/
│   ├── platform/             # shared_preferences / flutter_secure_storage 封装
│   ├── drift/                # 表定义 + DAO
│   ├── provider/             # Provider 仓库（CRUD、加密存储）
│   ├── adapter/              # ChatAdapter 抽象 + OpenAI/Anthropic 实现
│   └── repository/           # 领域 ↔ 存储互译，事务边界
├── application/              # Riverpod provider：生成管线、草稿解析、
│                             #     checkout / 删除 / 快照覆盖 / 保存为默认
└── ui/
    ├── l10n/                 # gen_l10n 生成，中文优先
    ├── chat/                 # 聊天视图（Markdown 渲染、思考内容折叠）
    ├── tree/                 # GitLens 式树状视图（CustomPainter 轨道图）
    ├── session/              # 会话列表、会话设置、草稿态
    └── settings/             # 软件设置、Provider 管理、默认配置
test/
├── domain/                   # 纯算法测试（无 Flutter 依赖）
├── data/                     # 存储 + 适配器测试（内存库 / fixture）
└── ui/                       # widget 测试
```

## 代码规范

### 文档语言

**本仓库所有文档、issue、评论一律使用中文。** 代码标识符（类名、变量名、方法名）、CLI 命令、标签字符串保持英文。

### 架构边界（⚠️ 不可碰）

- **`domain/` 禁止 import Flutter、Drift、HTTP 库。** 违反意味着领域逻辑浸入了 IO，重构代价巨大
- **`ui/` 禁止直接 import Drift、HTTP 客户端。** UI 只能通过 Riverpod provider 消费数据
- 建一个新文件时第一件事是向上一层看它属于哪个包：依赖倒置（interface 在 data、backend 也在 data）、领域实体（在 domain 不碰任何上层）、编排（在 application 只能 import data+domain）

### 命名

- 类与枚举：PascalCase（`NodeStatus`、`GenerationSnapshot`）
- 变量与方法：camelCase（`checkoutNode`、`rootToHead`）
- 文件：snake_case（`session_config.dart`、`tree_view.dart`）
- 领域术语以 `CONTEXT.md` 为唯一词汇来源——**不得**在同义词间漂移。示例：说"Session"不要说"Chat"；说"Fork"不要说"分支化"

### 实体建模

- 领域实体一律 freezed，不可变，无 setter
- 树算法全为纯函数：输入旧实体 → 输出新实体，内部不持有可变状态
- 方法返回 `(newNode, newHead)` 元组而非原地修改——保证与 Riverpod 不可变状态树兼容

### l10n

- **从第一天就做 i18n。** UI 文案禁止硬编码，全部走 `gen_l10n` 的 `AppLocalizations`
- 默认语言为中文（`zh`）

### 无注释原则

**代码不加注释。** 命名与结构本身应表意——如果一段逻辑需要注释才能读懂，说明命名或结构需要重新设计。唯一的例外：以 ADR 编号标注刻意背离常见惯例的地方（如 `// ADR-0001: 不静默截断`）。

## 测试策略

### 分层命令

```bash
# 领域层（最快，无 Flutter 运行时）
flutter test test/domain/

# 持久化 + 适配器
flutter test test/data/

# UI widget 测试
flutter test test/ui/
```

### 测试分类与要求

| 层级 | 测试类型 | 命令 | 要求 |
|------|---------|------|------|
| domain | 纯 Dart 单测 | `flutter test test/domain/` | 每个公共函数必须有测试；分叉三规则、级联删除、分支名推进的不变量必须全覆盖 |
| data | 集成测试 | `flutter test test/data/` | Drift 走内存库（`_openInMemory`）；适配器走 SSE fixture，不调真实网络 |
| ui | widget 测试 | `flutter test test/ui/` | 关键交互路径（发送消息、停止生成、树视图点选检出）有烟雾测试 |

### 测试前置检查（每次修改代码后必须通过）

```bash
flutter analyze && flutter test
```

## 工单工作流

### Issue tracker

工单在 GitHub Issues，通过 `gh` CLI 操作。细则见 [`docs/agents/issue-tracker.md`](docs/agents/issue-tracker.md)。

### Triage 标签

| 标签 | 含义 |
|------|------|
| `needs-triage` | 待评估 |
| `needs-info` | 等待补充信息 |
| `ready-for-agent` | 规格完备，智能体可直接执行 |
| `ready-for-human` | 需要人类实现 |
| `wontfix` | 不予处理 |

### 按 frontier 施工（⚠️ 核心纪律）

1. `gh issue list --state open --label ready-for-agent --json number,title` 列出所有就绪工单
2. 取第一个**无未完成阻塞者**的工单——只读工单页面的 "Blocked by" 区域即可
3. `/implement` 在新会话中执行该工单；完成后 `gh issue close <number>`
4. **清上下文，取下一个 frontier**——不要在同一个会话里连续施工多张工单

### 阻塞依赖操作

```bash
# 查询工单的数据库 id（给阻塞关系用）
gh api repos/derec30240/ramble/issues/<number> --jq .id

# 加阻塞边
gh api --method POST repos/derec30240/ramble/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>
```

## 领域文档

在编写或审查代码前，必须读取：

- **[`CONTEXT.md`](CONTEXT.md)** — 18 个领域术语的唯一定义（Session / Node / Fork / HEAD / Checkout / Branch / 生成快照 / 会话配置 / 累计用量…），产出中不得漂移到术语表标记为 _Avoid_ 的同义词
- **[`docs/adr/`](docs/adr/)** — 架构决策记录（如 ADR-0001「不做静默上下文截断」）。产出一旦与 ADR 相抵触，必须显式指出而非静默推翻

## Open questions

在对项目做设计层面的决策时，需要参考项目的待解决问题和未来方向。

目前，项目处于初期阶段，我们还没录全 Open questions。如果你觉得有必要记录的话我们再录。

## Summarize conversation

如果对话的复杂度已经很高（至少有过两次 `/grilling` + 一次 `/implement`，或等量的设计讨论），先用 `/handoff` 压缩当前对话成交接文档，再继续。不要在一个越拉越长的会话中持续施工。

## Agent skills

### Issue tracker

工单跟踪在 GitHub Issues，通过 `gh` CLI 操作。见 [`docs/agents/issue-tracker.md`](docs/agents/issue-tracker.md)。

### Triage labels

默认五角色词表（`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human`、`wontfix`）。见 [`docs/agents/triage-labels.md`](docs/agents/triage-labels.md)。

### Domain docs

单上下文：仓库根部 `CONTEXT.md` + `docs/adr/`。见 [`docs/agents/domain.md`](docs/agents/domain.md)。
