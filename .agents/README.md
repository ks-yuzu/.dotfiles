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

旧構成から移行する場合は、先に `~/.agents` のディレクトリ symlink を外す。初回のみ必要。

```sh
test -L ~/.agents && rm ~/.agents
```

参照先を失った symlink を外す。旧構成のツール別 link は `~/.agents/` 配下を指しており、
上の手順でリンク切れになる。初回のみ必要。

```sh
for f in ~/.agents/AGENTS.md ~/.claude/CLAUDE.md ~/.codex/AGENTS.md; do
  test -L "$f" && ! test -e "$f" && rm "$f"
done
```

既存の実ファイルを退避する。初回のみ必要。

```sh
for f in ~/.agents/AGENTS.md ~/.claude/CLAUDE.md ~/.codex/AGENTS.md; do
  test -f "$f" && ! test -L "$f" || continue
  bak="$f.bak"; test -e "$bak" && bak="$f.$(date +%Y%m%d%H%M%S).bak"
  mv "$f" "$bak"
done
```

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

判定に `test -e` ではなく `test -L` を使う。`test -e` は退避前の実ファイルを既設と見なし、
symlink を貼らずに終わる。

`~/.agents` がディレクトリ symlink の場合は、配下のファイルを触る前に外す。`test -L` は
最終要素しか見ないため、symlink 経由で届いた `~/.agents/AGENTS.md` を実ファイルと判定し、
リポジトリの実体を `.bak` へ改名する。link を外してもリポジトリ側の実体は残る。

退避先が埋まっている場合はタイムスタンプ付きの名前にする。同名へ上書きすると前回の退避内容が
失われる。

リンク切れの symlink は外してから貼る。`test -L` は参照先の有無を見ないため、外さずに進めると
新しい link が作られず、ツールが指示ファイルを読めない状態で残る。

再測する場合は HOME を隔離したディレクトリへ向け、同じ初期条件 (skill 入りの `~/.agents`、
実ファイルの `~/.claude/CLAUDE.md`) を作って手順を 2 回実行する。

共通ルールを `~/.agents/AGENTS.md` からも参照できるようにしているのは、ツール別ファイルが
この位置を指しているためである。ツール別ファイルはリポジトリを直接指す。

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
