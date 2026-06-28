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
set -g fish_color_error red
# ====================================================================
# Environment Variables & PATH Configuration
# ====================================================================

function __add_path_if_dir
    set -l dir $argv[1]
    if test -d "$dir"; and not contains -- "$dir" $PATH
        set -gx PATH "$dir" $PATH
    end
end

# Homebrew paths for Apple Silicon macOS, Intel macOS, and Linuxbrew
__add_path_if_dir /opt/homebrew/bin
__add_path_if_dir /usr/local/bin
__add_path_if_dir /home/linuxbrew/.linuxbrew/bin

# User-specific binary directories
__add_path_if_dir $HOME/.npm-global/bin
__add_path_if_dir $HOME/.local/bin
__add_path_if_dir $HOME/.lmstudio/bin

# Configure 1Password SSH Agent when its socket exists
if not set -q SSH_AUTH_SOCK
    set -l onepassword_macos "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    set -l onepassword_linux "$HOME/.1password/agent.sock"
    if test -S "$onepassword_macos"
        set -gx SSH_AUTH_SOCK "$onepassword_macos"
    else if test -S "$onepassword_linux"
        set -gx SSH_AUTH_SOCK "$onepassword_linux"
    end
end

# ====================================================================
# Terminal Integration
# ====================================================================

# iTerm2 shell integration
test -e "$HOME/.iterm2_shell_integration.fish"; and source "$HOME/.iterm2_shell_integration.fish"

# Set version environment variables for iTerm2 status bar
if functions -q iterm2_set_user_var
    if type -q node
        set nodeVersion (node --version)
        iterm2_set_user_var nodeVersion $nodeVersion
    end

    if type -q python3
        set pythonVersion (python3 --version | awk '{ print $2 }')
        iterm2_set_user_var pythonVersion $pythonVersion
    end

    if type -q java
        set javaVersion (java --version 2>&1 | string match -r '\d+(\.\d+)+' | head -n 1)
        iterm2_set_user_var javaVersion $javaVersion
    end
end

# ====================================================================
# Aliases
# ====================================================================

# Shell Management
alias reload="exec fish"                    # Reload Fish shell

# System Update
# Source CachyOS default configurations if present
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# Debian / macOS System Update
if type -q apt
    alias update="sudo apt update && sudo apt upgrade -y"
else if type -q brew
    alias update="brew update && brew upgrade"
end

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
alias debian="ssh aj@192.168.68.211" # Connect to Proxmox Debian VM
alias proxmox="ssh root@192.168.68.208" # Connect to Proxmox VE
alias pbs="ssh root@192.168.68.66" # Connect to Proxmox Backup Server
alias ubuntu="ssh aj@192.168.68.66"         # Connect to Ubuntu server
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
# Wrap brew install and uninstall to keep Brewfile updated on MacOS
# ====================================================================
if test (uname) = Darwin
    function brew
        if test (count $argv) -ge 1
            if test $argv[1] = install -o $argv[1] = uninstall
                command brew $argv
                and brew bundle dump --file=~/Development/dotfiles/Brewfile --force
                return
            end
        end
        command brew $argv
    end
end

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


