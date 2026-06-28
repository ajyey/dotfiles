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
alias update="brew update && brew upgrade && brew cleanup"

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
