DEFAULT_GO_FILE=$BASE_PATH/config/default.go

source $BASE_PATH/lib/logger.sh

if [ -e $DEFAULT_GO_FILE ]; then
  mv -f $DEFAULT_GO_FILE{,.bak}
fi

function add(){
  info "added: $@"
  echo "$@" >> $DEFAULT_GO_FILE
}

add "home>$HOME"

printf "add sub-directories of home?([y]/n)"
read agree
if [ -z "$agree" -o "$agree" = "y" ]; then
  for directory in $(ls $HOME) ; do
    name=$(echo $directory | tr '[:upper:]' '[:lower:]')
    add "$name>$HOME/$directory"
  done
else
  info "skipped adding sub-direectories of home"
fi
