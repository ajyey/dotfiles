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

# Package Management (yay + flatpak)
if type -q yay
    alias update="yay -Syu --noconfirm; and if type -q flatpak; flatpak update -y; end"
    alias uninstall="yay -Rns --noconfirm"

    function search -d "Search standard, AUR, and Flatpak"
        if test (count $argv) -eq 0
            echo "Usage: search <package...>"
            return 1
        end
        set_color blue -o; echo "=== Standard & AUR (yay) ==="; set_color normal
        yay -Ss $argv
        if type -q flatpak
            set_color blue -o; echo "=== Flatpak ==="; set_color normal
            flatpak search $argv
        end
    end

    function install -d "Install from Standard/AUR, fallback to Flatpak"
        if test (count $argv) -eq 0
            echo "Usage: install <package...>"
            return 1
        end
        for pkg in $argv
            if yay -Si $pkg >/dev/null 2>&1
                set_color green; echo "Installing $pkg from Standard/AUR..."; set_color normal
                yay -S --noconfirm $pkg
            else if type -q flatpak
                set_color cyan; echo "Trying Flatpak for $pkg..."; set_color normal
                flatpak install -y $pkg
            else
                set_color red; echo "Package $pkg not found."; set_color normal
            end
        end
    end

    function installed -d "Check if a package is installed"
        if test (count $argv) -eq 0
            echo "Usage: installed <package...>"
            return 1
        end
        for pkg in $argv
            if pacman -Q $pkg >/dev/null 2>&1
                set_color green; echo "✅ $pkg is installed (Standard/AUR)"; set_color normal
            else if type -q flatpak; and flatpak list --app --columns=application,name | grep -iq $pkg
                set_color green; echo "✅ $pkg is installed (Flatpak)"; set_color normal
            else
                set_color red; echo "❌ $pkg is NOT installed"; set_color normal
            end
        end
    end
else
    # Fallback if yay is uninstalled
    alias update="sudo pacman -Syu"
    alias search="pacman -Ss"
    alias install="sudo pacman -S"
    alias uninstall="sudo pacman -Rns"
end

# Zellij session shortcuts
if type -q zellij
    alias dev="zellij --session dev"
end

# Added by Antigravity CLI installer
set -gx PATH "/home/aj/.local/bin" $PATH
