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
function update -d "Update system and tools"
    sudo apt update; and sudo apt upgrade -y
    if type -q mise
        mise upgrade --bump
    end
end

# Package Search
alias search="apt search"

# Package Install / Uninstall
alias install="sudo apt install"
alias uninstall="sudo apt purge"
