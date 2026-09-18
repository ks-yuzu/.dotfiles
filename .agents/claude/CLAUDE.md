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
- /codex:review を使う。エージェントから直接呼べないため、codex-companion.mjs を
  バックグラウンドで実行する。利用できない場合は /code-review で代替する
  - 実体は ~/.claude/plugins/cache/openai-codex/codex/<version>/scripts/codex-companion.mjs。
    CLAUDE_PLUGIN_ROOT はコマンド実行時しか入らないので絶対パスで書く。<version> は上がる
  - **焦点を渡せるのは adversarial-review だけ。**review は組み込みレビューア直結で、焦点文を
    渡すとエラーになる。「過剰実装」の巡は adversarial-review に焦点を書く
  - review が受けるのは --base / --scope / --model / --cwd。**--effort は task にしか無い。**
    --cwd は usage に出ないが効くので、worktree を cwd にしなくても回せる
  - **--model は渡さない。**ChatGPT アカウントでは terra も sol も API が 400 で返す。
    companion は名前を検証せず素通しするため、走らせるまで分からない。
    このサブコマンドは model も effort も上げられないので、巡を重ねる時は焦点を変える。
    深くしたいなら task --effort か /code-review へ移る
  - 既定の --scope auto は、作業ツリーが汚れていれば作業ツリーだけを見る。commit 済みの差分を
    見たいなら --scope branch (デフォルトブランチを自動検出)。--base <ref> は両者を上書きする
  - --background だけでは待ちにならない。切り離すのは Bash の run_in_background。
    進捗は status --all、結果は result <job-id>、中断は cancel <job-id>
- 過剰実装の巡には /simplify も使える
  - 既定の観点が品質寄りなので、AGENTS.md の観点 (到達しない防御、窓を閉じない規則、
    落ちないテスト、1 呼び出しの抽象、仕様と重複したコメント) を明示して渡す
  - 修正まで適用するため、差分を確認してから採否を決める
- /code-review で巡を重ねる時は effort を上げる (low/medium → high/max)

## エージェントの分担
- 委譲は Agent ツールで行い、model を sonnet / haiku へ落とす
- Codex へ委譲する場合は codex:rescue サブエージェントを使う
- 探索だけで済むタスクは Explore を使う。読み取り専用で、ファイル本文ではなく結論が返る
