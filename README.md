# Ramble

移动端 AI 对话客户端：会话即 git 式消息树。

每条消息是一个节点；重新生成、编辑重发、从历史节点续发会产生分叉；每个会话有一个 GitLens 式的树状视图用于浏览与管理全部历史。**对话树只记录有效内容，不是操作日志。**

## 项目文档

- [`CONTEXT.md`](./CONTEXT.md) — 领域术语表（唯一词汇来源，18 个术语）
- [`docs/adr/`](./docs/adr/) — 架构决策记录
- [`docs/agents/`](./docs/agents/) — 智能体工作流配置（issue 跟踪、triage 标签、领域文档规则）

## 开发状态

初版开发中。开发路径以 [GitHub Issues](https://github.com/derec30240/ramble/issues) 上带阻塞依赖的工单驱动，按 frontier（无未完成阻塞者）逐单施工。

## 技术栈

- Flutter（v1 仅 Android）
- 四层单向依赖：`ui → application → data → domain`
- Drift (SQLite) / Riverpod v3 / freezed / gen_l10n

## 本地开发

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
