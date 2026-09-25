# .agents

コーディングエージェントへの指示ファイル。このディレクトリのファイルが正であり、
各ツールのホームディレクトリからは symlink で参照する。

## 構成

| ファイル | 役割 | 参照元 |
| --- | --- | --- |
| `AGENTS.md` | ツール非依存の共通ルール | 各ツール別ファイルから参照 |
| `claude/CLAUDE.md` | Claude Code 差分 | `~/.claude/CLAUDE.md` |
| `codex/AGENTS.md` | Codex 差分 | `~/.codex/AGENTS.md` |

## symlink

symlink を貼る。再実行しても既存の link を作り直さない。

```sh
mkdir -p ~/.agents ~/.claude ~/.codex
test -L ~/.agents/AGENTS.md || ln -s ~/.dotfiles/.agents/AGENTS.md        ~/.agents/AGENTS.md
test -L ~/.claude/CLAUDE.md || ln -s ~/.dotfiles/.agents/claude/CLAUDE.md ~/.claude/CLAUDE.md
test -L ~/.codex/AGENTS.md  || ln -s ~/.dotfiles/.agents/codex/AGENTS.md  ~/.codex/AGENTS.md
```

symlink はディレクトリではなくファイル単位で貼る。

- `~/.agents` は skill の置き場として別に使う。ディレクトリごと貼ると skill が見えなくなる
- `~/.claude` と `~/.codex` は認証情報 (`.credentials.json`, `auth.json`)、会話履歴、
  セッション状態を含む。public リポジトリへ入れられない

## 共通ルールの取り込み方がツールごとに異なる理由

- Claude Code は CLAUDE.md 内の `@path` を import として解決し、内容を展開する
- Codex には import 相当の構文が無い (0.146.0 時点)。パスを書いてエージェント自身に
  読ませる形になるため、指示文を強める必要がある
  - 「作業を開始する前に必ず読む」程度では、作業を伴わない会話的なプロンプトで読まれず、
    文体などのルールが適用されない
  - 「いかなる応答よりも先に必ず読む。会話のみの応答であっても読まずに回答してはならない」
    と書けば、会話的なプロンプトでも 1 手目に読み取りが実行される
  - 再測する場合は、検出できる規則 (回答末尾に固定文字列を書かせる等) を置いた共通ルールを
    隔離した CODEX_HOME に用意し、`CODEX_HOME=<dir> codex exec -s read-only "<会話的な質問>"`
    で読み取りの有無と規則の適用を見る
