# Use powerline
USE_POWERLINE="true"

# === PATH ===
__path-prepend() {
  [[ -z "$1" ]] && return
  [[ "$PATH" =~ "$1" ]] && return

  export PATH="$1:$PATH"
}

__path-prepend "$HOME/.config/bin"


# === Removing 256color suffix ===
export TERM=${TERM:s/-256color/}

# === Autoload ===
# if [[ -o login ]]; then
#   if [[ -z "$SUDO_UID" ]]; then
#     python3 "$HOME/.config/tools/motd.py"
#   fi
# fi

python3 "$HOME/.config/tools/motd.py"


setopt prompt_subst

typeset -A fg
fg=(
  red     $'\033[31m'
  green   $'\033[32m'
  yellow  $'\033[33m'
  blue    $'\033[34m'
  cyan    $'\033[35m'
  electro $'\033[36m'
)
reset_color=$'\033[0m'

__utf-mode() {
  [[ "${LANG}" =~ "UTF|utf" ]]
}

if __utf-mode; then
  PROMPT_SEPARATOR=' » '
  RPROMPT_SEPARATOR=' « '
else
  PROMPT_SEPARATOR=' > '
  RPROMPT_SEPARATOR=' < '
fi

__in-git-repo() {
  git rev-parse --is-inside-work-tree > /dev/null 2>&1
}

__git-path() {
  if ! git diff-index --quiet HEAD -- > /dev/null 2>&1; then
    print -rn "%{$fg[red]%}"
  elif { git status --porcelain | command grep '^?? ' } > /dev/null 2>&1; then
    print -rn "%{$fg[yellow]%}"
  else
    print -rn "%{$fg[green]%}"
  fi

  local git_root="$(basename "$(git rev-parse --show-toplevel 2> /dev/null)")"
  local git_prefix="$(git rev-parse --show-prefix 2> /dev/null)"
  local git_path="$(print -rn "$git_root/$git_prefix" | sed 's/.$//g')"
  print -rn "$git_path"

  local git_branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
  case "$git_branch" in
    master) ;;
    HEAD) print -rn " %{$fg[red]%}(detached)" ;;
    *)    print -rn " %{$fg[electro]%}($git_branch)" ;;
  esac

  print -rn "${PROMPT_SEPARATOR}"
}

__prompt() {
  if __in-git-repo; then
    __git-path
  else
    case "${PWD}" in
      ${HOME}*) print -rn "%{$fg[blue]%}%~" ;;
      *) print -rn "%{$fg[red]%}%/" ;;
    esac
    print -rn "${PROMPT_SEPARATOR}"
  fi
}

PROMPT=' '
PROMPT+='$(__prompt)'
PROMPT+="%(1j.%{$fg[yellow]%}%j${PROMPT_SEPARATOR}.)"
PROMPT+="%(0?..%{$fg[red]%}%?${PROMPT_SEPARATOR})"
PROMPT+="%(!.%{$fg[yellow]%}!${PROMPT_SEPARATOR}.)"
PROMPT+="%{$reset_color%}"

PROMPT2="%{$fg[yellow]%}...${PROMPT_SEPARATOR}"

RPROMPT=''

if [[ "_${PREFIX}" =~ "/data/data/com.termux" ]]; then
  RPROMPT+="%{$fg[blue]%}${RPROMPT_SEPARATOR}termux"
else
  RPROMPT+="%{$fg[blue]%}${RPROMPT_SEPARATOR}%n"
  RPROMPT+="%{$fg[electro]%}${RPROMPT_SEPARATOR}%m"
fi

if [[ -n "$SSH_CONNECTION" ]]; then
  RPROMPT+="%{$fg[red]%}${RPROMPT_SEPARATOR}SSH"
fi

RPROMPT+="%{$reset_color%}"

# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
