# ====================================================================
# Fish Shell Configuration
# ====================================================================
# Personal Fish shell configuration with custom aliases, functions,
# and tool integrations for development workflow.

# ====================================================================
# Welcome Message
# ====================================================================
## Display fastfetch system information on shell startup
function fish_greeting
    if type -q fastfetch
        fastfetch
    end
end

# ====================================================================
# Syntax Highlighting Colors
# ====================================================================
# Turn valid commands green and invalid commands red
set -g fish_color_command 4ade80  # Solid true green
set -g fish_color_error eb6f92    # Rose Pine "Love" (Soft Red) for invalid commands/args
set -g fish_color_param 9ccfd8    # Rose Pine "Foam" (Cyan) for regular parameters
set -g fish_color_quote f6c177    # Rose Pine "Gold" for strings
# ====================================================================
# Environment Variables & PATH Configuration
# ====================================================================

function __add_path_if_dir
    set -l dir $argv[1]
    if test -d "$dir"; and not contains -- "$dir" $PATH
        set -gx PATH "$dir" $PATH
    end
end

# User-specific binary directories
__add_path_if_dir $HOME/.npm-global/bin
__add_path_if_dir $HOME/.local/bin
__add_path_if_dir $HOME/.lmstudio/bin

# ====================================================================
# OS-Specific Configuration Loading
# ====================================================================
set -l os (uname)
if test "$os" = "Darwin"
    source (status dirname)/os_specific/mac.fish
else if test "$os" = "Linux"
    if test -f /etc/debian_version
        source (status dirname)/os_specific/debian.fish
    else if test -f /etc/arch-release
        source (status dirname)/os_specific/arch.fish
    end
end


# Aliases
# ====================================================================

# Shell Management
alias reload="exec fish"                    # Reload Fish shell

# System Update
# (Update aliases are configured in os_specific files)

# Python
if type -q python3
    alias python="python3"                  # Use Python 3 by default
end

# File Listing (using eza for enhanced ls)
if type -q eza
    alias ls='eza -al --color=always --group-directories-first --icons'  # Detailed listing
    alias la='eza -a --color=always --group-directories-first --icons'   # All files and dirs
    alias ll='eza -l --color=always --group-directories-first --icons'   # Long format
    alias lt='eza -aT --color=always --group-directories-first --icons'  # Tree listing
    alias l.="eza -a | grep -e '^\.'"                                    # Show only dotfiles
else
    alias ll='ls -lh'
    alias la='ls -A'
    alias l.='ls -d .*'
end

# Navigation
alias ..='cd ..'                            # Go up one directory
alias ...='cd ../..'                        # Go up two directories
alias ....='cd ../../..'                    # Go up three directories
alias .....='cd ../../../..'                # Go up four directories
alias ......='cd ../../../../..'            # Go up five directories
if type -q zoxide
    alias cd='z'                            # Use zoxide for smart directory jumping
end

# SSH Connections

# alias debian="ssh -t aj@192.168.68.211"
# Connect to Proxmox Debian VM and automatically attach to zellij session
alias debian="ssh -t aj@192.168.68.211 'fish -C \"zellij attach -c debian\"'" 
alias proxmox="ssh root@192.168.68.208" # Connect to Proxmox VE
alias pbs="ssh root@192.168.68.66" # Connect to Proxmox Backup Server
alias pi="ssh dietpi@192.168.68.44"         # Connect to Raspberry Pi
alias synology="ssh aj@192.168.68.69"       # Connect to Synology NAS
alias cachy="ssh aj@192.168.68.166"         # Connect to CachyOS machine (Ethernet)

# Network Tools
if type -q wakeonlan
    alias cachywake='wakeonlan d8:43:ae:fa:7b:2d'  # Wake up CachyOS machine (Ethernet MAC)
end

# ====================================================================
# Custom Functions
# ====================================================================

# Git commit shortcut - Usage: gc "commit message"
function gc
    git commit -m "$argv"
end

# ====================================================================
# Tool Configurations
# ====================================================================

# FZF (Fuzzy Finder) Configuration
# Keybindings: Ctrl+R (history), Ctrl+T (files), Alt+C (directories)
if test -f ~/.fzf/shell/key-bindings.fish
    source ~/.fzf/shell/key-bindings.fish
end

if test -f ~/.fzf/shell/completion.fish
    source ~/.fzf/shell/completion.fish
end

# FZF appearance and behavior
set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --border'

# Use fd/fdfind (if available) for faster file searching
begin
    set -l fd_cmd
    if type -q fd
        set fd_cmd fd
    else if type -q fdfind
        set fd_cmd fdfind
    end

    if set -q fd_cmd
        set -gx FZF_DEFAULT_COMMAND "$fd_cmd --type f --hidden --exclude .git"
        set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
        set -gx FZF_ALT_C_COMMAND "$fd_cmd --type d --hidden --exclude .git"
    end
end

# ====================================================================
# Version Manager Initialization
# ====================================================================

# Mise Version Manager Setup
if type -q mise
    mise activate fish | source
else if test -x ~/.local/bin/mise
    ~/.local/bin/mise activate fish | source
end

# ====================================================================
# Navigation & Directory Tools
# ====================================================================

# Zoxide (smart cd replacement) initialization
if type -q zoxide
    zoxide init fish | source
end

# ====================================================================
# Prompt & Theme
# ====================================================================

# Starship prompt initialization
if type -q starship
    starship init fish | source
end

# ====================================================================
# (OS-specific wrapper functions have been moved to os_specific/ directories)

# ====================================================================

# ====================================================================
# Commented Out Configurations
# ====================================================================
# The following sections are disabled but kept for reference

# Fisher Plugin Manager (currently using fish_plugins file instead)
# if not functions -q fisher
#     curl -sL https://git.io/fisher | source
#     fisher install jorgebucaran/fisher
# end

# Conda Environment Manager
# if test -f /opt/homebrew/Caskroom/miniconda/base/bin/conda
#     eval (/opt/homebrew/Caskroom/miniconda/base/bin/conda shell.fish hook)
# end


