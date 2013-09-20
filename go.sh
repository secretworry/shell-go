#! /bin/sh

##
# show usage
##
function usage {
  echo 1>&2 ""
  echo 1>&2 "Usage: go [options] [module] \"to anywhere\""
  echo 1>&2 ""
  echo 1>&2 "\t-d    - debug. output debug info"
  echo 1>&2 "\t-t    - dry run. just show the place you are leading to"
  echo 1>&2 "\t-p    - use pushd instead of cd"
  echo 1>&2 "\t-C    - case sensitive"
  echo 1>&2 ""
  echo 1>&2 "\t-h    - display this"
  echo 1>&2 ""
}

#--- lib --------------------------------------------------------------------------

##
# log functions
##
function put() {
  echo -e $@
}
function info() {
  echo -e "\033[0;32m[INFO]$@\033[0m"
}
function warn() {
  echo -e "\033[0;33m[WARN]$@\033[0m"
}
function debug() {
  if [ ! -z "$DEBUG" ]; then
    echo -e "\033[0;36m[DEBUG]$@\033[0m"
  fi
}
function error() {
  echo -e "\033[1;31m[ERROR]$@\033[0m"
}

function push_IFS() {
  index=${#OLD_IFS[@]}
  OLD_IFS[$index]="$IFS"
  IFS=$1
}

function pop_IFS() {
  index=$(( ${#OLD_IFS[@]} - 1))
  if [ "$index" -gt 0 ]; then
    IFS=${OLD_IFS[$index]}
    unset OLD_IFS[$index]
  fi
}


##
# setup default vairables
##
function defaults {
  CD=cd
  CASE_SENSITIVE=
  INDEXED_FILE=".indexed.go"
  DEBUG=
  TEST=
  MAX_DEPTH=3
  return 0
}

function init {
  BASE_PATH="$(cd "$(dirname $BASH_SOURCE)" >> /dev/null && pwd -P)"
  debug "BASE_PATH: $BASE_PATH"
  debug "PWD: $(pwd)"
}

##
# go_to a command
# @param 1, the command, which starts with '>' indicates a path, '=' indicates a shell command, default to a path
##
function go_to {
  debug "go_to: $@"
  if [ -z "$TEST" ]; then
    if [[ "$1" == \>* ]]; then
      debug "$CD ${@#>}"
      $CD ${1#>}
    elif [[ "$1" == \=* ]]; then
      eval ${@#=}
    else
      $CD $1
    fi
  else
    if [[ "$1" == \>* ]]; then
      info "going to: ${@#>}"
    elif [[ "$1" == \=* ]]; then
      info "executing: ${@#=}"
    else
      info "going to: $1"
    fi
  fi
}

function go_multi {
  debug "go_multi: $@($#)"
  target=$1
  shift

  put "More than one path is matched:\n"
  index=0
  indexed_file_path="$BASE_PATH/$INDEXED_FILE"
  if [ -e $indexed_file_path ]; then
    debug "indexed file exists, remove"
    rm -f $indexed_file_path
  fi
  push_IFS $'\n'
  for command in $@ ; do
    put " $index: $command"
    echo "$index${command#$target}" >> $indexed_file_path
    index=$((index+1))
  done
  pop_IFS
  put "use go @{index} to go to the specified index"
  return 1
}

function go_go_file {
  debug "go_go_file $@"
  target=$1
  shift
  #
  # a hack for handling spaces in results when building results array
  # TODO any better way?
  #
  results=$(grep -h "^$target[^a-z0-9]" $@)
  if [ "$?" -eq 0 ]; then 
    push_IFS $'\n'
    results=($results)
    pop_IFS
    debug "get ${#results[@]} matches: ${results[@]}"
    if [ ${#results[@]} -gt 1 ]; then
      go_multi $target "${results[@]}"
      return 0
    else
      go_to ${results[0]#$target}
      return 0
    fi
  fi
  return 1
}


#--- sub-routines --------------------------------------------------------------------------

##
# go to according to indexed command
##
function go_indexed {
  debug "go indexed $@"
  indexed_file_path=$BASE_PATH/$INDEXED_FILE
  if [ ! -e $BASE_PATH/$INDEXED_FILE ]; then
    info "no indexed commands"
    return 1
  fi
  if go_go_file $1 $indexed_file_path; then
    debug "removed indexed file"
    rm -f $indexed_file_path
  fi
  return 1
}

##
# use modules to search
##
function search_modules {
  if [ $# -ge 1 ]; then
    module=$1
    script_module_path=$BASE_PATH/modules/go-$module.sh
    debug "trying to find file module with $script_module_path"
    if [ -e $script_module_path ]; then
      debug "found module file go-$module"
      shift
      source $script_module_path "$@"
      return 0
    fi
  fi
  modules_path="$BASE_PATH/modules"
  for module in $(ls $modules_path); do
    module_path="$module_path/$module"
    debug "search module: $module"
    go_file="$BASE_PATH/modules/$module/go.sh"
    if [ -e $go_file -a -x $go_file ]; then
      if source $go_file $@; then
        debug "matched in module: $module"
        return 0
      else
        debug "cannot fina any match in module: '$module' for '$@'"
      fi
    else
      warn "cannot find go.sh (or it's not executable) for module: $module"
    fi
  done
  return 1
}

##
# search through go files specified in config/*.go
# param name the name to search
##
function search_go_files {
  debug "search go files $@"
  if go_go_file "$1" "$(ls $BASE_PATH/config/*.go)"; then
    return 0
  fi
  return 1
}

##
# search the file tree rooted in the specified directory
# param path the root path
# param name the name to search
##
function search_dir_recursively {
  debug "search recursively with '$1'"
  root_path=$1
  shift
  FIND_OPTS=""
  if [ -z "$CASE_SENSITIVE" ]; then
    FIND_OPTS="$FIND_OPTS -iname $@"
  else
    FIND_OPTS="$FIND_OPTS -name $@"
  fi
  if [ ! -z "$MAX_DEPTH" ]; then
    FIND_OPTS="$FIND_OPTS -maxdepth $MAX_DEPTH"
  fi
  results=$(eval "find $root_path $FIND_OPTS")
  push_IFS $'\n'
  results=($results)
  pop_IFS
  debug "get ${#results[@]} matches: ${results[@]}"
  if [ ${#results[@]} -gt 1 ]; then
    go_multi $target "${results[@]}"
    return 0
  elif [ ${#results[@]} -eq 1 ]; then
    go_to ${results[0]#$target}
    return 0
  fi
  return 1
}

##
# the last step of the scripts, output a sorry
##
function failed {
  error "sorry we can take you to anywhere but '$@', cuz we dont understand it"
  return 1
}

#--- main --------------------------------------------------------------------------

# Setup default variables
defaults

# Parse options
while [[ "X$1" == X-* ]]; do
  if [[ "X$1" == X-t* ]]; then
    TEST=1
    info "Dry run..."
    shift
  elif [[ "X$1" == X-d* ]]; then
    DEBUG=1
    debug "DEBUG on"
    shift
  elif [[ "X$1" == X-p* ]]; then
    CD=pushd
    debug "use pushd instead of cd"
    shift
  elif [[ "X$1" == X-C* ]]; then
    CASE_SENSITIVE=1
    debug "case sensitive"
    shift
  elif [[ "X$1" == X-h* ]]; then
    usage
    return 1
  fi
done

# Output usage if not arguments specified
if [ "$#" -eq 0 ]; then
  usage
  return 1
fi

# Initialize program
init

debug "go $@"
if [[ "$1" == @* ]]; then
  go_indexed ${1#@*}
  return $?
fi

##
# search through sub-routines with folloing sequence
# * modules
# * path files in config/*.go
# * current directory
# * home directory
##
search_modules $@ || search_go_files $@ || search_dir_recursively $(pwd) $@ || search_dir_recursively $HOME $@ || failed $@
