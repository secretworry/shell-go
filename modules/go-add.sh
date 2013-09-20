debug "go-add $@"
if [ "$#" -gt 1 ]; then
  echo "$@" >> $BASE_PATH/config/go-add.go
else
  warn "nothing to add"
fi
return 0
