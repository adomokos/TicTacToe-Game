var require = function (file, cwd) {
    var resolved = require.resolve(file, cwd || '/');
    var mod = require.modules[resolved];
    if (!mod) throw new Error(
        'Failed to resolve module ' + file + ', tried ' + resolved
    );
    var res = mod._cached ? mod._cached : mod();
    return res;
}

require.paths = [];
require.modules = {};
require.extensions = [".js",".coffee"];

require._core = {
    'assert': true,
    'events': true,
    'fs': true,
    'path': true,
    'vm': true
};

require.resolve = (function () {
    return function (x, cwd) {
        if (!cwd) cwd = '/';
        
        if (require._core[x]) return x;
        var path = require.modules.path();
        cwd = path.resolve('/', cwd);
        var y = cwd || '/';
        
        if (x.match(/^(?:\.\.?\/|\/)/)) {
            var m = loadAsFileSync(path.resolve(y, x))
                || loadAsDirectorySync(path.resolve(y, x));
            if (m) return m;
        }
        
        var n = loadNodeModulesSync(x, y);
        if (n) return n;
        
        throw new Error("Cannot find module '" + x + "'");
        
        function loadAsFileSync (x) {
            if (require.modules[x]) {
                return x;
            }
            
            for (var i = 0; i < require.extensions.length; i++) {
                var ext = require.extensions[i];
                if (require.modules[x + ext]) return x + ext;
            }
        }
        
        function loadAsDirectorySync (x) {
            x = x.replace(/\/+$/, '');
            var pkgfile = x + '/package.json';
            if (require.modules[pkgfile]) {
                var pkg = require.modules[pkgfile]();
                var b = pkg.browserify;
                if (typeof b === 'object' && b.main) {
                    var m = loadAsFileSync(path.resolve(x, b.main));
                    if (m) return m;
                }
                else if (typeof b === 'string') {
                    var m = loadAsFileSync(path.resolve(x, b));
                    if (m) return m;
                }
                else if (pkg.main) {
                    var m = loadAsFileSync(path.resolve(x, pkg.main));
                    if (m) return m;
                }
            }
            
            return loadAsFileSync(x + '/index');
        }
        
        function loadNodeModulesSync (x, start) {
            var dirs = nodeModulesPathsSync(start);
            for (var i = 0; i < dirs.length; i++) {
                var dir = dirs[i];
                var m = loadAsFileSync(dir + '/' + x);
                if (m) return m;
                var n = loadAsDirectorySync(dir + '/' + x);
                if (n) return n;
            }
            
            var m = loadAsFileSync(x);
            if (m) return m;
        }
        
        function nodeModulesPathsSync (start) {
            var parts;
            if (start === '/') parts = [ '' ];
            else parts = path.normalize(start).split('/');
            
            var dirs = [];
            for (var i = parts.length - 1; i >= 0; i--) {
                if (parts[i] === 'node_modules') continue;
                var dir = parts.slice(0, i + 1).join('/') + '/node_modules';
                dirs.push(dir);
            }
            
            return dirs;
        }
    };
})();

require.alias = function (from, to) {
    var path = require.modules.path();
    var res = null;
    try {
        res = require.resolve(from + '/package.json', '/');
    }
    catch (err) {
        res = require.resolve(from, '/');
    }
    var basedir = path.dirname(res);
    
    var keys = (Object.keys || function (obj) {
        var res = [];
        for (var key in obj) res.push(key)
        return res;
    })(require.modules);
    
    for (var i = 0; i < keys.length; i++) {
        var key = keys[i];
        if (key.slice(0, basedir.length + 1) === basedir + '/') {
            var f = key.slice(basedir.length);
            require.modules[to + f] = require.modules[basedir + f];
        }
        else if (key === basedir) {
            require.modules[to] = require.modules[basedir];
        }
    }
};

require.define = function (filename, fn) {
    var dirname = require._core[filename]
        ? ''
        : require.modules.path().dirname(filename)
    ;
    
    var require_ = function (file) {
        return require(file, dirname)
    };
    require_.resolve = function (name) {
        return require.resolve(name, dirname);
    };
    require_.modules = require.modules;
    require_.define = require.define;
    var module_ = { exports : {} };
    
    require.modules[filename] = function () {
        require.modules[filename]._cached = module_.exports;
        fn.call(
            module_.exports,
            require_,
            module_,
            module_.exports,
            dirname,
            filename
        );
        require.modules[filename]._cached = module_.exports;
        return module_.exports;
    };
};

if (typeof process === 'undefined') process = {};

if (!process.nextTick) process.nextTick = (function () {
    var queue = [];
    var canPost = typeof window !== 'undefined'
        && window.postMessage && window.addEventListener
    ;
    
    if (canPost) {
        window.addEventListener('message', function (ev) {
            if (ev.source === window && ev.data === 'browserify-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);
    }
    
    return function (fn) {
        if (canPost) {
            queue.push(fn);
            window.postMessage('browserify-tick', '*');
        }
        else setTimeout(fn, 0);
    };
})();

if (!process.title) process.title = 'browser';

if (!process.binding) process.binding = function (name) {
    if (name === 'evals') return require('vm')
    else throw new Error('No such module')
};

if (!process.cwd) process.cwd = function () { return '.' };

if (!process.env) process.env = {};
if (!process.argv) process.argv = [];

require.define("path", function (require, module, exports, __dirname, __filename) {
function filter (xs, fn) {
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (fn(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length; i >= 0; i--) {
    var last = parts[i];
    if (last == '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Regex to split a filename into [*, dir, basename, ext]
// posix version
var splitPathRe = /^(.+\/(?!$)|\/)?((?:.+?)?(\.[^.]*)?)$/;

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
var resolvedPath = '',
    resolvedAbsolute = false;

for (var i = arguments.length; i >= -1 && !resolvedAbsolute; i--) {
  var path = (i >= 0)
      ? arguments[i]
      : process.cwd();

  // Skip empty and invalid entries
  if (typeof path !== 'string' || !path) {
    continue;
  }

  resolvedPath = path + '/' + resolvedPath;
  resolvedAbsolute = path.charAt(0) === '/';
}

// At this point the path should be resolved to a full absolute path, but
// handle relative paths to be safe (might happen when process.cwd() fails)

// Normalize the path
resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
var isAbsolute = path.charAt(0) === '/',
    trailingSlash = path.slice(-1) === '/';

// Normalize the path
path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }
  
  return (isAbsolute ? '/' : '') + path;
};


// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    return p && typeof p === 'string';
  }).join('/'));
};


exports.dirname = function(path) {
  var dir = splitPathRe.exec(path)[1] || '';
  var isWindows = false;
  if (!dir) {
    // No dirname
    return '.';
  } else if (dir.length === 1 ||
      (isWindows && dir.length <= 3 && dir.charAt(1) === ':')) {
    // It is just a slash or a drive letter with a slash
    return dir;
  } else {
    // It is a full dirname, strip trailing slash
    return dir.substring(0, dir.length - 1);
  }
};


exports.basename = function(path, ext) {
  var f = splitPathRe.exec(path)[2] || '';
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPathRe.exec(path)[3] || '';
};

});

require.define("/ai_move.js", function (require, module, exports, __dirname, __filename) {
(function() {
  var AIMove;

  AIMove = (function() {

    function AIMove() {}

    AIMove.prototype.next = function(moves) {
      var locationToSet, row, _i, _j, _len, _len2, _ref;
      _ref = require('./score_board').prototype.PERMUTATIONS;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        for (_j = 0, _len2 = row.length; _j < _len2; _j++) {
          locationToSet = row[_j];
          if (moves[locationToSet] === void 0) {
            moves[locationToSet] = "o";
            return locationToSet;
          }
        }
      }
    };

    return AIMove;

  })();

  module.exports = AIMove;

}).call(this);

});

require.define("/tic_tac_toe.js", function (require, module, exports, __dirname, __filename) {
(function() {

  if (typeof App === "undefined" || App === null) App = {};

  App.X_WINS = 1;

  App.O_WINS = 2;

  App.UNDECIDED = 3;

  App.TIE = 4;

  App.GameBoard = Backbone.Model.extend({
    initialize: function() {
      this.moves = {};
      return this.aiMove = new (require('./ai_move'));
    },
    result: function() {
      var scoreBoard;
      scoreBoard = new (require('./score_board'));
      return scoreBoard.result(this.moves);
    },
    recordMove: function(location) {
      var ai_move;
      if (this.moves[location] !== void 0) throw "Cell is already taken";
      this.moves[location] = "x";
      if (this.hasGameEnded()) {
        this.trigger('gameEnded', this.scoreBoardResult);
        return;
      }
      ai_move = this.makeMove();
      if (this.hasGameEnded()) this.trigger('gameEnded', this.scoreBoardResult);
      return ai_move;
    },
    hasGameEnded: function() {
      this.scoreBoardResult = this.result();
      if (this.scoreBoardResult === App.UNDECIDED) return false;
      return true;
    },
    makeMove: function() {
      return this.aiMove.next(this.moves);
    },
    clearMoves: function() {
      var properties, property, _i, _len, _results;
      properties = _.keys(this.moves);
      _results = [];
      for (_i = 0, _len = properties.length; _i < _len; _i++) {
        property = properties[_i];
        _results.push(delete this.moves[property]);
      }
      return _results;
    }
  });

  App.GameView = Backbone.View.extend({
    events: {
      'click #restart': 'onRestart',
      'click': 'clicked'
    },
    initialize: function() {
      this.board = new App.GameBoard;
      this.board.bind('gameEnded', _.bind(this.onGameEnded, this));
      this.disabled = false;
      return this.counts = {
        won: 0,
        lost: 0,
        tie: 0
      };
    },
    clicked: function(source) {
      var result;
      if (this.disabled) return false;
      if (!source.target.id.match(/A|B|C_1|2|3/)) return false;
      try {
        result = this.board.recordMove(source.target.id);
        $(source.target).text("x");
        return $("#" + result).text("o");
      } catch (error) {
        return console.log(error);
      }
    },
    onRestart: function(sender, eventArgs) {
      var _this = this;
      this.disabled = false;
      (function() {
        var columnId, i, j, _i, _len, _ref;
        _ref = ['A', 'B', 'C'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          for (j = 1; j <= 3; j++) {
            columnId = "#" + i + "_" + j;
            $(columnId).text('');
          }
        }
        _this.board.clearMoves();
        $('#restart_container').hide();
        $('#won').hide();
        $('#lost').hide();
        return $('#tie').hide();
      })();
      return false;
    },
    onGameEnded: function(result) {
      this.disabled = true;
      $('#restart_container').show();
      switch (result) {
        case App.X_WINS:
          this.counts.won++;
          return this._updateUIWith('won');
        case App.O_WINS:
          this.counts.lost++;
          return this._updateUIWith('lost');
        default:
          this.counts.tie++;
          return this._updateUIWith('tie');
      }
    },
    _updateUIWith: function(what) {
      $("#" + what).show();
      return this.el.find("span[id='" + what + "_count']").text(this.counts[what]);
    },
    wonCount: function() {
      return this.counts['won'];
    },
    lostCount: function() {
      return this.counts['lost'];
    },
    tieCount: function() {
      return this.counts['tie'];
    }
  });

  module.exports = App;

}).call(this);

});

require.define("/score_board.js", function (require, module, exports, __dirname, __filename) {
(function() {
  var AIMove, App, ScoreBoard;

  AIMove = require('./ai_move');

  App = require("./tic_tac_toe");

  ScoreBoard = (function() {

    function ScoreBoard() {}

    ScoreBoard.prototype.PERMUTATIONS = [['A_1', 'B_1', 'C_1'], ['A_2', 'B_2', 'C_2'], ['A_3', 'B_3', 'C_3'], ['A_1', 'A_2', 'A_3'], ['B_1', 'B_2', 'B_3'], ['C_1', 'C_2', 'C_3'], ['A_1', 'B_2', 'C_3'], ['A_3', 'B_2', 'C_1']];

    ScoreBoard.prototype.result = function(moves) {
      var check_for_winners, result;
      check_for_winners = function(x_or_o) {
        var found_matches, matches, permutation, _i, _len, _ref;
        found_matches = _.select(_.keys(moves), function(item) {
          return moves[item] === x_or_o;
        });
        _ref = ScoreBoard.prototype.PERMUTATIONS;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          permutation = _ref[_i];
          matches = _.intersect(found_matches, permutation);
          if (matches.length === 3) return true;
        }
        return false;
      };
      result = check_for_winners('x');
      if (result) return App.X_WINS;
      result = check_for_winners('o');
      if (result) return App.O_WINS;
      if (_.keys(moves).length === 9) return App.TIE;
      return App.UNDECIDED;
    };

    return ScoreBoard;

  })();

  module.exports = ScoreBoard;

}).call(this);

});

require.define("/ai_move.js", function (require, module, exports, __dirname, __filename) {
    (function() {
  var AIMove;

  AIMove = (function() {

    function AIMove() {}

    AIMove.prototype.next = function(moves) {
      var locationToSet, row, _i, _j, _len, _len2, _ref;
      _ref = require('./score_board').prototype.PERMUTATIONS;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        for (_j = 0, _len2 = row.length; _j < _len2; _j++) {
          locationToSet = row[_j];
          if (moves[locationToSet] === void 0) {
            moves[locationToSet] = "o";
            return locationToSet;
          }
        }
      }
    };

    return AIMove;

  })();

  module.exports = AIMove;

}).call(this);

});
require("/ai_move.js");

require.define("/score_board.js", function (require, module, exports, __dirname, __filename) {
    (function() {
  var AIMove, App, ScoreBoard;

  AIMove = require('./ai_move');

  App = require("./tic_tac_toe");

  ScoreBoard = (function() {

    function ScoreBoard() {}

    ScoreBoard.prototype.PERMUTATIONS = [['A_1', 'B_1', 'C_1'], ['A_2', 'B_2', 'C_2'], ['A_3', 'B_3', 'C_3'], ['A_1', 'A_2', 'A_3'], ['B_1', 'B_2', 'B_3'], ['C_1', 'C_2', 'C_3'], ['A_1', 'B_2', 'C_3'], ['A_3', 'B_2', 'C_1']];

    ScoreBoard.prototype.result = function(moves) {
      var check_for_winners, result;
      check_for_winners = function(x_or_o) {
        var found_matches, matches, permutation, _i, _len, _ref;
        found_matches = _.select(_.keys(moves), function(item) {
          return moves[item] === x_or_o;
        });
        _ref = ScoreBoard.prototype.PERMUTATIONS;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          permutation = _ref[_i];
          matches = _.intersect(found_matches, permutation);
          if (matches.length === 3) return true;
        }
        return false;
      };
      result = check_for_winners('x');
      if (result) return App.X_WINS;
      result = check_for_winners('o');
      if (result) return App.O_WINS;
      if (_.keys(moves).length === 9) return App.TIE;
      return App.UNDECIDED;
    };

    return ScoreBoard;

  })();

  module.exports = ScoreBoard;

}).call(this);

});
require("/score_board.js");

require.define("/tic_tac_toe.js", function (require, module, exports, __dirname, __filename) {
    (function() {

  if (typeof App === "undefined" || App === null) App = {};

  App.X_WINS = 1;

  App.O_WINS = 2;

  App.UNDECIDED = 3;

  App.TIE = 4;

  App.GameBoard = Backbone.Model.extend({
    initialize: function() {
      this.moves = {};
      return this.aiMove = new (require('./ai_move'));
    },
    result: function() {
      var scoreBoard;
      scoreBoard = new (require('./score_board'));
      return scoreBoard.result(this.moves);
    },
    recordMove: function(location) {
      var ai_move;
      if (this.moves[location] !== void 0) throw "Cell is already taken";
      this.moves[location] = "x";
      if (this.hasGameEnded()) {
        this.trigger('gameEnded', this.scoreBoardResult);
        return;
      }
      ai_move = this.makeMove();
      if (this.hasGameEnded()) this.trigger('gameEnded', this.scoreBoardResult);
      return ai_move;
    },
    hasGameEnded: function() {
      this.scoreBoardResult = this.result();
      if (this.scoreBoardResult === App.UNDECIDED) return false;
      return true;
    },
    makeMove: function() {
      return this.aiMove.next(this.moves);
    },
    clearMoves: function() {
      var properties, property, _i, _len, _results;
      properties = _.keys(this.moves);
      _results = [];
      for (_i = 0, _len = properties.length; _i < _len; _i++) {
        property = properties[_i];
        _results.push(delete this.moves[property]);
      }
      return _results;
    }
  });

  App.GameView = Backbone.View.extend({
    events: {
      'click #restart': 'onRestart',
      'click': 'clicked'
    },
    initialize: function() {
      this.board = new App.GameBoard;
      this.board.bind('gameEnded', _.bind(this.onGameEnded, this));
      this.disabled = false;
      return this.counts = {
        won: 0,
        lost: 0,
        tie: 0
      };
    },
    clicked: function(source) {
      var result;
      if (this.disabled) return false;
      if (!source.target.id.match(/A|B|C_1|2|3/)) return false;
      try {
        result = this.board.recordMove(source.target.id);
        $(source.target).text("x");
        return $("#" + result).text("o");
      } catch (error) {
        return console.log(error);
      }
    },
    onRestart: function(sender, eventArgs) {
      var _this = this;
      this.disabled = false;
      (function() {
        var columnId, i, j, _i, _len, _ref;
        _ref = ['A', 'B', 'C'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          for (j = 1; j <= 3; j++) {
            columnId = "#" + i + "_" + j;
            $(columnId).text('');
          }
        }
        _this.board.clearMoves();
        $('#restart_container').hide();
        $('#won').hide();
        $('#lost').hide();
        return $('#tie').hide();
      })();
      return false;
    },
    onGameEnded: function(result) {
      this.disabled = true;
      $('#restart_container').show();
      switch (result) {
        case App.X_WINS:
          this.counts.won++;
          return this._updateUIWith('won');
        case App.O_WINS:
          this.counts.lost++;
          return this._updateUIWith('lost');
        default:
          this.counts.tie++;
          return this._updateUIWith('tie');
      }
    },
    _updateUIWith: function(what) {
      $("#" + what).show();
      return this.el.find("span[id='" + what + "_count']").text(this.counts[what]);
    },
    wonCount: function() {
      return this.counts['won'];
    },
    lostCount: function() {
      return this.counts['lost'];
    },
    tieCount: function() {
      return this.counts['tie'];
    }
  });

  module.exports = App;

}).call(this);

});
require("/tic_tac_toe.js");
