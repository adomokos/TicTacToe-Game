(function() {
  window.theApp = function() {
    var App;
    App = {};
    App.X_WINS = 1;
    App.O_WINS = 2;
    App.UNDECIDED = 3;
    App.TIE = 4;
    App.ScoreBoard = (function() {
      var permutations;
      function ScoreBoard() {}
      permutations = [['A_1', 'B_1', 'C_1'], ['A_2', 'B_2', 'C_2'], ['A_3', 'B_3', 'C_3'], ['A_1', 'A_2', 'A_3'], ['B_1', 'B_2', 'B_3'], ['C_1', 'C_2', 'C_3'], ['A_1', 'B_2', 'C_3'], ['A_3', 'B_2', 'C_1']];
      ScoreBoard.prototype.result = function(gameBoard) {
        var check_for_winners, result;
        check_for_winners = function(x_or_o) {
          var found_matches, matches, permutation, _i, _len;
          found_matches = _.select(_.keys(gameBoard.moves), function(item) {
            return gameBoard.moves[item] === x_or_o;
          });
          for (_i = 0, _len = permutations.length; _i < _len; _i++) {
            permutation = permutations[_i];
            matches = _.intersect(found_matches, permutation);
            if (matches.length === 3) {
              return true;
            }
          }
          return false;
        };
        result = check_for_winners('x');
        if (result) {
          return App.X_WINS;
        }
        result = check_for_winners('o');
        if (result) {
          return App.O_WINS;
        }
        if (_.keys(gameBoard.moves).length === 9) {
          return App.TIE;
        }
        return App.UNDECIDED;
      };
      return ScoreBoard;
    })();
    App.GameBoard = Backbone.Model.extend({
      initialize: function() {
        return this.moves = {};
      },
      moves: function() {
        return this.moves;
      },
      result: function() {
        var scoreBoard;
        scoreBoard = new App.ScoreBoard;
        return scoreBoard.result(this);
      },
      recordMove: function(location) {
        var ai_move, scoreBoardResult;
        if (this.moves[location] !== void 0) {
          throw "Cell is already taken";
        }
        this.moves[location] = "x";
        scoreBoardResult = this.result();
        if (scoreBoardResult === App.X_WINS) {
          return;
        }
        ai_move = this.makeMove();
        scoreBoardResult = this.result();
        return ai_move;
      },
      makeMove: function() {
        return this.tryCells(['A_1', 'B_1', 'C_1']);
      },
      tryCells: function(locations) {
        var i, locationToSet, _results;
        i = 0;
        _results = [];
        while (i <= locations.length - 1) {
          locationToSet = locations[i];
          i++;
          if (this.moves[locationToSet] === void 0) {
            this.moves[locationToSet] = "o";
            return locationToSet;
          }
        }
        return _results;
      }
    });
    App.GameView = Backbone.View.extend({
      el: $("#container"),
      events: {
        'click': 'clicked'
      },
      initialize: function() {
        return this.board = new App.GameBoard;
      },
      clicked: function(source, eventArg) {
        var result;
        if (source.target === this.el[0]) {
          return;
        }
        try {
          result = this.board.recordMove(source.target.id);
          $(source.target).html("x");
          return $("#" + result).html("o");
        } catch (error) {
          return console.log(error);
        }
      }
    });
    return App;
  };
}).call(this);
