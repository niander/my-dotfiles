# disable-windows-path.sh stops WSL appending the whole Windows PATH. Restore what
# interop needs, appended so Linux binaries always win.
if [[ -n "$WSL_DISTRO_NAME" ]]
then
    path+=(/mnt/c/Windows/System32 /mnt/c/Windows)

    () {
        setopt localoptions extendedglob
        local -a keep
        local entry dir pat cmd=/mnt/c/Windows/System32/cmd.exe

        [[ -x $cmd && -r $DOTFILES/wsl/windows-path.keep ]] || return
        keep=(${(f)"$(<$DOTFILES/wsl/windows-path.keep)"})
        keep=(${${keep%%\#*}##[[:space:]]#})
        keep=(${${keep%%[[:space:]]#}:#})
        # Accept either separator and surrounding ones; the pattern needs one shape.
        keep=(${keep//\\//})
        keep=(${${keep##/##}%%/##})
        (( $#keep )) || return

        # Match a whole trailing segment, case-insensitively. (@b) keeps a glob
        # character inside a keep entry literal.
        pat="*/(${(j:|:)${(@b)keep}})/#"

        # cmd.exe needs a Windows cwd.
        for entry in ${(s.;.)${"$(cd /mnt/c && $cmd /c 'echo %PATH%')"//$'\r'/}}
        do
            [[ ${entry//\\//} == (#i)${~pat} ]] || continue
            dir=$(wslpath -u $entry 2>/dev/null)
            [[ -d $dir ]] && path+=($dir)
        done
    }
fi
