# CoffeeScript on JScript

## What is this?

This is a wrapper of CoffeeScript compiler works on JScript.
No need cygwin!

## What is CoffeeScript?

See http://jashkenas.github.com/coffee-script/ .

## Usage

    Usage: coffee [options] path/to/script.coffee

      -c, --compile      compile to JavaScript and save as .js files
      -o, --output       set the directory for compiled JavaScript
      -j, --join         concatenate the scripts before compiling
      -w, --watch        watch scripts for changes, and recompile
      -p, --print        print the compiled JavaScript to stdout
      -s, --stdio        listen for and compile scripts over stdio
      -e, --eval         compile a string from the command line
      -b, --bare         compile without the top-level function wrapper
      -t, --tokens       print the tokens that the lexer produces
      -v, --version      display CoffeeScript version
      -h, --help         display this help message

## Note

- The file "coffee-script.js" included in this repository is a part of CoffeeScript.
  You can get the latest version of this from the following.

  http://jashkenas.github.com/coffee-script/extras/coffee-script.js

- This script works on JScript. So, some functions and objects that can be used by node.js cannot be used.

- Some problems are known in the direct running(without --compile).
  - Can not know the point that the error occurred.
  - Can not treat the arguments of command line.

- If multibyte character is contained in the output with `-p`, it may break.
  - StdOut of JScript can not treat binary data.
  - If how you treat binary data is known, please let me know.
  - ...or, add an option to specify the output encoding?

## Information

    Version:    1.5.1
    Author:     thinca <thinca@gmail.com>
    Repository: https://github.com/thinca/coffee-script-on-jscript
    License:
        Creative Commons Attribution 3.0 Unported (CC BY 3.0)
        http://creativecommons.org/licenses/by/3.0/


## ChangeLog

1.5.1  2011-07-13

- Fixed the watching of directory.

1.5  2011-07-13

- Added --join option.
- Added --watch option.
- Fixed the error with an empty file.

1.4  2011-07-08

- Improved the handling of error.
- Fixed some behaviors.

1.3  2011-07-08

- Added --tokens option.
- Added --version option.

1.2  2011-07-07

- Added --output option.
- Fixed bug that can not compile.

1.1  2011-07-07

- Directory support.

1.0  2011-07-07

- Initial Version.
