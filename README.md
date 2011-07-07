# CoffeeScript on JScript

## What is this?

This is a wrapper of CoffeeScript compiler works on JScript.
No need cygwin!

## What is CoffeeScript?

See http://jashkenas.github.com/coffee-script/ .

## Usage

    Usage: coffee [options] path/to/script.coffee

      -c, --compile      compile to JavaScript and save as .js files
      -p, --print        print the compiled JavaScript to stdout
      -s, --stdio        listen for and compile scripts over stdio
      -e, --eval         compile a string from the command line
      -b, --bare         compile without the top-level function wrapper
      -h, --help         display this help message

## Note

- The file "coffee-script.js" included in this repository is a part of CoffeeScript.
  You can get the latest version of this from the following.

  https://github.com/jashkenas/coffee-script/blob/master/extras/coffee-script.js

- This script works on JScript. So, some functions and objects that can be used by node.js cannot be used.

## Latest version

https://github.com/thinca/coffee-script-on-jscript

## TODO

- Error handling.
- --output option.
- --join option.
- --watch option.

## License

    Creative Commons Attribution 3.0 Unported (CC BY 3.0)
    http://creativecommons.org/licenses/by/3.0/deed

## Version

1.1

## ChangeLog

1.1  2011-07-07

- Directory support.

1.0  2011-07-07

- Initial Version.
