# Remove fish greeting and enable <esc> to activate vi mode
set fish_greeting
fish_vi_key_bindings

###################
# Global env vars
###################

# Avoid some remote environments automatically setting these
set -e GIT_COMITTER_NAME
set -e GIT_AUTHOR_NAME
set -e GIT_AUTHOR_EMAIL

# Default editor
set -gx EDITOR code
set -gx VISUAL $EDITOR
set -gx GIT_EDITOR $EDITOR --wait

# Default the version of node nvm uses
set -U nvm_default_version 24.10.0

# Default the version of node nvm uses
set -U nvm_default_version 24.10.0

# Set SHELL to fish for e.g. install scripts
set -gx SHELL (which fish)

##################
# Aliases
##################

# Omarchy bash replication
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Shortcut for lazygit
alias lg="lazygit"

# Config files
alias v="$EDITOR ~/vimwiki/index.md"
alias ca="$EDITOR ~/.config/alacritty/alacritty.toml"
alias cf="$EDITOR ~/.config/fish/config.fish"
alias cl="$EDITOR ~/.config/lazygit/config.yml"
alias ch="$EDITOR ~/.config/hypr/bindings.conf"
alias cn="$EDITOR ~/.config/nvim"
alias cm="$EDITOR ~/.config/nvim/lua/config/keymaps.vim"

# Mojo programming
set -gx DISABLE_CHDIR 1
alias mr="mojo run"
alias mb="mojo build"
alias mp="mojo package"
alias ms="bazel run //:mojo-stdlib"
alias mi="bazel run //:install"

switch (uname)
    case Linux
        # arch linux
        alias s="yay -S"
        alias u="yay -Syuu"
        alias r="yay -Rns"

        alias relector-update="sudo reflector --verbose --latest 200 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist"

        # systemd
        alias ss="sudo systemctl start"
        alias us="systemctl --user start"
        alias sr="sudo systemctl restart"
        alias ur="systemctl --user restart"
        alias sstop="sudo systemctl stop"
        alias ustop="systemctl --user stop"
        alias ureload="systemctl --user daemon-reload"
        alias sreload="sudo systemctl daemon-reload"
        alias sstat="sudo systemctl status"
        alias ustat="systemctl --user status"

        # wayland
        alias yy="wl-copy"
        alias pp="wl-paste"
end

##################
# Prompt
##################

# Pretty format duration last command took to run
function format_duration -d "Format duration in milliseconds to human-readable time"
    # Check if CMD_DURATION is set and is a valid number
    if test -z "$CMD_DURATION" -o "$CMD_DURATION" -lt 0
        echo 0ms
    end

    set -l ms $CMD_DURATION

    # Calculate hours, minutes, seconds, and milliseconds
    set -l hours (math -s0 "$ms / 3600000") # 3600000 ms = 1 hour
    set -l minutes (math -s0 "($ms % 3600000) / 60000") # 60000 ms = 1 minute
    set -l seconds (math -s0 "($ms % 60000) / 1000") # 1000 ms = 1 second
    set -l milliseconds (math -s0 "$ms % 1000")

    # Build output string, including only non-zero units
    set -l parts
    if test $hours -gt 0
        set parts $parts "$hours"h
    end
    if test $minutes -gt 0
        set parts $parts "$minutes"m
    end
    if test $seconds -gt 0
        set parts $parts "$seconds"s
    end
    if test $milliseconds -gt 0 -o (count $parts) -eq 0
        set parts $parts "$milliseconds"ms
    end

    # Join parts with spaces and remove any leading/trailing spaces
    if test (count $parts) -gt 0
        echo (string join " " $parts)" "
    else
        echo 0ms
    end
end

# Prompt with vi status, git branch, and time last command took to run
function fish_prompt
    # Check if we're in an SSH session
    if set -q SSH_CLIENT; or set -q SSH_TTY
        set_color --bold green
        echo -n "[SSH] "
        set_color green
    end

    # Directory display logic
    if git rev-parse --git-dir >/dev/null 2>&1
        # We're in a git repository
        # Get the repository root directory name
        set -l git_root (basename (git rev-parse --show-toplevel 2>/dev/null))
        # Get the prefix (subdirectory within the repo)
        set -l git_prefix (git rev-parse --show-prefix 2>/dev/null)

        set_color cyan
        echo -n $git_root

        # If we're in a subdirectory, show it
        if test -n "$git_prefix"
            set_color normal
            echo -n /
            set_color cyan
            # Remove trailing slash from prefix
            echo -n (string trim --right --chars=/ $git_prefix)
        end
        set_color normal
    else
        # Not in a git repo, show normal path
        set_color cyan
        echo -n (pwd)
        set_color normal
    end

    # Display duration
    set -l duration (format_duration)
    echo -s (set_color green) " $duration" (set_color normal)
    echo
end

###################
# Path Manipulation
###################

# remove path from user paths added with 'fish_add_path'
function fish_remove_path
    echo "Current fish_user_path entries:"
    echo "===================="

    set -l counter 1
    for path_entry in $fish_user_paths
        echo "[$counter] $path_entry"
        set counter (math $counter + 1)
    end

    echo ""
    read -P "Enter number to remove (or 'q' to quit): " choice

    if test "$choice" = q
        echo "Exiting..."
        return 0
    end

    # Validate input is a number
    if not string match -qr '^\d+$' "$choice"
        echo "Error: Please enter a valid number"
        return 1
    end

    set -l total (count $PATH)

    if test $choice -gt $total -o $choice -lt 1
        echo "Error: Number must be between 1 and $total"
        return 1
    end

    set -l path_to_remove $fish_user_paths[$choice]
    echo ""
    echo "Removing fish user path: $path_to_remove"
    echo ""

    # Try fish_add_path -r first (works for paths added with fish_add_path)
    if set -e fish_user_paths[$choice] 2>/dev/null
        echo "✓ Successfully removed with fish_add_path"
        return
    else
        echo "fish path removal failed"
    end
end

# list all paths in system PATH
function fish_list_paths
    echo "Current PATH entries:"
    echo "===================="

    set -l counter 1
    for path_entry in $PATH
        echo "[$counter] $path_entry"
        set counter (math $counter + 1)
    end
end
