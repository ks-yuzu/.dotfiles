function append-path-if-exists {
  DIRPATH=$1
  if [ -d "$DIRPATH" ]; then
    export PATH="$DIRPATH:$PATH"
  fi
}


## plenv
export PATH="$HOME/.plenv/bin:$PATH"

if [ -x "`which plenv 2> /dev/null`" ]; then
  eval "$(plenv init -)"
  export PLENV_VERSION=$(plenv version | awk '{print $1}')
  # export PERL_CPANM_OPT="--local-lib=${PERL_LOCAL_LIB}"
  # export PATH=${PLENV_ROOT}/bin:$PATH
  # export PERL5LIB=${PLENV_ROOT}/versions/${PLENV_VERSION}/lib/perl5:$PERL5LIB
fi


## node etc.
# nodebrew
append-path-if-exists "$HOME/.nodebrew/current/bin"

# nvm
NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
if [ -d "$NVM_DIR" ]; then
  export NVM_DIR
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
fi

# deno
DENO_INSTALL="/mnt/d/wsl-home/.deno"
if [ -d "$DENO_INSTALL" ]; then
  export DENO_INSTALL
  append-path-if-exists "$DENO_INSTALL/bin"
fi


## ruby
if [ -d "$HOME/.rbenv" ]; then
  append-path-if-exists "$HOME/.rbenv/bin"
  eval "$(rbenv init -)"
fi


## python
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  append-path-if-exists "$PYENV_ROOT/bin"
  eval "$(pyenv init --path)"
fi


## haskell
append-path-if-exists "$HOME/.cabal/bin"


## go
if [ -d "$HOME/.goenv" ]; then
  export GOENV_ROOT=$HOME/.goenv
  export PATH=$GOENV_ROOT/bin:$PATH
  eval "$(goenv init -)"
elif [ -d "$HOME/.go" ]; then
  export GOPATH=~/.go
  export PATH=$GOPATH/bin:$PATH
fi


# gcc
LIBRARY_PATH=/usr/lib/gcc/x86_64-linux-gnu/10
if [ -d "$LIBRARY_PATH" ]; then
  export LIBRARY_PATH
  export C_INCLUDE_PATH="${LIBRARY_PATH}/include"
fi


## others
# export PATH=$PATH:$HOME/.local/lib/python2.7/site-packages/powerline
# export PATH=$PATH:/opt/ibm/ILOG/CPLEX_Studio1261/cplex/bin/x86-64_linux
append-path-if-exists "$HOME/.local/bin/"
append-path-if-exists "$HOME/bin"
append-path-if-exists "$HOME/opt"
append-path-if-exists "$HOME/.cargo/bin"

