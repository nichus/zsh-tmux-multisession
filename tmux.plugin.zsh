#
# Aliases
#

alias ta='tmux attach -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'

# Only run if tmux is actually installed
if which tmux &> /dev/null; then
  # Wrapper function for tmux.
  function _zsh_tmux_plugin_run()
  {
    local long_sessionname=`date "+%Y%m%d%H%M%S%N$$" | sha512sum`
    local tmux_sessionname=${long_sessionname[0,6]}
    local tmux_sessions=$(\tmux ls >/dev/null 2>&1 && echo true || echo false)
    # Some people seem to like tmux/iterm2 integration, maybe one day that will be me?
    local tmux_iterm2=$( [ -n "$ITERM_PROFILE" ] && echo '-CC' )
    # But not today...
    tmux_iterm2=''
    # Check for a detached ztm session
    local tmux_ztm_exists=$(\tmux ls 2>/dev/null | grep -q ztm && echo "true" || echo "false")
    local tmux_ztm_attached=$(\tmux ls 2>/dev/null | grep attached | grep -q ztm && echo "true" || echo "false")

    # If we have other arguments, just run them
    if [[ -n "$@" ]]; then
      \tmux $@
    # Try to reconnect to our detached primary session first
    elif [[ ${tmux_ztm_attached} == "false" ]]; then
      \tmux $tmux_iterm2 attach -t ztm && exit
    # If the primary session is already attached, create a new child session
    elif [[ ${tmux_ztm_exists} == "true" ]]; then
      \tmux $tmux_iterm2 new-session -s $tmux_sessionname -t ztm && exit
    # Create a new ztm session
    else
      \tmux $tmux_iterm2 new-session -s ztm && exit
    fi
  }

  # Use the completions for tmux for our function
  compdef _tmux _zsh_tmux_plugin_run

  # Alias tmux to our wrapper function.
  alias tmux=_zsh_tmux_plugin_run

  # Autostart if not already in tmux and enabled.
  if [[ ! -n "$TMUX" ]]; then
    # Actually don't autostart if we already did and multiple autostarts are disabled.
    if [[ "$ZSH_TMUX_AUTOSTARTED" != "true" ]]
    then
      export ZSH_TMUX_AUTOSTARTED=true
      _zsh_tmux_plugin_run
    fi
  fi
else
  print "zsh tmux plugin: tmux not found. Please install tmux before using this plugin."
fi
