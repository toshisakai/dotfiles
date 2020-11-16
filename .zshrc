#               ■              
#               ■              
#               ■     ■        
#   ■■■■  ■■■   ■■■   ■■    ■■■
#     ■■  ■     ■  ■  ■■■  ■   
#    ■■    ■■   ■  ■  ■    ■   
#   ■■      ■■  ■  ■  ■    ■   
#   ■■■■  ■■■   ■  ■  ■    ■■■■

# 環境設定
# ------- ------- ------- ------- ------- ------- -------
export LANG=ja_JP.UTF-8
export KCODE=u
export LSCOLORS=Exfxcxdxbxegedabagacad
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
export ZLS_COLORS=$LS_COLORS
export CLICOLOR=true

autoload -U colors; colors
autoload -U compinit; compinit

setopt no_beep
setopt auto_cd
setopt auto_pushd
setopt magic_equal_subst
setopt prompt_subst
setopt notify
setopt equals
setopt auto_list
setopt auto_menu
setopt list_packed
setopt list_types
setopt extended_glob
setopt prompt_subst

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} r:|[-_.]=**'

# コマンドプロンプト
# ------- ------- ------- ------- ------- ------- -------
PROMPT='${fg[magenta]}%n ${fg[white]}at ${fg[yellow]}%m ${fg[white]}in ${fg[green]}%~%{$reset_color%}
%# '

# コマンド履歴
# ------- ------- ------- ------- ------- ------- -------
if [ -w ~/.zsh_history -o -w ~ ]; then
    SAVEHIST=100000
    HISTSIZE=100000
    HISTFILE=~/.zsh_history
    setopt extended_history
    setopt hist_ignore_dups
    setopt share_history
    setopt hist_reduce_blanks
fi

# zplug https://github.com/zplug/zplug
# Zsh Plugin Manager
# ------- ------- ------- ------- ------- ------- -------
if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/zplug/zplug ~/.zplug
fi
source ~/.zplug/init.zsh
zplug "zsh-users/zsh-completions"
zplug "plugins/git",   from:oh-my-zsh
zplug "peterhurford/git-aliases.zsh"
zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi
zplug load –verbose

# peco https://github.com/peco/peco
# Simplistic interactive filtering tool.
#
# install : brew install peco
# ------- ------- ------- ------- ------- ------- -------
## コマンド履歴候補
function peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        sort -k1,1nr | \
        perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey "^R" peco-select-history

## SSH候補
function peco-ssh () {
    ssh $(awk '
        tolower($1)=="host" {
                for (i=2; i<=NF; i++) {
                    if ($i !~ "[*?]") {
                        print $i
                    }
            }
        }
    ' ~/.ssh/config | sort | peco)
    zle clear-screen
}
zle -N peco-ssh
bindkey "^@" peco-ssh

## ghq + peco gitリポジトリ候補
function peco-src () {
    local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-src
bindkey "^]" peco-src

# zsh prompt that displays information about the current git repository
# ------- ------- ------- ------- ------- ------- -------
if type "git" > /dev/null 2>&1; then
    function branch_prompt() {
      local name=`git branch 2> /dev/null | grep '^\*' | cut -b 3-`
      if [[ -z $name ]]; then
        echo "%#"
      else
        echo "%F{green}$name%f"
      fi
    }

    function branch-status-check {
        local prefix branchname suffix
            if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
                return
            fi
            branchname=`get-branch-name`
            if [[ -z $branchname ]]; then
                return
            fi
            echo '%{'${fg[white]}${bg[cyan]}'%} '${branchname}' %{'${reset_color}'%}'
    }

    function get-branch-name {
        echo `git rev-parse --abbrev-ref HEAD 2> /dev/null`
    }

    # コマンドプロンプト書き換え
    PROMPT='${fg[magenta]}%n ${fg[white]}at ${fg[yellow]}%m ${fg[white]}in ${fg[green]}%~ `branch-status-check`%{$reset_color%}
%# '
fi

# ls color
# ------- ------- ------- ------- ------- ------- -------
chpwd() {
    ls_abbrev
}
ls_abbrev() {
    # -a : Do not ignore entries starting with ..
    # -C : Force multi-column output.
    # -F : Append indicator (one of */=>@|) to entries.
    local cmd_ls='ls'
    local -a opt_ls
    opt_ls=('-aCF' '--color=always')
    case "${OSTYPE}" in
        freebsd*|darwin*)
            if type gls > /dev/null 2>&1; then
                cmd_ls='gls'
            else
                # -G : Enable colorized output.
                opt_ls=('-aCFG')
            fi
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 10 ]; then
        echo "$ls_result" | head -n 5
        echo '...'
        echo "$ls_result" | tail -n 5
        echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}


# エイリアス
# ------- ------- ------- ------- ------- ------- -------
alias rmf="rm -rf"
alias ls="ls -laFG"

if type "vim" > /dev/null 2>&1; then
    alias vz="vim ~/.zshrc"
else
    alias vz="vi ~/.zshrc"
fi

if [ -w ~/.zshrc -o -w ~ ]; then
  alias sz="source ~/.zshrc"
fi

if type "ag" > /dev/null 2>&1; then
  alias grep="ag"
fi

if type "git" > /dev/null 2>&1; then
    gcom () {
        git add . && git status
        echo "Type commit comment" && read comment;
        git commit -m ${comment}
    }
fi

# Python
# ------- ------- ------- ------- ------- ------- -------

if [ -w ~/.pythonrc.py -o -w ~ ]; then
    export PYTHONSTARTUP=~/.pythonrc.py
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if [ -d ~/.pyenv ] && type "pyenv" > /dev/null 2>&1; then
    eval "$(pyenv init -)"
    if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
fi

# brew
# ------- ------- ------- ------- ------- ------- -------
export PATH=$HOME/.homebrew/bin:$PATH
if type "brew" > /dev/null 2>&1; then
  export HOMEBREW_CACHE=$HOME/.homebrew/caches
fi

# brewでインストールしたっぽいやつ...謎
# ------- ------- ------- ------- ------- ------- -------
export PATH="/usr/local/opt/openjdk/bin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH="/usr/local/opt/sqlite/bin:$PATH"
export PATH="/usr/local/opt/python@3.8/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"