#! /bin/bash
BASE_DIR=$(dirname $0)
DEBUG=1

source $BASE_PATH/lib/logger.sh

function complete_modules() {
  modules=
  modules_path=$BASE_PATH/modules
  for file in $(ls $modules_path); do
    if [[ "$file" == go-* ]]; then
      module=${file#go-}
      module=${module%.sh}
      debug "found file module $module"
      modules="$modules $module"
    else
      debug "found module $module"
      modules="$modules $file"
      if [ -e $modules_path/$file/completion.sh ]; then
        debug "source completion scripts for $module"
        source $modules_path/$file/completion.sh
      fi
    fi
    debug "modules: $modules"
    complete -W "$modules" go
  done
}

function complete_go_files() {
  return 0
}

function complete_directories() {
  return 0
}

complete_modules
complete_go_files
complete_directories
