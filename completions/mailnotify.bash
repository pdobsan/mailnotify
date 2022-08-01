_mailnotify()
{
    local CMDLINE
    local IFS=$'\n'
    CMDLINE=(--bash-completion-index $COMP_CWORD)

    for arg in ${COMP_WORDS[@]}; do
        CMDLINE=(${CMDLINE[@]} --bash-completion-word $arg)
    done

    COMPREPLY=( $(/usr/bin/mailnotify "${CMDLINE[@]}") )
}

complete -o filenames -F _mailnotify mailnotify
