# ====================================================================
# Debian Specific Configuration
# ====================================================================

__add_path_if_dir /usr/local/bin

# 1Password Agent Socket
if not set -q SSH_AUTH_SOCK
    set -l onepassword_linux "$HOME/.1password/agent.sock"
    if test -S "$onepassword_linux"
        set -gx SSH_AUTH_SOCK "$onepassword_linux"
    end
end

# System Update
alias update="sudo apt update && sudo apt upgrade -y"
