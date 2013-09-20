shell-go
========

a shell script help you to go to anywhere

## Usage
```
# basic operations
go home               # go to home directory
go desktop            # go to desktop
go some_named_place   # go to some named place( named in config files)
go some_dir           # go some_dir rooted in the current directory or home_directory

# also provide mechanism to solve conflict
go @0                 # go to the match indexed with 0

# provide modules to support more operations
go db local     # open a db client linked to local db server
go add server=ssh username@192.168.0.37
go add 'video>/home/username/video'
```

## Install && Config

TODO

## Extend the basic operations

TODO

## Compatability

Tested environment
* bash 3.2.48, OS X 10.8.4 (mine)

(due to long-existing portability problems with shell scripts, for now, the script can only be used under the environment similar to mine)

## Developers

* [siyu.du](https://github.com/secretworry) dusiyh@gmail.com

## License

see the LICENSE

## Contribute

pull requests are welcome
