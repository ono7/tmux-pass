#!/usr/bin/env bash

# ------------------------------------------------------------------------------

get_tmux_option() {
  local option=$1
  local default_value=$2
  local option_value; option_value=$(tmux show-option -gqv "$option")

  if [[ -z "$option_value" ]]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

display_message() {
  tmux display-message "tmux-pass: $1"
}

is_cmd_exists() {
  command -v "$1" &> /dev/null
  return $?
}

copy_to_clipboard() {
  if [[ "$(uname)" == "Darwin" ]] && is_cmd_exists "pbcopy"; then
    echo -n "$1" | pbcopy
  elif [[ -f '/etc/wsl.conf' ]] && is_cmd_exists "win32yank.exe"; then
    echo -n "$1" | win32yank.exe -i --crlf
  elif [[ "$(uname)" == "Linux" ]] && is_cmd_exists "tmux"; then
    echo -n "$1" | tmux load-buffer -
  elif [[ "$(uname)" == "Linux" ]] && is_cmd_exists "xclip"; then
    echo -n "$1" | xclip -i
  else
    return 1
  fi
}

clear_clipboard() {
  local -r SEC="$1"

  if [[ "$(uname)" == "Darwin" ]] && is_cmd_exists "pbcopy"; then
    tmux run-shell -b "sleep $SEC && echo '' | pbcopy"
  elif [[ -f '/etc/wsl.conf' ]] && is_cmd_exists "win32yank.exe"; then
    echo -n "" | win32yank.exe -i --crlf
  elif [[ "$(uname)" == "Linux" ]] && is_cmd_exists "xsel"; then
    tmux run-shell -b "sleep $SEC && xsel -c -b"
  elif [[ "$(uname)" == "Linux" ]] && is_cmd_exists "xclip"; then
    tmux run-shell -b "sleep $SEC && echo '' | xclip -i"
  else
    return 1
  fi
}
