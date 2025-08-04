# ==========================
# PATH setup
# ==========================

# Add Homebrew to PATH (Apple Silicon default - change to /usr/local/bin if Intel)
set -x PATH /opt/homebrew/bin $PATH

# Add user bins
set -x PATH ~/.npm-global/bin $PATH
set -x PATH $PATH $HOME/.local/bin

# Add asdf
set -gx PATH $HOME/.asdf/shims $PATH


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

function iterm2_print_user_vars
    set nodeVersion (node --version)
    iterm2_set_user_var nodeVersion $nodeVersion

    set pythonVersion (python3 --version | awk '{ print $2 }')
    iterm2_set_user_var pythonVersion $pythonVersion

    set javaVersion (java --version | grep 'openjdk' | awk '{print $2}')
    iterm2_set_user_var javaVersion $javaVersion
end



# fzf 
# Ctrl+R → Fuzzy search your command history
# Ctrl+T → Fuzzy search files and insert path
# Alt+C → Fuzzy search directories and cd into them
if test -d ~/.fzf
    source ~/.fzf/shell/key-bindings.fish
    source ~/.fzf/shell/completion.fish
end
# fzf colors and layout
set -gx FZF_DEFAULT_OPTS '--height 40% --reverse --border'
# Use fd (if installed) instead of find for faster file search
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --exclude .git'
    set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
end


# # ==========================
# # asdf Initialization
# # ==========================

# Set ASDF_DIR
set -x ASDF_DIR $HOME/.asdf

# Source asdf Fish completions and functions
if test -f /opt/homebrew/share/fish/vendor_completions.d/asdf.fish
    source /opt/homebrew/share/fish/vendor_completions.d/asdf.fish
end

if test -f $ASDF_DIR/asdf.fish
    source $ASDF_DIR/asdf.fish
end




# # ==========================
# # Plugins & Prompt
# # ==========================
# # Install Fisher (Fish plugin manager) if not installed
# if not functions -q fisher
#     curl -sL https://git.io/fisher | source
#     fisher install jorgebucaran/fisher
# end

# zoxide
if type -q zoxide
    zoxide init fish | source
end

# # ==========================
# # Conda Initialization
# # ==========================
# if test -f /opt/homebrew/Caskroom/miniconda/base/bin/conda
#     eval (/opt/homebrew/Caskroom/miniconda/base/bin/conda shell.fish hook)
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
