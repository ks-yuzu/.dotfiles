共通ルールは AGENTS.md を単一の情報源とし、本ファイルはその Claude Code での差分を記述する。
見出しは AGENTS.md と対応させ、競合する場合は本ファイルの記述を優先する。

@~/.agents/AGENTS.md

## 作業環境
### タスク管理
task / task-report skill から参照・更新する。

## 作業フロー
- 方針が複数ありうる場合は、着手前に plan mode で選択肢とトレードオフを提示する。
  実装を進めてから方針を問い直すのは手戻りが大きい
- worktree は EnterWorktree ツール、または `git worktree add` で切る

## レビュー
- 不具合は /code-review、過剰実装は /simplify を起点にする
  - /simplify は既定の観点が品質寄りなので、AGENTS.md の観点 (到達しない防御、窓を閉じない規則、
    落ちないテスト、1 呼び出しの抽象、仕様と重複したコメント) を明示して渡す
  - /simplify は修正まで適用するため、差分を確認してから採否を決める
- 巡を重ねる際は effort を上げる (low/medium → high/max)
- Codex 側のレビューに当てる場合は codex:rescue サブエージェント経由で渡す。
  /codex:review はエージェントから直接呼べない

## エージェントの分担
- 委譲は Agent ツールで行い、model を sonnet / haiku へ落とす
- 探索だけで済むタスクは Explore を使う。読み取り専用で、ファイル本文ではなく結論が返る
