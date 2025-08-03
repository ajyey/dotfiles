# ==========================
# PATH setup
# ==========================

# Add Homebrew to PATH (Apple Silicon default - change to /usr/local/bin if Intel)
set -x PATH /opt/homebrew/bin $PATH

# Add user bins
set -x PATH ~/.npm-global/bin $PATH
set -x PATH $PATH $HOME/.local/bin

# 1Password SSH Agent
set -x SSH_AUTH_SOCK ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# ==========================
# iTerm2 Integration
# ==========================
test -e "$HOME/.iterm2_shell_integration.fish"; and source "$HOME/.iterm2_shell_integration.fish"

# ==========================
# Aliases
# ==========================
alias reload="exec fish"
alias python="python3"
alias ls="eza --header --long"
alias ubuntu="ssh aj@192.168.68.66"
alias pi="ssh dietpi@192.168.68.44"
alias synology="ssh aj@192.168.68.69"
alias dev="cd ~/Development"
alias f="fzf"

# ==========================
# Functions
# ==========================
# Git commit shortcut
function gc
    git commit -m "$argv"
end

# iTerm2 user vars for showing Node/Python/Java versions in the status bar
function iterm2_print_user_vars
    iterm2_set_user_var nodeVersion (node --version)
    iterm2_set_user_var pythonVersion (python3 --version | awk '{ print $2 }')
    # iterm2_set_user_var javaVersion (java --version | grep 'openjdk' | awk '{print $2}')
end

# # ==========================
# # Plugins & Prompt
# # ==========================
# # Install Fisher (Fish plugin manager) if not installed
# if not functions -q fisher
#     curl -sL https://git.io/fisher | source
#     fisher install jorgebucaran/fisher
# end

# # Syntax highlighting, autosuggestions, fzf integration, zoxide, and Tide prompt
# if not test -e ~/.config/fish/functions/tide.fish
#     fisher install PatrickF1/fzf.fish jethrokuan/z IlanCosman/tide@v5
#     tide configure
# end

# # zoxide
# if type -q zoxide
#     zoxide init fish | source
# end

# # fzf
# if type -q fzf
#     fzf --fish | source
# end

# # ==========================
# # Conda Initialization
# # ==========================
# if test -f /opt/homebrew/Caskroom/miniconda/base/bin/conda
#     eval (/opt/homebrew/Caskroom/miniconda/base/bin/conda shell.fish hook)
# end

# # ==========================
# # asdf Initialization
# # ==========================
# if test -f ~/.asdf/asdf.fish
#     source ~/.asdf/asdf.fish
# end

# # Java & Golang environment setup via asdf plugins
# if test -f ~/.asdf/plugins/java/set-java-home.fish
#     source ~/.asdf/plugins/java/set-java-home.fish
# end
# if test -f ~/.asdf/plugins/golang/set-env.fish
#     source ~/.asdf/plugins/golang/set-env.fish
# end

# ==========================
# Starship (Optional)
# ==========================
if type -q starship
    starship init fish | source
end
