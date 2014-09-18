fpath=(~/.zsh $fpath)
autoload -U compinit
compinit -u

bindkey -e
export EDITOR=emacs
export LANG=ja_JP.UTF-8

# prompt# {{{
autoload colors
colors
#PROMPT=$'%{${fg[magenta]}%* ${reset_color}(%d)%}
#PROMPT=$'%{${fg_bold[white]}%d ${reset_color}(%*)%}
PROMPT='[%F{yellow}%~%f]`branch-status-check`
%n%%'
#PROMPT2='${fg[white]}%n%% ${reset_color}'
#PROMPT2='[%n]> '
# %{${fg[yellow]}%}%~%{${reset_color}%}
## RPROMPT
#RPROMPT=$'`branch-status-check`' # %~はpwd
setopt prompt_subst #表示毎にPROMPTで設定されている文字列を評価する

# {{{ methods for RPROMPT
# fg[color]表記と$reset_colorを使いたい
# @see https://wiki.archlinux.org/index.php/zsh
autoload -U colors; colors
function branch-status-check {
local prefix branchname suffix
# .gitの中だから除外
if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
return
fi
branchname=`get-branch-name`
# ブランチ名が無いので除外
if [[ -z $branchname ]]; then
return
fi
prefix=`get-branch-status` #色だけ返ってくる
suffix='%{'${reset_color}'%}'
echo "(${prefix}${branchname}${suffix})"
}
function get-branch-name {
# gitディレクトリじゃない場合のエラーは捨てます
echo `git rev-parse --abbrev-ref HEAD 2> /dev/null`
}
function get-branch-status {
local res color
output=`git status --short 2> /dev/null`
if [ -z "$output" ]; then
res=':' # status Clean
color='%{'${fg[cyan]}'%}'
elif [[ $output =~ "[\n]?\?\? " ]]; then
res='?:' # Untracked
color='%{'${fg[yellow]}'%}'
elif [[ $output =~ "[\n]? M " ]]; then
res='M:' # Modified
color='%{'${fg[red]}'%}'
else
res='A:' # Added to commit
color='%{'${fg[green]}'%}'
fi
# echo ${color}${res}'%{'${reset_color}'%}'
echo ${color} # 色だけ返す
}
# }}}
# }}}

# about history# {{{
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
# }}}

# title# {{{
case "${TERM}" in
kterm*|xterm)
    precmd() {
        echo -ne "\033]0;${USER}@${HOST}\007"
    }
    ;;
esac
# }}}
#
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
cdpath=(~/ant.git/sys/ ~/ant.git/user/)
#色の設定
#export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
  #export LSCOLORS=exfxcxdxbxegedabagacad

#alias
case "${OSTYPE}" in
freebsd*|darwin*)
  alias ls="ls -GF";
  export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30';;
linux*)
  alias ls="ls -F --color" ;
  zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32';;
esac

alias la='ls -a'
alias ll='ls -l'
alias lla='ls -al'
alias e-en='vim ~/.zshrc'
alias s-en='exec zsh'
alias ant='sh ~/src/mkant.sh'
alias dump='objdump -D /ant | less'
#alias fpath='find ~/src -name'
alias view='sh ~/vfpath.sh'
alias gtags='vim -c 'Gtags $1' '


#ssh
function print_known_hosts()
{
	if [ -f $HOME/.ssh/known_hosts ]; then
		cat $HOME/.ssh/known_hosts | tr ',' ' ' | cut -d ' ' -f1
	fi
}
_cache_hosts=($( print_known_hosts ))

setopt nobeep

#改行のない出力をプロンプトで上書きするのを防ぐ
unsetopt promptcr

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

#個別設定を読み込む
[ -f ~/.zshrc.mine ] && source ~/.zshrc.mine
