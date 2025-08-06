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
    fastfetch
end

# ====================================================================
# Environment Variables & PATH Configuration
# ====================================================================

# Add Homebrew to PATH (Apple Silicon - change to /usr/local/bin for Intel Mac)
set -x PATH /opt/homebrew/bin $PATH

# Add user-specific binary directories
set -x PATH ~/.npm-global/bin $PATH
set -x PATH $PATH $HOME/.local/bin

# Add asdf version manager shims
set -gx PATH $HOME/.asdf/shims $PATH

# Add LM Studio CLI tools
set -gx PATH $PATH /Users/AJ/.lmstudio/bin

# Configure 1Password SSH Agent
set -x SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# ====================================================================
# Terminal Integration
# ====================================================================

# iTerm2 shell integration
test -e "$HOME/.iterm2_shell_integration.fish"; and source "$HOME/.iterm2_shell_integration.fish"

# Set version environment variables for iTerm2 status bar
set nodeVersion (node --version)
iterm2_set_user_var nodeVersion $nodeVersion
set pythonVersion (python3 --version | awk '{ print $2 }')
iterm2_set_user_var pythonVersion $pythonVersion
set javaVersion (java --version | grep 'openjdk' | awk '{print $2}')
iterm2_set_user_var javaVersion $javaVersion

# ====================================================================
# Aliases
# ====================================================================

# Shell Management
alias reload="exec fish"                    # Reload Fish shell
alias please='sudo'                         # Polite sudo

# Python
alias python="python3"                      # Use Python 3 by default

# File Listing (using eza for enhanced ls)
alias ls='eza -al --color=always --group-directories-first --icons'  # Detailed listing
alias la='eza -a --color=always --group-directories-first --icons'   # All files and dirs
alias ll='eza -l --color=always --group-directories-first --icons'   # Long format
alias lt='eza -aT --color=always --group-directories-first --icons'  # Tree listing
alias l.="eza -a | grep -e '^\.'"                                     # Show only dotfiles

# Navigation
alias ..='cd ..'                            # Go up one directory
alias ...='cd ../..'                        # Go up two directories
alias ....='cd ../../..'                    # Go up three directories
alias .....='cd ../../../..'                # Go up four directories
alias ......='cd ../../../../..'            # Go up five directories
alias cd='z'                                # Use zoxide for smart directory jumping

# SSH Connections
alias ubuntu="ssh aj@192.168.68.66"         # Connect to Ubuntu server
alias pi="ssh dietpi@192.168.68.44"         # Connect to Raspberry Pi
alias synology="ssh aj@192.168.68.69"       # Connect to Synology NAS
alias cachy="ssh aj@192.168.68.210"         # Connect to CachyOS machine

# Network Tools
alias cachywake='wakeonlan 2c:fd:a1:e0:54:3c'  # Wake up CachyOS machine

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
if test -d ~/.fzf
    source ~/.fzf/shell/key-bindings.fish
    source ~/.fzf/shell/completion.fish
end

# FZF appearance and behavior
set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --border'

# Use fd (if available) for faster file searching
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
end

# ====================================================================
# Version Manager Initialization
# ====================================================================

# ASDF Version Manager Setup
set -x ASDF_DIR $HOME/.asdf

# Load ASDF completions and functions
if test -f /opt/homebrew/share/fish/vendor_completions.d/asdf.fish
    source /opt/homebrew/share/fish/vendor_completions.d/asdf.fish
end

if test -f $ASDF_DIR/asdf.fish
    source $ASDF_DIR/asdf.fish
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

# ASDF Language-Specific Environment Setup
# if test -f ~/.asdf/plugins/java/set-java-home.fish
#     source ~/.asdf/plugins/java/set-java-home.fish
# end
# if test -f ~/.asdf/plugins/golang/set-env.fish
#     source ~/.asdf/plugins/golang/set-env.fish
# end
