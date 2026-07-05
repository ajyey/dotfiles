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

# System Update (all sources)
if type -q shelly
    alias update="shelly upgrade-all -n"
else if type -q paru
    alias update="paru -Syu"
else if type -q yay
    alias update="yay -Syu --answerclean y --answerdiff y --noconfirm"
else
    alias update="sudo pacman -Syu"
end

# Package Search (all sources)
if type -q shelly
    function search -d "Search across standard, AUR, and Flatpak"
        if test (count $argv) -eq 0
            echo "Usage: search <package...>"
            return 1
        end
        set_color blue -o; echo "=== Standard Repos ==="; set_color normal
        shelly query $argv
        set_color blue -o; echo "=== AUR ==="; set_color normal
        shelly aur search $argv
        set_color blue -o; echo "=== Flatpak ==="; set_color normal
        shelly flatpak search $argv
    end
else if type -q paru
    alias search="paru -Ss"
else if type -q yay
    alias search="yay -Ss"
else
    alias search="pacman -Ss"
end

# Package Install (try standard, then AUR, then Flatpak)
if type -q shelly
    function install -d "Install from standard repos, AUR, or Flatpak"
        if test (count $argv) -eq 0
            echo "Usage: install <package...>"
            return 1
        end
        for pkg in $argv
            if shelly query $pkg 2>&1 | grep -q "No package named"
                if shelly aur search $pkg 2>&1 | grep -q "Total results: 0"
                    set_color cyan; echo "Trying Flatpak for $pkg..."; set_color normal
                    shelly flatpak install -n $pkg
                else
                    set_color magenta; echo "Installing $pkg from AUR..."; set_color normal
                    shelly aur install -n $pkg
                end
            else
                set_color green; echo "Installing $pkg from standard repos..."; set_color normal
                shelly install -n $pkg
            end
        end
    end
else if type -q paru
    alias install="paru -S"
else if type -q yay
    alias install="yay -S"
else
    alias install="sudo pacman -S"
end

# Package Uninstall
if type -q shelly
    alias uninstall="shelly remove -n"
    alias aurs="shelly aur"   # Direct AUR commands: aurs install foo, aurs upgrade
else if type -q paru
    alias uninstall="paru -Rns"
else if type -q yay
    alias uninstall="yay -Rns"
else
    alias uninstall="sudo pacman -Rns"
end

# Zellij session shortcuts
if type -q zellij
    alias dev="zellij --session dev"
end

# Added by Antigravity CLI installer
set -gx PATH "/home/aj/.local/bin" $PATH
