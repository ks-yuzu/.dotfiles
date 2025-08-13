#!/usr/bin/env zsh
set -euo pipefail

# options
# -a: show all (default)
# -c: show count dirty repos only
# -l: show list dirty repos only
# -f: update cache
# -h: show help


function usage() {
  echo 'Usage: $0 [-a] [-c] [-l] [-f] [-h]'
  cat <<EOF
    -a  show all (default)
    -c  show count dirty repos only
    -l  show list dirty repos only
    -p  show full paths
    -f  update cache
    -h  show help
EOF
  exit 1
}

function parse_options() {
  while getopts aclfh OPT; do
    case $OPT in
      # a) OPT_COUNT=1; OPT_LIST=1 ;;
      c) OPT_COUNT=1 ;;
      l) OPT_LIST=1 ;;
      p) OPT_FULLPATH=1 ;;
      f) OPT_FORCE=1 ;;
      h) usage ;;
    esac
  done

  if [ -z "${OPT_COUNT:-}" ] && [ -z "${OPT_LIST:-}" ]; then
    OPT_COUNT=1
    OPT_LIST=1
  fi
}


function run() {
  local count=0
  for repo in $(ghq list ${OPT_FULLPATH:+-p}); do
    repo_prefix=${${OPT_FULLPATH:+ }:-$(ghq root)/}
    if git -C ${repo_prefix}$repo status --porcelain | grep . > /dev/null; then
      count=$((count + 1))
      [ -n "${OPT_LIST:-}" ] && echo "\e[38;5;160m■\e[m ${repo}"
    else
      [ -n "${OPT_LIST:-}" ] && echo "\e[38;5;46m■\e[m ${repo}"
    fi
  done

  if [ -n "${OPT_COUNT:-}" ]; then
    if [ -n "${OPT_LIST:-}" ]; then
      echo "\ndirty repos: $count\n"
    else
      echo $count
    fi
  fi
}

parse_options $@

cache_file=/tmp/ghq-dirty-repos.${OPT_ALL+a}${OPT_COUNT+c}${OPT_LIST+l}.cache
cache_exists=$(find $cache_file -mmin -30 2> /dev/null || true)

if [ -z "${cache_exists}" ] || [ -n "${OPT_FORCE:-}" ] ||  ; then
  run > $cache_file
  cat $cache_file
else
  cat $cache_file
fi

