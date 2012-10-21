# Automatically tries to make a prompt that looks like the native one for the OS

default_has_help=1

default_help() {
    cat << 'EOF'

    Default - Looks similar to the default bash prompt on a system.
    Author: Frank Erens <frank@synthi.net>
    Depends: gitthemes (optional)
    Known conflicts: None

    Options: 
        DEFAULT_ENABLE_VCS_INFO         [0]
                Enables VCS info (type, branch) on the prompt if in a repo.
        DEFAULT_ENABLE_GIT_STATUS       [0]
                Shows git status (clean, dirty) on the prompt if in a git
                repo.
                Requires the gitthemes plugin.
            
    
EOF
}

if [[ -z $DEFAULT_ENABLE_VCS_INFO ]]; then
    DEFAULT_ENABLE_VCS_INFO=0
fi

if [[ -z $DEFAULT_ENABLE_GIT_STATUS ]]; then
    DEFAULT_ENABLE_GIT_STATUS=0
fi


if [[ $DEFAULT_ENABLE_VCS_INFO == 1 ]]; then
    setopt prompt_subst
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' actionformats \
        ' (%b %a) '
    zstyle ':vcs_info:*' formats       \
        ' (%b) '
    zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b:%r'

    zstyle ':vcs_info:*' enable git cvs svn

    function vcs_info_wrapper() {
        vcs_info
        if [ -n "$vcs_info_msg_0_" ]; then
            echo "${vcs_info_msg_0_}$del"
        fi
    }
else
    function vcs_info_wrapper() {

    }
fi

if [[ $DEFAULT_ENABLE_GIT_STATUS == 1 ]]; then
    loadplugin gitthemes
    ZSH_THEME_GIT_PROMPT_CLEAN=''
    ZSH_THEME_GIT_PROMPT_DIRTY='* '

    function default_git_status() {
        if [[ -n $(parse_git_branch) ]]; then
            parse_git_dirty
        fi
    }
else
    function default_git_status() {
    }
fi

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
    export PS1="$PS1%{$fg[green]%}"'$(vcs_info_wrapper)$(default_git_status)'
    export PS1="$PS1$nl%{$reset_color%}$usuf "
    ;;
Darwin)
    # Mac OS X
    export PS1="%m:%c %n"'$(vcs_info_wrapper)$(default_git_status)'"$usuf "
    ;;
Linux|*)
    distro=$(lsb_release -si)
    case $distro in
    Fedora)
        # Probably a crapload of other distros as well
        export PS1="[%n@%m %c]"'$(vcs_ifno_wrapper)'
        export PS1="$PS1"'$(default_git_status)'"$usuf "
        ;;
    Ubuntu|Debian|*)
        # Default to Debian-like shell.
        export PS1="%n@%m:%~"'$(vcs_info_wrapper)$(default_git_status)'"$usuf "
        ;;
    esac
    ;;
esac
