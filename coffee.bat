@set @junk=1 /* vim:set ft=javascript:
@cscript //nologo //e:jscript "%~dpn0.bat" %*
@goto :eof
*/

var FSO = WScript.CreateObject("Scripting.FileSystemObject");

function loadCoffee() {
  eval(FSO.OpenTextFile(
    FSO.BuildPath(FSO.GetFile(WScript.ScriptFullName).parentFolder, "coffee-script.js"), 1).ReadAll());
  return CoffeeScript;
}

function parseArguments() {
  var args = getArgs();
  var res = {
    args: [],
    options: {
      bare: false,
      compile: false,
      eval: false,
      help: args.length == 0,
      print: false,
      stdio: false
    }
  };
  var o = res.options;
  function setOption(opt) {
    switch(opt) {
      case "-b":
      case "--bare":
        o.bare = true;
      break;
      case "-c":
      case "--compile":
        o.compile = true;
      break;
      case "-e":
      case "--eval":
        o.eval = true;
      break;
      case "-h":
      case "--help":
        o.help = true;
      break;
      case "-p":
      case "--print":
        o.print = true;
      break;
      case "-s":
      case "--stdio":
        o.stdio = true;
      break;
    }
  }
  while (args.length != 0) {
    var arg = args.shift();
    if (arg.match(/^--/)) {
      setOption(arg);
    } else if (arg.match(/^-/)) {
      for (var i = 1; i < arg.length; i++) {
        setOption('-' + arg.charAt(i));
      }
    } else {
      res.args.push(arg);
    }
  }
  if (o.stdio) {
    res.args = [WScript.StdIn.ReadAll()];
    o.eval = true;
  }
  if (res.args.length == 0 && !o.eval) {
    o.help = true;
  }
  if (o.eval || o.stdio) {
    o.print = true;
  }
  return res;
}

function getArgs() {
  var args = [];
  for (var i = 0; i < WScript.Arguments.length; i++) {
    args.push(WScript.Arguments(i));
  }
  return args;
}

function usage() {
  WScript.Echo('');
  WScript.Echo("Usage: coffee [options] path/to/script.coffee");
  WScript.Echo('');
  WScript.Echo("  -c, --compile      compile to JavaScript and save as .js files");
  WScript.Echo("  -p, --print        print the compiled JavaScript to stdout");
  WScript.Echo("  -s, --stdio        listen for and compile scripts over stdio");
  WScript.Echo("  -e, --eval         compile a string from the command line");
  WScript.Echo("  -b, --bare         compile without the top-level function wrapper");
  WScript.Echo("  -h, --help         display this help message");

  WScript.Quit(0);
}

this.console = {
  log: function() {
    var args = [];
    for (var i = 0; i < arguments.length; i++) { args.push(arguments[i]); } 
	WScript.Echo(args.join(' '));
  }
}

function main() {
  var args = parseArguments();
  var o = args.options;

  if (o.help) {
    usage();
  }

  var CoffeeScript = loadCoffee();
  for (var i = 0; i < args.args.length; i++) {
    var arg = args.args[i];
    var src = o.eval ? arg : FSO.OpenTextFile(arg, 1).ReadAll();

    if (o.compile) {
      var compileOptions = {
        filename: o.eval ? undefined : arg,
        bare: o.bare
      };
      var compiled = CoffeeScript.compile(src, compileOptions);
      if (o.print) {
        WScript.Echo(compiled);
      } else {
        var file = arg.replace(/(\.\w+)?$/, ".js");
        FSO.OpenTextFile(file, 2, true).Write(compiled);
      }
    } else {
      CoffeeScript.run(src, o);
    }
  }
}

main();
