function cwe
    cargo watch -cx "run --example $argv"
end

function cwt
    cargo watch -cx "test $argv"
end

function cwr
    cargo watch -cx "run $argv"
end

function cws
    cargo watch -cs "$argv"
end
