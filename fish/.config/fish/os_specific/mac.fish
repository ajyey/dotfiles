# ====================================================================
# macOS Specific Configuration
# ====================================================================

# Homebrew paths for Apple Silicon macOS, Intel macOS
__add_path_if_dir /opt/homebrew/bin
__add_path_if_dir /usr/local/bin


# 1Password Agent Socket
if not set -q SSH_AUTH_SOCK
    set -l onepassword_macos "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    if test -S "$onepassword_macos"
        set -gx SSH_AUTH_SOCK "$onepassword_macos"
    end
end

# System Update
alias update="brew update && brew upgrade && brew cleanup; if type -q mise; mise upgrade --bump; end"

# Package Search
alias search="brew search"

# Package Install / Uninstall (routed through brew wrapper to keep Brewfile updated)
alias install="brew install"
alias uninstall="brew uninstall"

# Wrap brew install and uninstall to keep Brewfile updated on MacOS
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
