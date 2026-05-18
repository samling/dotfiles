# Per-machine / private dotfile overrides. Drop *.fish files into
# any of these dirs; they get sourced at shell init.
for dir in $HOME/dotfiles-private/fish $HOME/work-dotfiles/fish
    if test -d $dir
        for f in $dir/*.fish
            test -r $f; and source $f
        end
    end
end

# Also pick up loose `~/.config.fish.*` files (mirrors the zsh `~/.zshrc.*` pattern)
for f in $HOME/.config.fish.*
    test -r $f; and source $f
end
