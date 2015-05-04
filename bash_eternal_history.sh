# Bash Eternal History
#
# Records all commands to a file for later searching.

export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'echo $$ $USER "$(history 1)" >> ~/.bash_eternal_history'

function ehistory() {
  if [ -z $1 ]; then
    cat ~/.bash_eternal_history
  else
    grep $1 ~/.bash_eternal_history
  fi
}

alias ?='ehistory'
