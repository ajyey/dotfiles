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
if type -q shelly
    alias update="shelly"
else if type -q paru
    alias update="paru -Syu"
else if type -q yay
    alias update="yay -Syu --answerclean y --answerdiff y --noconfirm"
else
    alias update="sudo pacman -Syu"
end

# Package Search
if type -q shelly
    alias search="shelly query"
else if type -q paru
    alias search="paru -Ss"
else if type -q yay
    alias search="yay -Ss"
else
    alias search="pacman -Ss"
end

# Package Install
if type -q shelly
    alias install="shelly install --upgrade"
else if type -q paru
    alias install="paru -S"
else if type -q yay
    alias install="yay -S"
else
    alias install="sudo pacman -S"
end

# Package Uninstall (-Rns: remove package + unneeded deps + config files)
if type -q shelly
    alias uninstall="shelly remove"
else if type -q paru
    alias uninstall="paru -Rns"
else if type -q yay
    alias uninstall="yay -Rns"
else
    alias uninstall="sudo pacman -Rns"
end

# Added by Antigravity CLI installer
set -gx PATH "/home/aj/.local/bin" $PATH
