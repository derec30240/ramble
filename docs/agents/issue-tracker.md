# Issue 跟踪：GitHub

本仓库的 issue 与 PRD 都以 GitHub issue 形式存在，一律通过 `gh` CLI 操作。

## 约定

- **创建 issue**：`gh issue create --title "..." --body "..."`，多行正文用 heredoc
- **读取 issue**：`gh issue view <number> --comments`，用 `jq` 过滤评论并一并取标签
- **列出 issue**：`gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`，按需加 `--label`、`--state` 过滤
- **评论**：`gh issue comment <number> --body "..."`
- **加/减标签**：`gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **关闭**：`gh issue close <number> --comment "..."`

仓库信息由 `git remote -v` 推断——在克隆目录内运行 `gh` 时自动完成。

## PR 是否作为需求入口

**PR 作为需求入口：否。**（若本仓库把外部 PR 当作功能请求处理则改为"是"；`/triage` 读取此开关。）

设为"是"时，PR 走与 issue 相同的标签与状态机，用 `gh pr` 等价命令：

- **读 PR**：`gh pr view <number> --comments`，diff 用 `gh pr diff <number>`
- **列出待 triage 的外部 PR**：`gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`，只保留 `authorAssociation` 为 `CONTRIBUTOR`、`FIRST_TIME_CONTRIBUTOR`、`NONE` 的（丢弃 `OWNER`/`MEMBER`/`COLLABORATOR`）
- **评论/标签/关闭**：`gh pr comment`、`gh pr edit --add-label`/`--remove-label`、`gh pr close`

GitHub 的 issue 与 PR 共用一个编号空间，裸编号 `#42` 可能是任一种——先 `gh pr view 42`，失败再回退 `gh issue view 42`。

## 当某个 skill 说"发布到 issue tracker"

创建一个 GitHub issue。

## 当某个 skill 说"获取相关工单"

运行 `gh issue view <number> --comments`。

## Wayfinding 操作

供 `/wayfinder` 使用。**地图**是一个 issue，**子工单**是挂在它下面的 issue。

- **地图**：单个带 `wayfinder:map` 标签的 issue，正文承载 Notes / Decisions-so-far / Fog。`gh issue create --label wayfinder:map`
- **子工单**：通过 GitHub sub-issue 关联到地图（`gh api` 走 sub-issues 端点）。sub-issue 不可用时，把子工单加入地图正文的任务清单，并在子工单正文顶部写 `Part of #<map>`。标签：`wayfinder:<type>`（`research`/`prototype`/`grilling`/`task`）。被认领后指派给执行者
- **阻塞**：用 GitHub **原生 issue 依赖**——规范且 UI 可见。加边：`gh api --method POST repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by -F issue_id=<blocker-db-id>`，其中 `<blocker-db-id>` 是阻塞者的数字**数据库 id**（`gh api repos/<owner>/<repo>/issues/<n> --jq .id`，**不是** `#编号` 或 `node_id`）。GitHub 通过 `issue_dependencies_summary.blocked_by` 报告未关闭阻塞者数量（即活跃闸门）。依赖功能不可用时，回退为子工单正文顶部的 `Blocked by: #<n>, #<n>` 行。所有阻塞者关闭即解除阻塞
- **frontier 查询**：列出地图的未关闭子工单（`gh issue list --state open`，按 sub-issue/任务清单圈定范围），剔除仍有未关闭阻塞者（`issue_dependencies_summary.blocked_by > 0`，或 `Blocked by` 行里仍有未关闭 issue）或已有指派者的；按地图顺序取第一个
- **认领**：`gh issue edit <n> --add-assignee @me`——session 的第一个写操作
- **完结**：`gh issue comment <n> --body "<答案>"`，然后 `gh issue close <n>`，再把上下文指针（gist + 链接）追加到地图的 Decisions-so-far
