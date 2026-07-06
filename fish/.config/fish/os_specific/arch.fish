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
    function update -d "Update system, flatpaks, and tools"
        yay -Syu --noconfirm
        if type -q flatpak
            flatpak update -y
        end
        if type -q mise
            mise upgrade --bump
        end
    end
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

    function installed -d "Check if a package is installed (smart match)"
        if test (count $argv) -eq 0
            echo "Usage: installed <package...>"
            return 1
        end
        for pkg in $argv
            set -l found 0
            
            # 1. Exact pacman match
            set -l exact_match (pacman -Q $pkg 2>/dev/null)
            if test -n "$exact_match"
                set found 1
                set_color green; echo "✅ Found exactly '$pkg' (Standard/AUR):"; set_color normal
                echo "   - $exact_match"
            else
                # 2. Fuzzy pacman match (names only)
                set -l fuzzy_matches (pacman -Qq | grep -i "$pkg" 2>/dev/null)
                if test -n "$fuzzy_matches"
                    set found 1
                    set_color yellow; echo "⚠️  No exact match, but found similar (Standard/AUR):"; set_color normal
                    for match in $fuzzy_matches
                        echo "   - "(pacman -Q $match)
                    end
                end
            end

            # 3. Flatpak match
            if type -q flatpak
                set -l fp_matches (flatpak list --app --columns=application,name | grep -i "$pkg")
                if test -n "$fp_matches"
                    set found 1
                    set_color green; echo "✅ Found '$pkg' (Flatpak):"; set_color normal
                    for match in $fp_matches
                        echo "   - $match"
                    end
                end
            end
            
            if test $found -eq 0
                set_color red; echo "❌ No installed packages found matching '$pkg'"; set_color normal
            end
        end
    end
else
    # Fallback if yay is uninstalled
    function update -d "Update system, flatpaks, and tools"
        sudo pacman -Syu --noconfirm
        if type -q flatpak
            flatpak update -y
        end
        if type -q mise
            mise upgrade --bump
        end
    end
    alias search="pacman -Ss"
    alias install="sudo pacman -S"
    alias uninstall="sudo pacman -Rns"
end

# Zellij session shortcuts
if type -q zellij
    alias dev="zellij attach -c dev"
end

# Added by Antigravity CLI installer
set -gx PATH "/home/aj/.local/bin" $PATH
