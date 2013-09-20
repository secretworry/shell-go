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
