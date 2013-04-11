######################################################################
#         guillaumep's zshrc file, based on:
#           tonio's zshrc file v0.1 , based on:
#             jdong's zshrc file v0.2.1 , based on:
#               mako's zshrc file, v0.1
######################################################################

##############################
# Configuration options
##############################

source $HOME/.zsh/config

##############################
# enviromental/shell options
##############################

setopt ALL_EXPORT
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt AUTO_LIST
setopt AUTO_MENU

unsetopt CORRECT
unsetopt BG_NICE
unsetopt NOMATCH
unsetopt LIST_AMBIGUOUS

# setopt AUTO_REMOVE_SLASH
# setopt AUTO_RESUME
# setopt HASH_CMDS
# setopt MENU_COMPLETE
# setopt NOHUP
# setopt NOTIFY
# setopt NO_FLOW_CONTROL

##############################
# Set/unset shell options
##############################

setopt notify globdots pushdtohome cdablevars autolist
setopt autocd recexact longlistjobs
setopt autoresume histignoredups pushdsilent 
setopt autopushd pushdminus extendedglob rcquotes mailwarning

#if [[ $COMMAND_CORRECTION == yes ]] ; then
#  setopt correct
#fi

#if [[ $COMMAND_CORRECTION == yes ]] ; then
#  setopt correctall
#fi

unsetopt bgnice autoparamslash

# setopt   printexitvalue

##############################
# Autoload zsh modules
##############################

zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -a zsh/mapfile mapfile

##############################
# Set environment variables
##############################

PATH="$HOME/.local/bin:/usr/local/bin:/usr/local/sbin/:/bin:/sbin:/usr/bin:/usr/sbin:$PATH"
HISTFILE=$HOME/.zhistory
HISTSIZE=3000
SAVEHIST=3000
HOSTNAME="`hostname`"
PAGER='less'
EDITOR='vim'
WORDCHARS="${WORDCHARS:s#/#}"
OS="`uname`"

##############################
# Set color variables
##############################

autoload colors zsh/terminfo

if [[ "$terminfo[colors]" -ge 8 ]]; then
  colors
fi

for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
  eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
  eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
done

PR_NO_COLOR="%{$terminfo[sgr0]%}"

##############################                                                                                                                                                      
# Unset exports                                                                                                                                                                      
##############################                                                                                                                                                      
unsetopt ALL_EXPORT

##############################
# Set preexec ()
##############################

preexec () {
  command="${1%% *}"
}

##############################
# Set precmd ()
##############################

precmd () {
  local exitstatus=$?

  # Command not found stuff for debian/ubuntu
  if [ $exitstatus -ne 0 ] && [ -n "$command" ] && [ -x /usr/lib/command-not-found ] ; then
    whence -- "$command" >& /dev/null ||
      /usr/bin/python /usr/lib/command-not-found -- "$command"
    unset command
  fi

  # Display exit status for previous command
  if [[ $exitstatus -ge 128 && $exitstatus -le (127+${#signals}) && $COMMAND_STATUS == yes ]]
  then
    # Last process was killed by a signal.  Find out what it was from
    # the $signals environment variable.
    psvar[1]="Status:$signals[$exitstatus-127]"
  elif [[ $exitstatus -ne 0 && $shownexterr -gt 0 ]]
  then
    psvar[1]="Status:[$exitstatus]"
  else
    psvar[1]=""
  fi
  shownexterr=0

  # VCS Support
  psvar[2]=""
  rev=""

    if [[ $SVN_SUPPORT == "yes" ]] && [[ -x `which svn` ]] ; then
      if [ -d $PWD/.svn ] ; then
        psvar[2]="(svn:$(env LC_ALL=C svn info | grep "^Revision" | awk '{print $2}')) "
      fi
    fi

    if [[ $BZR_SUPPORT == "yes" ]] && [[ -x `which bzr` ]] && [ ! -n "$psvar[2]" ] ; then
      rev=$(env LC_ALL=C bzr revno 3>&2 2>/dev/null | grep "^[0-9]*")
      if [[ $? -eq 0 ]] ; then
        psvar[2]="(bzr:$rev) "
      fi
    fi

    if [[ $GIT_SUPPORT == "yes" ]] && [[ -x `which git` ]] && [ ! -n "$psvar[2]" ] ; then
      rev="$(env LC_ALL=C git branch 2>/dev/null | grep "^*" | awk '{print $2}')"
      if [ -n "$rev" ] ; then
        psvar[2]="(git:$rev) "
      fi
    fi

    if [[ $HG_SUPPORT == "yes" ]] && [[ -x `which hg` ]] && [ ! -n "$psvar[2]" ] ; then
      rev="$(python $HOME/.zsh/print_hg_info.py)"
      if [ -n "$rev" ] ; then
        psvar[2]="(hg:$rev) "
      fi
    fi

    if [[ $CVS_SUPPORT == "yes" ]] && [[ -x `which cvs` ]] && [ ! -n "$psvar[2]" ] ; then
      rtag="$(python $HOME/.zsh/print_lastest_cvs_tag.py)"
      if [ -d $PWD/CVS ] ; then
        psvar[2]="(cvs:rtag:$rtag) "
      fi
    fi

  # Windows title support
  case $TERM in
    *xterm*)
      print -Pn "\e]0;%n~%M: %~\a"
      ;;
  esac
}

##############################
# Set Prompt
##############################

PS1="%{%(#~$PR_RED$bg[red]~$PR_BLUE)%}%n$PR_WHITE~$PR_GREEN%m$PR_NO_COLOR $PR_LIGHT_YELLOW%2v$PR_YELLOW%20c $PR_RED%1v
$PR_NO_COLOR%(!.#.$) "
RPS1="$PR_LIGHT_YELLOW(%D{%m-%d %H:%M})$PR_NO_COLOR"

##############################
# Aliases
##############################

if [[ ! -x $HOME/.zsh/aliases ]] ; then
  touch $HOME/.zsh/aliases
fi

if [[ ! -x $HOME/.zsh/aliases.$USER ]] ; then
  touch $HOME/.zsh/aliases.$USER
fi

source $HOME/.zsh/aliases
source $HOME/.zsh/aliases.$USER

##############################
# Binding keys
##############################

case "$TERM" in
  cons25*|linux) # plain BSD/Linux console
    bindkey '\e[H'    beginning-of-line   # home 
    bindkey '\e[F'    end-of-line         # end  
    bindkey '\e[5~'   delete-char         # delete
    bindkey '[D'      emacs-backward-word # esc left
    bindkey '[C'      emacs-forward-word  # esc right
    ;;
  *rxvt*) # rxvt derivatives
    bindkey '\e[3~'  delete-char         # delete
    bindkey '\eOc'    forward-word        # ctrl right
    bindkey '\eOd'    backward-word       # ctrl left
    # workaround for screen + urxvt
    bindkey '\e[7~'   beginning-of-line   # home
    bindkey '\e[8~'   end-of-line         # end
    bindkey '^[[1~'   beginning-of-line   # home
    bindkey '^[[4~'   end-of-line         # end
    ;;
  *xterm*) # xterm derivatives
    bindkey '\e[H'    beginning-of-line   # home
    bindkey '\e[F'    end-of-line         # end
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\e[1;5C' forward-word        # ctrl right
    bindkey '\e[1;5D' backward-word       # ctrl left
    # workaround for screen + xterm
    bindkey '\e[1~'   beginning-of-line   # home
    bindkey '\e[4~'   end-of-line         # end
    ;;
  screen)
    bindkey '^[[1~'   beginning-of-line          # home
    bindkey '^[[4~'   end-of-line         # end
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\eOc'    forward-word        # ctrl right
    bindkey '\eOd'    backward-word       # ctrl left
    bindkey '^[[1;5C' forward-word        # ctrl right
    bindkey '^[[1;5D' backward-word       # ctrl left
    ;;
esac

##############################
# Completion Settings
##############################

autoload -U compinit
compinit

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle ':completion:*' ignore-parents parent pwd
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

##############################
# Completion Styles
##############################

function _force_rehash() {
  (( CURRENT == 1 )) && rehash
  return 1	# Because we didn't really complete anything
}

# list of completers to use
zstyle ':completion:*::::' completer _oldlist _expand _force_rehash _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# command for process lists, the local web server details and host completion
# on processes completion complete all user processes
# zstyle ':completion:*:processes' command 'ps -au$USER'

## add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

#zstyle ':completion:*:processes' command 'ps ax -o pid,s,nice,stime,args | sed "/ps/d"'
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' command 'ps axho command' 
#zstyle ':completion:*:urls' local 'www' '/var/www/htdocs' 'public_html'
#
#NEW completion:
# 1. All /etc/hosts hostnames are in autocomplete
# 2. If you have a comment in /etc/hosts like #%foobar.domain,
#    then foobar.domain will show up in autocomplete!
zstyle ':completion:*' hosts $(awk '/^[^#]/ {print $2 $3" "$4" "$5}' /etc/hosts | grep -v ip6- && grep "^#%" /etc/hosts | awk -F% '{print $2}') 
# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm apache bin daemon games gdm halt ident junkbust lp mail mailnull \
        named news nfsnobody nobody nscd ntp operator pcap postgres radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs avahi-autoipd\
        avahi backup messagebus beagleindex debian-tor dhcp dnsmasq fetchmail\
        firebird gnats haldaemon hplip irc klog list man cupsys postfix\
        proxy syslog www-data mldonkey sys snort
# SSH Completion
zstyle ':completion:*:scp:*' tag-order \
  files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order \
  files all-files users hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order \
  users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order \
  hosts-domain hosts-host users hosts-ipaddr
zstyle '*' single-ignored show

##############################
# SSH key Management by Asyd
##############################

ssh_key_manage() {
  if [[ -x `which keychain` ]] && [ -r ~/.ssh/id_?sa ]
  then
    # run keychain
    keychain --nogui ~/.ssh/id_?sa
    [[ -r ~/.ssh-agent-`hostname` ]] && . ~/.ssh-agent-`hostname`
    [[ -r ~/.keychain/`hostname`-sh ]] &&  source ~/.keychain/`hostname`-sh
  else
    if [[ -x `which ssh-agent` ]] && [ -r ~/.ssh/id_?sa ]
    then
      if [[ -r $HOME/.ssh/agent-pid ]]
      then
        if [[ -d /proc/$(< $HOME/.ssh/agent-pid) ]]
        then
          source $HOME/.ssh/agent
        else
          ssh-agent -s > $HOME/.ssh/agent
          source $HOME/.ssh/agent
          echo $SSH_AGENT_PID > $HOME/.ssh/agent-pid
          ssh-add $HOME/.ssh/id_?sa
        fi
      else
        ssh-agent -s > $HOME/.ssh/agent
        source $HOME/.ssh/agent
        echo $SSH_AGENT_PID > $HOME/.ssh/agent-pid
        ssh-add $HOME/.ssh/id_?sa
      fi
    fi
  fi
}

if [[ "$USER" != "root" ]] && [[ $SSH_KEYS_MANAGEMENT == yes ]]; then
  ssh_key_manage
fi

##############################
# Up/Down searching in history
##############################

function history-search-end {
  integer ocursor=$CURSOR

  if [[ $LASTWIDGET = history-beginning-search-*-end ]]; then
    CURSOR=$hbs_pos
  else
    hbs_pos=$CURSOR
  fi

  if zle .${WIDGET%-end}; then
    # success, go to end of line
    zle .end-of-line
  else
    # failure, restore position
    CURSOR=$ocursor
    return 1
  fi
}

# Alias the function
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# Binding keys
bindkey "${key[Up]}" history-beginning-search-backward-end
bindkey "${key[Down]}" history-beginning-search-forward-end

##############################
# Auto update
##############################

local update_file last_update current_time week
update_file=$HOME/.zsh/update

# This script checks for configuration files update

function check_update () {
  if [[ ! -d $HOME/.zsh/.bzr ]] || [[ ! -x `which bzr` ]] ; then
    return 0
  fi

  # Remote revisions and local revision
  local rrev lrev update

  if [[ -x `which bzr` ]] ; then
    echo "Looking for zsh configuration update, please wait..."
    rrev=$(bzr revno http://bazaar.launchpad.net/~tonio/+junk/zsh 3>&2 2>/dev/null)
    lrev=$(bzr revno $HOME/.zsh/)

    if [[ $rrev > $lrev ]]; then
      echo "A new zsh configuration version (version $rrev) is available."
      echo "Do you want to replace your local configuration (version $lrev) ? (y/N)"
      read update
      if [ $update = "y" ] ; then
        bzr up $HOME/.zsh
      fi
    fi
  fi
}

# Create the file used at reference it not exists
if [[ ! -r $update_file ]]; then
  touch $update_file
fi

last_update=$(stat +mtime $update_file)
current_time=$(date +"%s")

# Number of seconds in a week
week=$((3600 * 24 * 7))

#if [[ $(($current_time - $last_update)) -gt $week ]] && [[ $AUTO_UPDATE == yes ]] ; then
#  check_update
#  touch $update_file
#fi

# We source a config file for user made modifications
if [[ ! -x $HOME/.zsh/zshrc.$USER ]] ; then
  touch $HOME/.zsh/zshrc.$USER
fi

source $HOME/.zsh/zshrc.$USER

