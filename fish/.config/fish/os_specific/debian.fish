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

# LaTeX Live Watch Function - Usage: texwatch [file.tex]
# Continuously watches a .tex file for changes and auto-compiles to PDF using latexmk.
function texwatch --description "Watch .tex file for changes and auto-compile PDF with latexmk"
    set -l tex $argv[1]
    if test -z "$tex"
        set -l tex_files (path filter -f -- *.tex 2>/dev/null)
        if test (count $tex_files) -gt 0
            set tex (command ls -t -- $tex_files 2>/dev/null | head -n1)
        end
    end

    if test -z "$tex"
        echo "No .tex file found in the current directory."
        return 1
    end

    echo "Watching: $tex"
    latexmk -pdf -pvc -interaction=nonstopmode -halt-on-error "$tex"
end
