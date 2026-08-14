# colors everywhere
export CLICOLOR=1
export CLICOLOR_FORCE=1
export LSCOLORS=exfxcxdxbxegedabagacad

# ls
alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -aG'

# grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# diff
alias diff='diff --color=auto'

# ripgrep (if installed) is color by default
command -v rg >/dev/null && export RIPGREP_CONFIG_PATH=~/.ripgreprc

# man pages with color
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;32m'

# zsh completion colors
autoload -Uz compinit && compinit
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# oh-my-posh
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/night-owl.omp.json)"

# zsh-autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf
source <(fzf --zsh)

# zoxide
eval "$(zoxide init zsh)"
alias cd='z'

# eza (modern ls)
alias ls='eza --color=always --group-directories-first'
alias ll='eza -l --color=always --group-directories-first --git'
alias la='eza -la --color=always --group-directories-first --git'
alias lt='eza --tree --level=2'

# bat (modern cat)
alias cat='bat --paging=never'

# delta (pretty git diffs) — pager set globally, see setup

# history tuning
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE

# zsh-syntax-highlighting (must be sourced last)
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh