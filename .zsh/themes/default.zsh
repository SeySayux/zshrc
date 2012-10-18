# Automatically tries to make a prompt that looks like the native one for the OS

default_has_help=1

default_help() {
    cat << 'EOF'

    Default - Looks similar to the default bash prompt on a system.
    Author: Frank Erens <frank@synthi.net>
    Depends: None
    Known conflicts: None

EOF
}

uname=$(uname -s)

nl='
'

if [ $UID -eq 0 ]; then
    usuf='#'
else
    usuf='$'
fi

winify() {
    if echo "$1" | grep -q "$HOME"; then
        echo "$1" | sed "s:$HOME:~:" | sed 's:/:\\:g'
    else
        cygpath -aw "$1"
    fi
}

case $uname in
Cygwin*|CYGWIN*)
    # Cygwin
    autoload colors;
    colors;
    setopt prompt_subst

    export PS1="$nl%{$fg[green]%}%n@%m %{$fg[yellow]%}"'$(winify $PWD)'
    export PS1="$PS1$nl%{$reset_color%}$usuf "
    ;;
Darwin)
    # Mac OS X
    export PS1="%m:%c %n$usuf "
    ;;
Linux|*)
    distro=$(lsb_release -si)
    case $distro in
    Fedora)
        # Probably a crapload of other distros as well
        export PS1="[%n@%m %c]$usuf "
        ;;
    Ubuntu|Debian|*)
        # Default to Debian-like shell.
        export PS1="%n@%m:%~$usuf "
        ;;
    esac
    ;;
esac
