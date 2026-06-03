let carapace_completer = {|spans: list<string>|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -o 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }


    CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
}

$env.config = {
    buffer_editor: "nvim"
    edit_mode: vi
    show_banner: false
    history: {
        max_size: 100000000
        sync_on_enter: true
        file_format: "sqlite"
        isolation: false
    }
    completions: {
        external: {
            enable: true
            completer: $carapace_completer
        }
    }
}

# Default editor settings.
$env.EDITOR = "nvim"
$env.VISUAL = $env.EDITOR
$env.GIT_EDITOR = "nvim"

$env.path ++= [
    $"($env.HOME)/src/zig/build/stage3/bin"
    $"($env.HOME)/src/ziglab/zig-out/bin"
    $"($env.HOME)/.local/bin"
    "/opt/cuda/bin"
    $"($env.HOME)/scripts"
    $"($env.HOME)/.local/odin"
    $"($env.HOME)/.local/share/nvm/v24.7.0/bin"
    $"($env.HOME)/.cargo/bin"
]

##################
# Aliases
##################

# Fuzzy find files and open in your editor after pressing enter.
def ff [] {
    let files = (
        fd .
        | sk -m --preview "bat --color=always --style=numbers --line-range=:500 {}"
        | lines
    )

    if ($files | is-not-empty) {
        run-external $env.EDITOR ...$files
    }
}

alias lg = lazygit

def v [] { run-external $env.EDITOR $"($env.HOME)/vimwiki/index.md" }

# Quick commands to edit config files.
def cf [] { run-external $env.EDITOR $"($env.HOME)/.config/foot/foot.ini" }
def cg [] { run-external $env.EDITOR $"($env.HOME)/.gitconfig" }
def cl [] { run-external $env.EDITOR $"($env.HOME)/.config/lazygit/config.yml" }
def ch [] { run-external $env.EDITOR $"($env.HOME)/.config/hypr/hyprland.conf" }
def ck [] { run-external $env.EDITOR $"($env.HOME)/.config/hypr/bindings.conf" }
def cn [] { run-external $env.EDITOR $"($env.HOME)/.config/nvim/lua" }
def cnu [] { run-external $env.EDITOR $"($env.HOME)/.config/nushell/config.nu" }
def cm [] { run-external $env.EDITOR $"($env.HOME)/.config/nvim/lua/config/keymaps.lua" }

def require-command [name: string] {
    if (which $name | is-empty) {
        error make {msg: $"required command not found: ($name)"}
    }
}

# Clears out any commands that failed from history
def clear-history-failures [] {
    require-command sqlite3

    let history_db = $"($env.HOME)/.config/nushell/history.sqlite3"
    let deleted = (sqlite3 $history_db "SELECT count(*) FROM history WHERE exit_status = 1;" | into int)

    sqlite3 $history_db "DELETE FROM history WHERE exit_status = 1; VACUUM;"
    print $"cleared ($deleted) history rows with exit_status = 1"
}

# pacman and paru aliases
alias s = sudo pacman -Syuu
alias p = paru -Syuu
alias r = paru -Rns
alias d = paru -Si
def pb [] { require-command paru; paru -Qqe | save --force $"($env.HOME)/arch-packages-backup.txt" }

# systemd shortcuts
alias ss = sudo systemctl
alias su = systemctl --user
alias ssr = ss restart
alias sur = su restart
alias ssd = ss daemon-reload
alias sud = su daemon-reload

##################
# Prompt
##################

# Displays time to run last command, formatted nicely depending on how long it took e.g. 2s 223ms
$env.PROMPT_COMMAND_RIGHT = {||
    let ms = if $env.CMD_DURATION_MS == "0823" { 0 } else { 
      $env.CMD_DURATION_MS | into int 
    }
    let hours = ($ms / 3600000 | math floor)
    let minutes = (($ms mod 3600000) / 60000 | math floor)
    let seconds = (($ms mod 60000) / 1000 | math floor)
    let milliseconds = ($ms mod 1000)
    mut parts = []

    if ($hours > 0) { $parts = ($parts | append $"($hours)h") }
    if ($minutes > 0) { $parts = ($parts | append $"($minutes)m") }
    if ($seconds > 0) { $parts = ($parts | append $"($seconds)s") }
    if ($milliseconds > 0 or ($parts | is-empty)) {
        $parts = ($parts | append $"($milliseconds)ms")
    }

    let duration = $parts | str join " "

    return $"(ansi purple)^ took ($duration)"
}
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = null
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = "\n"
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "V "
$env.PROMPT_MULTILINE_INDICATOR = "C "

###################
# Utility Functions
###################

def yy [] {
    let input = $in

    if ($input == null) {
        print -e "Pipe to system clipboard.\n\nUsage:\n  echo [input] | yy"
        return
    }

    print --no-newline $"\u{1b}]52;c;($input | to text | encode base64)\u{07}"
}
