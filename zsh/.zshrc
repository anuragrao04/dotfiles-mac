# ~/.zshrc — fast, no Oh My Zsh

# ---- Core shell behaviour -------------------------------------------------
export ZSH_DISABLE_COMPFIX=true
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS NO_BEEP PROMPT_SUBST
# Hide zsh's partial-line marker (`%`) that can appear above/ before prompt.
PROMPT_EOL_MARK=''
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS SHARE_HISTORY
setopt EXTENDED_HISTORY INC_APPEND_HISTORY

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

# ---- PATH -----------------------------------------------------------------
path=(
  "$HOME/.ai-stats/bin"
  "/opt/homebrew/opt/openjdk/bin"
  "$HOME/.local/bin"
  "$HOME/.bun/bin"
  "$HOME/.cargo/bin"
  "$HOME/go/bin"
  "$HOME/.pi/agent/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  $path
)
typeset -U path PATH

export NODE_EXTRA_CA_CERTS="$HOME/.certs/ZscalerRootCA.crt"
export BUN_INSTALL="$HOME/.bun"
export PYENV_ROOT="$HOME/.pyenv"
export NVM_DIR="$HOME/.nvm"
export WERF_HELM3_MODE=1
# Avoid spawning `tty` during startup; terminals usually set $TTY.
[[ -n "$TTY" ]] && export GPG_TTY="$TTY"

# AI Usage Tracker
export TRACKER_LIB="$HOME/.ai-stats/lib"
export TRACKER_API_URL="https://vyom-api.concierge.razorpay.com/api/v1/pulse"
export TRACKER_API_KEY="local-dev-key"

# Put a current Node on PATH without loading nvm.
# This avoids a full nvm init but keeps npm globals like pi/mcp2cli available.
if [[ -d "$NVM_DIR/versions/node/v22.22.1/bin" ]]; then
  path=("$NVM_DIR/versions/node/v22.22.1/bin" $path)
fi

# Load tokens from ~/tokens/ as env vars: filename=key, contents=value.
for f in "$HOME"/tokens/*(N); do
  export "${f:t}"="$(<"$f")"
done

# ---- Prompt ---------------------------------------------------------------
# Starship prompt, wired manually so startup doesn't run `starship init zsh`.
# The prompt itself calls starship when drawn; shell config load stays tiny.
if [[ -x /opt/homebrew/bin/starship ]]; then
  zmodload zsh/parameter
  zmodload zsh/datetime
  zmodload zsh/mathfunc
  autoload -Uz add-zsh-hook
  __starship_get_time() { (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) )) }
  prompt_starship_precmd() {
    STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=(${pipestatus[@]})
    if (( ${+STARSHIP_START_TIME} )); then
      __starship_get_time && STARSHIP_DURATION=$(( STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
      unset STARSHIP_START_TIME
    else
      unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
    fi
    STARSHIP_JOBS_COUNT="${#jobstates[*]}"
  }
  prompt_starship_preexec() { __starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME }
  add-zsh-hook precmd prompt_starship_precmd
  add-zsh-hook preexec prompt_starship_preexec

  # Add one blank line before prompts after a command has run, but not at startup.
  __prompt_spacer_preexec() { __PROMPT_NEEDS_SPACER=1 }
  __prompt_spacer_precmd() {
    if [[ -n "$__PROMPT_NEEDS_SPACER" ]]; then
      print -r -- ""
      unset __PROMPT_NEEDS_SPACER
    fi
  }
  add-zsh-hook preexec __prompt_spacer_preexec
  add-zsh-hook precmd __prompt_spacer_precmd

  export STARSHIP_SHELL=zsh
  export STARSHIP_SESSION_KEY="${RANDOM}${RANDOM}${RANDOM}${RANDOM}"
  VIRTUAL_ENV_DISABLE_PROMPT=1
  PROMPT='$(/opt/homebrew/bin/starship prompt --terminal-width="$COLUMNS" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
  RPROMPT=''
  PROMPT2='%F{8}∙%f '
else
  PROMPT='%F{green}%n@%m%f %F{cyan}%~%f %# '
fi

# ---- Lazy interactive features -------------------------------------------
# Keep startup sub-200ms: don't initialize completions/fzf/bun until needed.
__load_completions_once() {
  if [[ -z "$__COMPLETIONS_LOADED" ]]; then
    __COMPLETIONS_LOADED=1
    autoload -Uz compinit
    compinit -C -d "$HOME/.zcompdump-fast"
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
    zstyle ':completion:*' menu select
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
    [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
  fi
  zle expand-or-complete
}
zle -N __load_completions_once
bindkey '^I' __load_completions_once

# fzf: load only before first fzf keybinding use.
__load_fzf_once() {
  unfunction __load_fzf_once 2>/dev/null
  if command -v fzf >/dev/null 2>&1; then
    if [[ ! -f "$HOME/.fzf.zsh" || "$(command -v fzf)" -nt "$HOME/.fzf.zsh" ]]; then
      fzf --zsh > "$HOME/.fzf.zsh"
    fi
    source "$HOME/.fzf.zsh"
  fi
  zle ${WIDGET#lazy-}
}
for widget in fzf-history-widget fzf-file-widget fzf-cd-widget; do
  eval "lazy-$widget() { __load_fzf_once }"
  zle -N lazy-$widget
  case $widget in
    fzf-history-widget) bindkey '^R' lazy-$widget ;;
    fzf-file-widget) bindkey '^T' lazy-$widget ;;
    fzf-cd-widget) bindkey '^[c' lazy-$widget ;;
  esac
done

# zoxide — smarter cd. Init is cheap; keep it eager for `cd=z`.
export _ZO_DOCTOR=0
if command -v zoxide >/dev/null 2>&1; then
  if [[ ! -f "$HOME/.zoxide.zsh" || "$(command -v zoxide)" -nt "$HOME/.zoxide.zsh" ]]; then
    zoxide init zsh > "$HOME/.zoxide.zsh"
  fi
  source "$HOME/.zoxide.zsh"
  alias cd=z
  alias cdi=zi
fi

# Syntax highlighting. Keep this near the end so it wraps ZLE widgets correctly.
[[ -r "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Lazy loaders --------------------------------------------------------------
# nvm: load only when explicitly requested.
nvm() {
  unset -f nvm
  [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && source "/opt/homebrew/opt/nvm/nvm.sh"
  [[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]] && source "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}

# pyenv: load only when explicitly requested.
pyenv() {
  unset -f pyenv
  eval "$(command pyenv init - zsh)"
  pyenv "$@"
}

# ---- Aliases --------------------------------------------------------------
alias custom-terragrunt="$HOME/repos/terragrunt/terragrunt"
alias claude-mem='$HOME/.bun/bin/bun "$HOME/.claude/plugins/cache/thedotmack/claude-mem/10.5.2/scripts/worker-service.cjs"'
alias helmfile='helmfile --enable-live-output -b werf'

# eza — modern ls replacement
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git --time-style=relative'
  alias la='eza -la --icons --group-directories-first --git --time-style=relative'
  alias lt='eza --tree --icons --group-directories-first --level=2'
  alias lta='eza --tree --icons --group-directories-first --level=2 -a'
else
  alias ll='ls -lh'
  alias la='ls -lah'
fi

# kubectl shortcuts
alias k=kubectl
alias kg='kubectl get'
alias kgp='kubectl get pods'
alias kgno='kubectl get nodes'
alias kgrs='kubectl get replicasets'
alias kgd='kubectl get deployments'
alias kgds='kubectl get daemonsets'
alias kgimg='kubectl get deployments -o wide'
alias kgir='kubectl get ingressroute'
alias kgmid='kubectl get middleware'
alias kgcr='kubectl get clusterrole'
alias kgcrb='kubectl get clusterrolebinding'
alias kgrole='kubectl get role'
alias kgrb='kubectl get rolebinding'
alias kgcj='kubectl get cronjobs'
alias kgj='kubectl get jobs'
alias kgsec='kubectl get secrets'
alias kgsa='kubectl get serviceaccounts'
alias kgsvc='kubectl get services'
alias kd='kubectl describe'
alias kdp='kubectl describe pods'
alias kdno='kubectl describe nodes'
alias kdrs='kubectl describe replicasets'
alias kdd='kubectl describe deployments'
alias kdds='kubectl describe daemonsets'
alias kdimg='kubectl describe deployments -o wide'
alias kdir='kubectl describe ingressroute'
alias kdmid='kubectl describe middleware'
alias kdcr='kubectl describe clusterrole'
alias kdcrb='kubectl describe clusterrolebinding'
alias kdrole='kubectl describe role'
alias kdrb='kubectl describe rolebinding'
alias kdcj='kubectl describe cronjobs'
alias kdj='kubectl describe jobs'
alias kdsec='kubectl describe secrets'
alias kdsa='kubectl describe serviceaccounts'
alias kdsvc='kubectl describe services'
alias kroll='kubectl rollout restart'
alias krolld='kubectl rollout restart deploy'
alias ka='kubectl apply -f'
alias kdiff='kubectl diff -f'
alias ke='kubectl edit'
alias kep='kubectl edit pods'
alias kers='kubectl edit replicasets'
alias ked='kubectl edit deployments'
alias keds='kubectl edit daemonsets'
alias keimg='kubectl edit deployments -o wide'
alias keir='kubectl edit ingressroute'
alias kemid='kubectl edit middleware'
alias kecr='kubectl edit clusterrole'
alias kecrb='kubectl edit clusterrolebinding'
alias kerole='kubectl edit role'
alias kerb='kubectl edit rolebinding'
alias kecj='kubectl edit cronjobs'
alias kej='kubectl edit jobs'
alias kesec='kubectl edit secrets'
alias kesa='kubectl edit serviceaccounts'
alias kesvc='kubectl edit services'
alias ksh='kubectl exec -it'
alias kl='kubectl logs -f'
alias ktp='kubectl top pods'
alias ktno='kubectl top nodes'
alias kdel='kubectl delete'
alias kdelp='kubectl delete pods'
alias kdelrs='kubectl delete replicasets'
alias kdeld='kubectl delete deployments'
alias kdelds='kubectl delete daemonsets'
alias kdelimg='kubectl delete deployments -o wide'
alias kdelir='kubectl delete ingressroute'
alias kdelmid='kubectl delete middleware'
alias kdelcr='kubectl delete clusterrole'
alias kdelcrb='kubectl delete clusterrolebinding'
alias kdelrole='kubectl delete role'
alias kdelrb='kubectl delete rolebinding'
alias kdelcj='kubectl delete cronjobs'
alias kdelj='kubectl delete jobs'
alias kdelsec='kubectl delete secrets'
alias kdelsa='kubectl delete serviceaccounts'
alias kdelsvc='kubectl delete services'

# Clone a Razorpay GitHub repo by short name.
rclone() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: rclone <repo> [git clone options...] [directory]" >&2
    return 1
  fi
  local repo="$1"
  shift
  local url="git@github.com:razorpay/${repo}"
  if [[ $# -eq 0 ]]; then
    mkdir -p "$HOME/repos"
    git clone "$url" "$HOME/repos/$repo"
  else
    git clone "$url" "$@"
  fi
}
