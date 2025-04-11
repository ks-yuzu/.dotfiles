# peco の存在チェック
# if [ ! ${+commands[peco]} ]; then
#     return
# fi


# ヒストリからコマンドを選択して実行する
# - preview: コマンドの内容
function select-history-fzf {
  BUFFER=$(
    history -nr 1 \
      | fzf --query "$LBUFFER" \
            --preview 'echo -e {} | perl -pe "s/\\\\n/\n/g"' \
            --preview-window=wrap \
            --no-sort \
      | perl -pe 's/\\n/\n/g' \
  )
  CURSOR="$#BUFFER"
  zle reset-prompt
}
zle -N select-history-fzf && bindkey '^r' $_


# zshrc の分割ファイルを選択して反映/編集する
# - preview: ファイルの内容
# - bind:
#   - enter: 反映
#   - ctrl-r: 反映
#   - ctrl-e: 編集
function reload-zshrc-fzf {
  if ps aux | grep emacs >/dev/null; then
    local editor='emacsclient -n'
  else
    local editor='vim'
  fi

  local command=$(
    find ~/.dotfiles/zsh/src -mindepth 1 | sort \
      | fzf --query "$LBUFFER" \
            --preview 'bat --color=always {}' \
            --bind 'enter:become(echo source {})' \
            --bind 'ctrl-r:become(echo source {})' \
            --bind "ctrl-e:become(echo $editor {})" \
            --bind '?:preview:echo "usage:\n- enter: reload\n- ctrl-r: reload- ctrl-e: edit\n"' \
  )
  BUFFER=" $command"
  zle accept-line
  zle reset-prompt
}
zle -N reload-zshrc-fzf && bindkey '^x^z' $_ && bindkey '^xz' $_


# ファイルを選択して、パスをラインバッファに挿入 or コピーする
# - query: カーソル位置の単語
# - preview: ファイル/ディレクトリの内容
# - bind:
#   # helm.el ライクなキーバインド
#   - tab:       サブディレクトリに移動
#   - ctrl-j:    サブディレクトリに移動
#   - ctrl-l:    親ディレクトリに移動
#   - enter:     選択 - バッファにファイルパスを挿入 (相対パス)
#   - alt-enter: 選択 - バッファにファイルパスを挿入 (絶対パス)
#   - ctrl-y:    選択 - ファイルパスをコピー (相対パス)
#   - alt-y:     選択 - ファイルパスをコピー (絶対パス)
function find-file-fzf {
  local usage=(
    'usage:'
    '- tab        go to subdirectory'
    '- ctrl-j     go to subdirectory'
    '- ctrl-l     go to parent directory'
    '- enter      insert relative path'
    '- alt-enter  insert absolute path'
    '- ctrl-y     copy relative path'
    '- alt-y      copy absolute path'
    '- ?          help'
  )
  usage=$(IFS=$'\n'; echo "${usage[*]}")

  # カーソルの直前の文字が空白でなければ単語を入力中と判定
  local prev_char="${BUFFER[$CURSOR]}"
  local next_char="${BUFFER[$CURSOR+1]}"
  local is_typing_word=$([[
    ( -z "$prev_char" || "$prev_char" == [[:space:]] ) &&
    ( -z "$next_char" || "$next_char" == [[:space:]] )
  ]] && echo 1)

  if [ -n "$is_typing_word" ]; then
    local query=''
  else
    local word_left="${BUFFER[1,CURSOR]##*[[:space:]]}"
    local word_right="${BUFFER[CURSOR+1,-1]%%[[:space:]]*}"
    local query="${word_left}${word_right}"
  fi

  # local find_opts="-maxdepth 1 -mindepth 1 -printf '%M %3n %u %g %5s %TY-%Tm-%Td %TR %p\n'"
  local find_opts="-maxdepth 1 -mindepth 1 "
  local selected=$(
    eval "find . ${find_opts}" | sort -k8,8 | xargs ls --color -ld --almost-all --si --time-style=long-iso \
      | fzf --ansi \
            --prompt="$(pwd)> " \
            --query "$query" \
            --select-1 \
            --nth 8 \
            --accept-nth 8 \
            --preview 'realpath {8}; echo; [[ -d {8} ]] && ls --color -l --almost-all --si --time-style=long-iso {8} || bat --color=always {8}' \
            --bind "tab:reload(test -d {8} \
                      && find \$(realpath -s --relative-to=. {8})                ${find_opts} | sort -k8,8 | xargs ls --color -ld --almost-all --si --time-style=long-iso \
                      || find \$(realpath -s --relative-to=. \$(dirname {8}))    ${find_opts} | sort -k8,8 | xargs ls --color -ld --almost-all --si --time-style=long-iso \
                    )+clear-query+top" \
            --bind "ctrl-j:reload(test -d {8} \
                      && find \$(realpath -s --relative-to=. {8})                ${find_opts} | sort -k8,8 | xargs ls --color -ld --almost-all --si --time-style=long-iso \
                      || find \$(realpath -s --relative-to=. \$(dirname {8}))    ${find_opts} | sort -k8,8 | xargs ls --color -ld --almost-all --si --time-style=long-iso \
                    )+clear-query+top" \
            --bind "ctrl-l:reload( \
                      find \$(realpath -s --relative-to=. \$(dirname {8})/..) ${find_opts} | sort -k8,8 | xargs ls --color -ld --almost-all --si --time-style=long-iso \
                    )+clear-query+top" \
            --bind "enter:accept" \
            --bind "alt-enter:become(realpath {8})" \
            --bind "ctrl-y:execute(echo {8} | pbcopy)+abort" \
            --bind "alt-y:execute(realpath {8} | pbcopy)+abort" \
            --bind "?:preview:echo '${usage}'"
  )
  [[ -z "$selected" ]] && return

  if [ -n "$is_typing_word" ]; then
    LBUFFER+="$selected"
  else
    local start=$(( CURSOR - ${#word_left} ))
    local end=$(( CURSOR + ${#word_right} ))
    BUFFER="${BUFFER[1,start]}${selected}${BUFFER[end+1,-1]}"
    CURSOR=$(( start + ${#selected} ))
  fi
}
zle -N find-file-fzf && bindkey '^x^f' $_


function zsh-snippets-fzf() {
  local snippets="$HOME/.dotfiles/zsh/snippets.txt"
  if [ ! -e "$snippets" ]; then
    echo "$snippets is not found." >&2
    return 1
  fi

  local line="$(grep -v -e "^\s*#" -e "^\s*$" "$snippets"  | fzf --query "$LBUFFER")"
  if [ -z "$line" ]; then
    return 1
  fi

  local command="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
  if [ -z "$command" ]; then
    return 1
  fi

  BUFFER="$command"
  CURSOR=$#BUFFER
}
zle -N zsh-snippets-fzf && bindkey '^x^x' $_


# プロセスを選択して kill する
# - preview: プロセスの詳細
# - bind:
#   - tab:    プロセスの環境変数を表示
#   - ctrl-r: プロセスリストを再読み込み
function kill-fzf() {
  local command="ps aux --sort=-pid"
  local pid=($(
    eval "$command" \
      | fzf --multi \
            --nth 2,11.. \
            --accept-nth 2 \
            --header-lines=1 \
            --preview 'ps -p {2} -o pid,ppid,etime,%cpu,%mem,cmd; echo; pstree -p {2}' \
            --bind "ctrl-r:reload($command)" \
            --bind "tab:preview:cat /proc/{2}/environ | tr '\0' '\n'" \
  ))

  if [ -n "$pid" ]; then
    echo 'kill processes (SIGTERM):'
    ps u "${pid[@]}"
    kill "${pid[@]}"
  fi

  zle reset-prompt
}
alias pka="kill-fzf"
zle -N kill-fzf && bindkey '^xp' $_


# プロセスを選択して kill -9 する
# - preview: プロセスの詳細
# - bind:
#   - tab:    プロセスの環境変数を表示
#   - ctrl-r: プロセスリストを再読み込み
function kill-force-fzf() {
  local command="ps aux --sort=-pid"
  local pid=($(
    eval "$command" \
      | fzf --multi \
            --nth 2,11.. \
            --accept-nth 2 \
            --header-lines=1 \
            --preview 'ps -p {2} -o pid,ppid,etime,%cpu,%mem,cmd; echo; pstree -p {2}' \
            --bind "ctrl-r:reload($command)" \
            --bind "tab:preview:cat /proc/{2}/environ | tr '\0' '\n'" \
  ))

  if [ -n "$pid" ]; then
    echo 'kill processes (SIGKILL):'
    ps u "${pid[@]}"
    kill -9 "${pid[@]}"
  fi

  zle reset-prompt
}
alias pka9=kill-force-fzf
zle -N kill-force-fzf && bindkey '^xP' $_


# 再帰的にディレクトリを選択して cd する
# - preview: ディレクトリの中身を表示
# - bind:
#   - tab: サブディレクトリの中身を表示
#   - ctrl-l: 親ディレクトリに移動
function cd-recursively-fzf() {
  while true; do
    local selected_dir=$(
      =ls -ald --si --time-style=long-iso */ \
        | fzf --prompt="$(pwd)> " \
              --nth 8 \
              --accept-nth 8 \
              --preview="ls --color -l --almost-all --si --time-style=long-iso {8}" \
              --bind "tab:preview:ls --color -l --almost-all --si --time-style=long-iso {8}*/" \
              --bind "ctrl-l:become(echo ..)"
    )

    if [ -z "$selected_dir" ]; then
      break
    else
      builtin cd "$selected_dir"
    fi
  done

  zle reset-prompt
}
zle -N cd-recursively-fzf && bindkey '^xf' $_


function rm-fzf() {
    rm $(ls --almost-all | fzf)
}


function ssh-fzf () {
  local selected_host=$(
    grep -h Host ~/.ssh/config.d/*-hosts-*.conf \
      | fzf --query "$LBUFFER" \
            --nth 2 \
            --accept-nth 2 \
            --preview 'ssh-add -l; echo; \
                       ssh -ttG {2} | grep -E "^(user|host|port|identityfile|forward|control|proxycommand|remotecommand|sendenv)"' \
  )

  if [ -n "$selected_host" ]; then
    BUFFER=" ssh ${selected_host}"
    CURSOR=$#BUFFER
    # zle accept-line
  fi
}
zle -N ssh-fzf && bindkey '^\' $_


# Makefile の recipe を選択して実行する
# - preview: Makefile の該当 recipe
# - bind:
#   - tab: 選択した recipe を make -n する
function make-fzf() {
  local recipe=$(rg --line-number --no-heading '^\S+:' Makefile \
    | grep -vF .PHONY \
    | fzf --prompt="recipe> " \
          --delimiter : \
          --with-nth 2 \
          --preview 'bat --color=always --highlight-line {1} Makefile' \
          --preview-window='+{1}+3/2,~3,80%' \
          --accept-nth=2 \
          --bind 'tab:preview:make -n {2}'
  )

  if [ -n "$recipe" ]; then
    BUFFER="make $recipe"
    # zle accept-line
  fi
  zle reset-prompt
}
zle -N make-fzf && bindkey '^[m' $_

# ghq 管理のリポジトリを選択して cd する
# - preview: リポジトリのブランチとファイル一覧
# - bind:
#   - ctrl-r: リストを再読み込み
function ghq-fzf() {
  local ghq_root=$(ghq root)
  local with_icon=$(which ghq-dirty-repo.zsh > /dev/null 2>&1 && echo 1)
  local GHQ_LIST=$([ -n "$with_icon" ] && echo 'ghq-dirty-repo.zsh -l' || echo 'ghq list -p')
  local GHQ_LIST_NO_CACHE=$([ -n "$with_icon" ] && echo 'ghq-dirty-repo.zsh -l -f' || echo 'ghq list -p')

  local preview_commands=(
    'dir={};'
    'echo -n "\e[38;5;202m\e[m "; cut -d/ -f2- <<<"${dir#*'"$ghq_root"'/}";'
    'builtin cd ${dir#* };'
    'echo -n "\e[38;5;202m\e[m "; git branch --show-current;'
    'echo; git -c color.status=always status -sb | head -n10;'
    'echo; ls --color -l --almost-all --si --time-style=long-iso'
  )

  local selected_dir=$(
    eval "$GHQ_LIST" \
      | fzf --ansi \
            --prompt='repo> ' \
            --query "$LBUFFER" \
            --preview-label='' \
            --preview "${preview_commands[*]}" \
            --bind "ctrl-r:reload:$GHQ_LIST_NO_CACHE" \
            --select-1
  )

  if [ -n "$selected_dir" ]; then
    [ -n "$with_icon" ] && selected_dir=${selected_dir#* }
    BUFFER=" cd ${selected_dir}"
    zle accept-line
  fi
}
zle -N ghq-fzf && bindkey '^[g' $_

# リポジトリを選択して ghq get する
function ghq-clone-fzf() {
  local org=$(gh repo list | gh org list | fzf)
  local repo=$(NO_COLOR=true unbuffer gh repo list gree-main --limit 10 | tail -n +5 | fzf --accept-nth 1)

  ghq get $repo
  cd $(ghq list -p $repo | fzf --select-1)
}

# インクリメンタルに ripgrep する
# - preview: 対象ファイルの該当行
function rg-fzf() {
  local INITIAL_QUERY="${1:-}"
  local RG_PREFIX="rg --line-number --no-heading --color=always --smart-case "

  FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --phony --query "$INITIAL_QUERY" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window='+{2}+3/2,~3' \
}
alias rgi=rg-fzf

