indexed_file_path="$BASE_PATH/$INDEXED_FILE"
if [ -e $indexed_file_path ]; then 
  cat $indexed_file_path
else
  warn "cannot find indexed file"
fi
