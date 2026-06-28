# ====================================================================
# Arch / CachyOS Specific Configuration
# ====================================================================

# Source CachyOS default configurations if present
if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# 1Password Agent Socket
if not set -q SSH_AUTH_SOCK
    set -l onepassword_linux "$HOME/.1password/agent.sock"
    if test -S "$onepassword_linux"
        set -gx SSH_AUTH_SOCK "$onepassword_linux"
    end
end

# System Update
if type -q paru
    alias update="paru -Syu"
else if type -q yay
    alias update="yay -Syu"
else
    alias update="sudo pacman -Syu"
end
