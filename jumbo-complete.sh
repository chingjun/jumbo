#auto completion
_jumbo() {
    local loc=$COMP_CWORD
    local actionloc=1
    while [[ "${COMP_WORDS[$actionloc]::1}" == "-" ]]
    do
        actionloc=$((actionloc + 1))
    done
    local cur=${COMP_WORDS[$COMP_CWORD]}
    local action=${COMP_WORDS[$actionloc]}
    if [[ "${cur::1}" == "-" ]]
    then
        true
    elif [[ "$loc" == "$actionloc" ]]
    then
        COMPREPLY=($(compgen -W "$(jumbo 2>&1 | awk '/^ /{print $1}')" $cur))
    else
        case "X$action" in
            # search all packages
            Xsearch|Xinstall)
                COMPREPLY=($([ -f "$JUMBO_ROOT/var/jumbo/list" ] && compgen -W "$(awk '{print $1}' < "$JUMBO_ROOT/var/jumbo/list")" -- $cur));;
            # search installed packages
            Xremove|Xupdate|Xlist-files|Xlist)
                COMPREPLY=($([ -f "$JUMBO_ROOT/var/jumbo/installed_list" ] && compgen -W "$(awk '{print $1}' < "$JUMBO_ROOT/var/jumbo/installed_list")" -- $cur));;
            # local file
            Xlocal-install)
                COMPREPLY=($( ( compgen -d $cur | sed 's|$|/|' ) && ( ( compgen -f $cur && compgen -d $cur ) | sort | uniq -u ) ));;
            # show nothing
            Xcheck|Xclean|Xcheck-unused)
                COMPREPLY=;;
            *)
                COMPREPLY=($( compgen -f $cur ));;
        esac
    fi
    len=${#COMPREPLY[@]}
    for ((i=0;i<len;i++))
    do
        str=${COMPREPLY[$i]}
        if [ "${str:(-1)}" != "/" ]
        then
            COMPREPLY[$i]="$str "
        fi
    done
}
complete -F _jumbo -o nospace jumbo

jumbo() {
    "$JUMBO_ROOT/bin/jumbo" "$@"
    if [[ "$1" == "install" || "$1" == "update" || "$1" == "remove" || "$1" == "local-install" ]]
    then
        hash -r
    fi
}

# vim:set ft=sh ts=4 sw=4 et:
