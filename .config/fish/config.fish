# Remove fish greeting and enable <esc> to activate vi mode
set fish_greeting
fish_vi_key_bindings

###################
# Global env vars
###################

set -g fish_history_max_entries 100000000
set -g fish_history_ignore_duplicates 1

# Avoid some remote environments automatically setting these
set -e GIT_COMITTER_NAME
set -e GIT_AUTHOR_NAME
set -e GIT_AUTHOR_EMAIL

# Default editor settings
set -gx EDITOR nvim
set -gx VISUAL $EDITOR
set -gx GIT_EDITOR $EDITOR --wait

# Set SHELL env var to fish for systems where default
# shell can't be changed (e.g. remote instances)
set -gx SHELL (which fish)

##################
# Aliases
##################

# List files and tree commands with pretty output
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'

# Fuzzy find files and open in your editor after pressing enter
alias ff='$EDITOR (fd . | sk -m --preview "bat --color=always --style=numbers --line-range=:500 {}")'

# Lazygit shortcut
alias lg="lazygit"

# SSH to coder workspace with tmux
function cx -d "Connect to coder workspace with tmux"
    if test (count $argv) -lt 1
        echo "Usage: cx <workspace> [session-name]"
        return 1
    end
    set -l session (test (count $argv) -ge 2; and echo $argv[2]; or echo main)
    ssh -t coder.$argv[1] "tmux new-session -As $session"
end

# shortcut to notes index file
alias v="$EDITOR ~/vimwiki/index.md"

# Config files
alias ca="$EDITOR ~/.config/alacritty/alacritty.toml"
alias cf="$EDITOR ~/.config/fish/config.fish"
alias cg="$EDITOR ~/.config/ghostty/config"
alias cl="$EDITOR ~/.config/lazygit/config.yml"
alias ch="$EDITOR ~/.config/hypr/hyprland.conf"
alias ck="$EDITOR ~/.config/hypr/bindings.conf"
alias cn="$EDITOR ~/.config/nvim/lua"
alias cm="$EDITOR ~/.config/nvim/lua/config/keymaps.lua"
alias ct="$EDITOR ~/.config/tmux/tmux.conf"

# paru aliases (AUR helper) only if installed
if type -q paru
    alias s="paru -S"
    alias u="paru -Syuu"
    alias r="paru -Rns"
    alias d="paru -Si"
    alias pb="paru -Qqe >~/arch-packages-backup.txt"
end

# systemd aliases only if systemctl is available
if type -q systemctl
    alias ss="sudo systemctl"
    alias su="systemctl --user"
    alias ssr="ss restart"
    alias sur="su restart"
    alias ssd="ss daemon-reload"
    alias sud="sudo systemctl --user daemon-reload"
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

# Prompt with vi/ssh status, git-aware dir, and time last command took to run
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
# Utility Functions
###################

# Copy piped input to system clipboard using OSC 52 escape sequence
function yy
    if not isatty stdin
        read -z input
        printf "\033]52
c
%s\a" (printf "%s" "$input" | base64 | tr -d '\n')
    else
        printf "Pipe to system clipboard.\n\nUsage:\n  echo [input] | yy" >&2
        return 1
    end
end

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

###################
# Mojo programming
###################

# Only activate mojo aliases if script at ~/mojo.fish exists
if test -f ~/mojo.fish

    set -gx DISABLE_CHDIR 1
    source ~/mojo.fish

    alias mr="mojo run"
    alias mb="mojo build"
    alias mp="mojo package"
    alias ms="bazel run //:mojo-stdlib"

    # Function to build and run Mojo file with MPI
    function mrun -d "Build Mojo file and run with MPI on all GPUs"
        if test (count $argv) -ne 1
            echo "Usage: mrun <filename.mojo >"
            return 1
        end

        set -l mojo_file $argv[1]
        set -l base_name (basename $mojo_file .mojo)

        # Get number of GPUs
        set -l num_gpus (nvidia-smi --query-gpu=name --format=csv,noheader | wc -l)

        echo "Building $mojo_file..."
        mojo build $mojo_file

        if test $status -eq 0
            echo "Running $base_name on $num_gpus GPUs..."
            mpirun -n $num_gpus ./$base_name
        else
            echo "Build failed!"
            return 1
        end
    end
end
