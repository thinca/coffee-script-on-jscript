@set @junk=1 /* vim:set ft=javascript:
@cscript //nologo //e:jscript "%~dpn0.bat" %*
@goto :eof
*/

(function () {

var FSO = WScript.CreateObject("Scripting.FileSystemObject");

function loadCoffee() {
  eval(FSO.OpenTextFile(
    FSO.BuildPath(FSO.GetFile(WScript.ScriptFullName).parentFolder, "coffee-script.js"), 1).ReadAll());
  return CoffeeScript;
}

function readFile(file) {
  if (!FSO.FileExists(file) || FSO.getFile(file).Size == 0) {
    return "";
  }
  var stream = FSO.OpenTextFile(file, 1);
  try {
    return stream.ReadAll();
  } finally {
    stream.Close();
  }
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
      join: null,
      nodes: false,
      output: null,
      print: false,
      stdio: false,
      tokens: false,
      version: false
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
      case "-j":
      case "--join":
        o.join = args.shift();
      break;
      case "-n":
      case "--nodes":
        o.nodes = true;
      break;
      case "-o":
      case "--output":
        o.output = args.shift();
      break;
      case "-p":
      case "--print":
        o.print = true;
      break;
      case "-s":
      case "--stdio":
        o.stdio = true;
      break;
      case "-t":
      case "--tokens":
        o.tokens = true;
      break;
      case "-v":
      case "--version":
        o.version = true;
      break;
      default:
        throw new Error("unrecognized option: " + opt);
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
  if (res.args.length == 0 && !o.eval && !o.version) {
    o.help = true;
  }
  if (o.print || o.output) {
    o.compile = true;
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

function tokensToString(tokens) {
  var strings = [];
  for (var i = 0; i < tokens.length; i++) {
    var token = tokens[i];
    var tag = token[0];
    var value = token[1].toString().replace(/\n/, "\\n");
    strings.push("[" + token[0] + " " + value + "]");
  }
  return strings.join(' ');
};

function createFolders(folder) {
  folder = FSO.GetAbsolutePathName(folder);
  if (!FSO.FolderExists(folder)) {
    var parent = FSO.GetParentFolderName(folder);
    createFolders(parent);
    FSO.CreateFolder(folder);
  }
}

function usage() {
  WScript.Echo('');
  WScript.Echo("Usage: coffee [options] path/to/script.coffee");
  WScript.Echo('');
  WScript.Echo("  -c, --compile      compile to JavaScript and save as .js files");
  WScript.Echo("  -o, --output       set the directory for compiled JavaScript");
  WScript.Echo("  -j, --join         concatenate the scripts before compiling");
  WScript.Echo("  -p, --print        print the compiled JavaScript to stdout");
  WScript.Echo("  -s, --stdio        listen for and compile scripts over stdio");
  WScript.Echo("  -e, --eval         compile a string from the command line");
  WScript.Echo("  -b, --bare         compile without the top-level function wrapper");
  WScript.Echo("  -t, --tokens       print the tokens that the lexer produces");
  WScript.Echo("  -v, --version      display CoffeeScript version");
  WScript.Echo("  -h, --help         display this help message");

  WScript.Quit(0);
}

function main() {
  var args = parseArguments();
  var o = args.options;

  if (o.help) {
    usage();
  }

  var CoffeeScript = loadCoffee();

  if (o.version) {
    WScript.Echo("CoffeeScript version " + CoffeeScript.VERSION);
    return;
  }

  var contents = [];

  function processCode(src, file, base) {
    var compileOptions = {
      filename: file,
      bare: o.bare
    };
    if (o.join) {
      contents.push(src);
    } else if (o.tokens) {
      WScript.Echo(tokensToString(CoffeeScript.tokens(src)));
    } else if (o.nodes) {
      WScript.Echo(CoffeeScript.nodes(src).toString().replace(/^\s+|\s+$/g, ""));
    } else if (o.compile) {
      var compiled = CoffeeScript.compile(src, compileOptions);
      if (o.print) {
        WScript.Echo(compiled);
      } else if (file) {
        var js = file.replace(/(\.\w+)?$/, ".js");
        if (o.output) {
          var tail = base
            ? FSO.GetAbsolutePathName(js).substr(base.length)
            : FSO.GetFileName(js);
          js = FSO.BuildPath(o.output, tail);
        }
        createFolders(FSO.GetParentFolderName(js));
        FSO.OpenTextFile(js, 2, true).Write(compiled);
      }
    } else {
      CoffeeScript.run(src, compileOptions);
    }
  }

  function process(path, base) {
    if (FSO.FileExists(path)) {
      processCode(readFile(path), path, base);
    }
  }

  function traverse(path, func, base) {
    if (FSO.FolderExists(path)) {
      var folder = FSO.GetFolder(path);
      if (!base) {
        base = FSO.GetAbsolutePathName(folder.Path);
      }
      for (var e = new Enumerator(folder.Files); !e.atEnd(); e.moveNext()) {
        var file = e.item();
        if (FSO.GetExtensionName(file) === "coffee") {
          traverse(FSO.BuildPath(path, file.Name), func, base);
        }
      }
      for (var e = new Enumerator(folder.SubFolders); !e.atEnd(); e.moveNext()) {
        traverse(FSO.BuildPath(path, e.item().Name), func, base);
      }
    } else if (!FSO.FileExists(path)) {
      throw new Error("File not found: " + path);
    }
    func(path, base);
  }

  for (var i = 0; i < args.args.length; i++) {
    var arg = args.args[i];
    if (o.eval) {
      processCode(arg);
    } else {
      traverse(arg, process);
    }
  }

  if (o.join && contents.length != 0) {
    var file = o.join;
    o.join = false;
    processCode(contents.join("\n"), file);
  }
}

try {
  main();
} catch (e) {
  WScript.StdErr.WriteLine("Error: " + e.message);
  WScript.Quit(1);
}

}).call(this);
