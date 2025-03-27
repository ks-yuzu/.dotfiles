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
            --preview 'echo {}' \
            --no-sort \
      | perl -pe 's/\\n/\n/g'
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
    find ~/.dotfiles/zsh/src/ -mindepth 1 \
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


# 選択したファイルパスをラインバッファのカーソル位置に挿入する
# - preview: ファイル/ディレクトリの内容
# - bind:
#   # helm.el ライクなキーバインド
#   - tab:    サブディレクトリに移動
#   - ctrl-j: サブディレクトリに移動
#   - ctrl-l: 親ディレクトリに移動
function insert-filepath-to-linebuf-fzf {
  local find_opts="-maxdepth 1 -mindepth 1 -printf '%M %3n %u %g %5s %TY-%Tm-%Td %TR %p\n'"
  local selected=$(
    eval "find . ${find_opts}" | sort -k8,8 \
      | fzf --prompt="$(pwd)> " \
            --nth 8 \
            --accept-nth 8 \
            --preview 'realpath {8}; echo; [[ -d {8} ]] && ls -l --almost-all --si --time-style=long-iso {8} || bat --color=always {8}' \
            --bind "tab:reload(test -d {8} \
                      && find \$(realpath -s --relative-to=. {8})                ${find_opts} | sort -k8,8 \
                      || find \$(realpath -s --relative-to=. \$(dirname {8}))    ${find_opts} | sort -k8,8 \
                    )+clear-query+top" \
            --bind "ctrl-j:reload(test -d {8} \
                      && find \$(realpath -s --relative-to=. {8})                ${find_opts} | sort -k8,8 \
                      || find \$(realpath -s --relative-to=. \$(dirname {8}))    ${find_opts} | sort -k8,8 \
                    )+clear-query+top" \
            --bind "ctrl-l:reload(find \$(realpath -s --relative-to=. \$(dirname {8})/..) ${find_opts} | sort -k8,8)+clear-query+top" \
  )
  [[ -z "$selected" ]] && return

  LBUFFER+="$selected"
  zle reset-prompt
}
zle -N insert-filepath-to-linebuf-fzf && bindkey '^x^f' $_



# peco snippet
function peco-snippets()
{
    local snippets="$HOME/.dotfiles/zsh/snippets.txt"

    if [ ! -e "$snippets" ]; then
        echo "$snippets is not found." >&2
        return 1
    fi

    local line="$(grep -v -e "^\s*#" -e "^\s*$" "$snippets"  | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi

    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    CURSOR="$#BUFFER"
}
zle -N peco-snippets && bindkey '^x^x' $_


# peco cheatsheet
function peco-sni-cs()
{
    local cspath="$HOME/works/cheatsheet/.snip-peco-cheatsheet"

    if [ ! -e "$cspath" ]; then
        echo "$cspath is not found." >&2
        return 1
    fi

    local line="$(grep -v "^#" $cspath | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi

    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    zle clear-screen
}

zle -N peco-sni-cs
bindkey '^xc' peco-sni-cs



# peco-process-kill
function peco-pkill()
{
    for pid in `ps u | peco | awk '{ print $2 }'`
    do
        kill $pid
        echo "killed ${pid}"
    done
}
alias pk="peco-pkill"


# peco-process-kill-all
function peco-pkill-all()
{
    for pid in `ps aux | peco | awk '{ print $2 }'`
    do
        kill $pid
        echo "killed ${pid}"
    done
}
alias pka="peco-pkill-all"


# peco-process-kill-all
function peco-pkill-all-force()
{
    for pid in `ps aux | peco | awk '{ print $2 }'`
    do
        sudo kill -9 $pid
        echo "killed ${pid}"
    done
}
alias pka9="peco-pkill-all-force"



# peco-get-fullpath
function peco-get-fullpath()
{
    local fullpath
    if [ ! -z "$1" ]; then
        if [ -f $1 ]; then
            fullpath=`pwd`/$1
        else
            fullpath=$(find `pwd`/$1 -maxdepth 1 -mindepth 1 | peco --query "$LBUFFER")
        fi
    else
        fullpath=$(find `pwd` -maxdepth 1 -mindepth 1 | peco --query "$LBUFFER")
    fi
    echo "${fullpath}" | pbcopy
    echo ${fullpath}
}
alias fullpath="peco-get-fullpath"



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
              --preview="ls -l --almost-all --si --time-style=long-iso {8}" \
              --bind "tab:preview:ls -l --almost-all --si --time-style=long-iso {8}*/" \
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
  )

  if [ -n "$selected_host" ]; then
    BUFFER=" ssh ${selected_host}"
    CURSOR=$#BUFFER
    # zle accept-line
  fi
}
zle -N ssh-fzf && bindkey '^\' $_


function peco-file() {
    ls -l --almost-all --si --time-style=long-iso $1 \
        | grep -P -v 'total [^ ]*' \
        | peco \
        | perl -alE 'say $F[7]'
}


# peco todo
function peco-open-todo()
{
    local snippets="$HOME/.dotfiles/zsh/note-files.txt"

    if [ ! -e "$snippets" ]; then
        echo "$snippets is not found." >&2
        return 1
    fi

    local line="$(grep -v "^#" "$snippets" | peco --query "$LBUFFER")"
    if [ -z "$line" ]; then
        return 1
    fi

    local snippet="$(echo "$line" | sed "s/^\[[^]]*\] *//g")"
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER=$snippet
    zle clear-screen
}
zle -N peco-open-todo
bindkey '^xt' peco-open-todo


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
function  ghq-fzf() {
  local selected_dir=$(
    ghq list -p \
      | fzf --prompt='repo> ' \
            --query "$LBUFFER" \
            --preview 'builtin cd {}; echo -n "branch: "; git branch --show-current; echo; ls -l --almost-all --si --time-style=long-iso {}' \
            --select-1
  )

  if [ -n "$selected_dir" ]; then
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
  INITIAL_QUERY="${1:-}"

  RG_PREFIX="rg --line-number --no-heading --color=always --smart-case "
  FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
    fzf --bind "change:reload:$RG_PREFIX {q} || true" \
        --ansi --phony --query "$INITIAL_QUERY" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window='+{2}+3/2,~3'
}
alias rgi=rg-fzf

