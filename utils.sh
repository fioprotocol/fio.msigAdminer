#!/usr/bin/env bash

# May be called two ways
# if yes_or_no "echo if"; then echo "if"; else echo "else"; fi
# if [[ $(yes_or_no "if test") -eq 0 ]]; then echo "if"; else echo "else"; fi
function yes_or_no {
  while true; do
    read -p "$*? [y/n]: " yn
    case $yn in
      [Yy]*) return 0;;
      [Nn]*) echo "Skipping..."; return  1;;
      * ) echo Invalid response entered! Try again...;;
    esac
  done
}

# May be called two ways
# if exit_on "Yes"; then echo "exiting"; else echo "not exiting"; fi
# if [[ $(exit_on "Yes") -eq 0 ]]; then echo "exiting"; else echo "not exiting"; fi
function exit_on {
  while true; do
    read -p "$*? [y/n]: " yn
    case $yn in
      [Yy]*) exit 0;;
      [Nn]*) echo "Continuing..."; return 0;;
      * ) echo Invalid response entered! Try again...;;
    esac
  done
}

function wait_on {
        echo "Press any key to continue"
        while [ true ]; do
                read -t 3 -n 1
                if [[ $? = 0 ]]; then
                        break;
                fi
        done
}

joinByChar() {
  local IFS="$1"
  shift
  echo "$*"
}

joinByString() {
  local separator="$1"
  shift
  local first="$1"
  shift
  printf "%s" "$first" "${@/#/$separator}"
}

