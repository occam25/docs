# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
	alias rgrep='rgrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi
#export PS1="\e[1;34m[\u@\h \W]\$ \e[0;34m "
#export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m[\]\u@\h \W]$ \[\033[0;34m\]'
#export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;34m[\]\u@\h \W]$ \[\033[0;34m\]'
export PS1='${debian_chroot:+($debian_chroot)}\[\e[34;1m\][\u@\H \W]\$\[\e[37;1m\] '
export PATH=$PATH:/usr/local/opt/crosstool/arm-linux/gcc-3.3.4-glibc-2.3.2/bin:/opt/modeltech/bin:/opt/modeltech/linux:/opt/Xilinx/13.3/ISE_DS/ISE/bin/lin:/opt/Xilinx/13.3/ISE_DS/common/bin/lin
export LM_LICENSE_FILE=/home/javi/flexlm/license.dat


# function to set terminal title
function set-title(){
	if [[ -z "$ORIG" ]]; then
		ORIG="$PS1"
			fi
			TITLE="\[\e]2;$*\a\]"
			PS1="${ORIG}${TITLE}"
}

# Alias to source the genericpc environment (Used to build the tests)
function teste(){
	. ~/develop/yocto/meta-fifthplay/env_yocto.sh -g
	set-title Teste
}
#alias teste=". ~/develop/yocto/meta-fifthplay/env_yocto.sh -g"
# Alias to source the emperor environment (Used to build stuff for the gateway architecture)
function empe(){
	. ~/develop/yocto/meta-fifthplay/env_yocto.sh
	set-title Emperor
}
#alias empe=". ~/develop/yocto/meta-fifthplay/env_yocto.sh"
#alias empe=". ~/develop/yocto/meta-fifthplay/env_yocto.sh"


export PATH="$PATH:$HOME/.rvm/bin"
# Add fifthplay scripts to path
export PATH="$PATH:/home/javi/develop/embedded/linuxtools/connected/bin"

export PROOT_NO_SECCOMP=1

function short_path(){
	pwd | awk -F/ '{print $NF}'
}

function git_branch () {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function git_prompt(){
	PS1='\[\033[00m\]:\[\033[01;34m\][$(short_path)]\[\033[0;32m\]($(git_branch))\[\033[00m\]\$ '
}

function reset_prompt(){
	PS1='${debian_chroot:+($debian_chroot)}\[\e[34;1m\][\u@\H \W]\$\[\e[37;1m\] '
}
# Para ejecutar los comandos pasados a la variable BASH_PORT_RC cuando se abre una nueva terminal desde la linea de comandos con: gnome-terminal -x sh -c BASH_POST_RC=\''command1; command2'\''; exec bash'
eval "$BASH_POST_RC"

# enable colors
eval "`dircolors -b`"

# force ls to always use color and type indicators
alias ls='ls -hF --color=auto'

# make the dir command work kinda like in windows (long format)
alias dir='ls --color=auto --format=long'

# make grep highlight results using color
export GREP_OPTIONS='--color=auto'

# Add some colour to LESS/MAN pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;33m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;42;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
