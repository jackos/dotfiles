set fish_greeting
fish_vi_key_bindings

set -e GIT_COMITTER_NAME
set -e GIT_AUTHOR_NAME
set -e GIT_AUTHOR_EMAIL

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx GIT_EDITOR nvim

set -gx DISABLE_CHDIR 1
alias m="source ~/m.fish"

# Omarchy
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Alias general
alias code="nvim"
alias lg="lazygit"
alias yy="xsel --clipboard --input"
alias pp="xsel --clipboard --output"

# Config files
alias v="$EDITOR ~/vimwiki/index.md"
alias ca="$EDITOR ~/.config/alacritty/alacritty.toml"
alias cf="$EDITOR ~/.config/fish/config.fish"
alias cl="$EDITOR ~/.config/lazygit/config.yml"
alias ch="$EDITOR ~/.config/hypr"
alias cn="$EDITOR ~/.config/nvim"
alias cm="$EDITOR ~/.config/nvim/lua/config/keymaps.vim"
alias cx="$EDITOR ~/.xinitrc"

# Mojo
alias mr="mojo run"
alias mb="mojo build"
alias mp="mojo package"
alias ms="bazel run //:mojo-stdlib"
alias msh="bazel build //:shmem"
alias mi="bazel run //:install"

switch (uname)
    case Linux
        # arch linux
        alias po="pacman -Qqe >~/pacman.pkg"
        alias s="sudo pacman -S"
        alias u="sudo pacman -Syuu"
        alias r="sudo pacman -Rns"
        alias relector-update="sudo reflector --verbose --latest 200 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist"

        # systemd
        alias ss="sudo systemctl start"
        alias us="systemctl --user start"
        alias sstop="sudo systemctl stop"
        alias ustop="systemctl --user stop"
        alias srestart="sudo systemctl restart"
        alias urestart="systemctl --user restart"
        alias ureload="systemctl --user daemon-reload"
        alias sreload="sudo systemctl daemon-reload"
        alias sstat="sudo systemctl status"
        alias ustat="systemctl --user status"
end

# Remote neovim terminal
function nv
    # Check if we're already inside a Neovim terminal
    if test -n "$NVIM"
        # We're inside Neovim, use native --remote to open in parent
        command nvim --server $NVIM --remote $argv
    else
        # Try to find a running Neovim instance
        set -l servers (command nvim --serverlist)
        if test -n "$servers"
            # Use the first available server
            set -l server (echo $servers | string split '\n' | head -n1)
            command nvim --server $server --remote $argv
        else
            # No server found, start new instance with a server name
            command nvim --listen ~/.cache/nvim/server.pipe $argv
        end
    end
end

# Nice time for last command to run format 
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
