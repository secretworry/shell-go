debug "go-add $@"
if [ "$#" -ge 1 ]; then
  if [ "$1" = "-h" -o "$1" = "help" ]; then
    put "Description"
    put "add names config to config/go-add.go file"
    put ""
    put "Usage: go add [name>some_where|name=some_command]"
    put ""
    put "Examples"
    put ""
    put "go add example>/go/to/example"
    put "go add example=sh a_example_command"
  fi
  echo "$@" >> $BASE_PATH/config/go-add.go
else
  warn "nothing to add"
fi
return 0
