(function() {
  window.theApp = function() {
    var App;
    App = {};
    App.X_WINS = 1;
    App.O_WINS = 2;
    App.UNDECIDED = 3;
    App.ScoreBoard = (function() {
      var permutations;
      function ScoreBoard() {}
      permutations = [['A_1', 'B_1', 'C_1'], ['A_2', 'B_2', 'C_2'], ['A_3', 'B_3', 'C_3'], ['A_1', 'A_2', 'A_3'], ['B_1', 'B_2', 'B_3'], ['C_1', 'C_2', 'C_3'], ['A_1', 'B_2', 'C_3'], ['A_3', 'B_2', 'C_1']];
      ScoreBoard.prototype.result = function(gameBoard) {
        var check_for_winners, result;
        check_for_winners = function(x_or_y) {
          var permutation, _i, _len;
          for (_i = 0, _len = permutations.length; _i < _len; _i++) {
            permutation = permutations[_i];
            if (gameBoard.moves[permutation[0]] === x_or_y && gameBoard.moves[permutation[1]] === x_or_y && gameBoard.moves[permutation[2]] === x_or_y) {
              return App.X_WINS;
            }
          }
        };
        result = check_for_winners('x');
        if (result != null) {
          return result;
        }
        result = check_for_winners('o');
        if (result != null) {
          return result;
        }
        return App.UNDECIDED;
      };
      return ScoreBoard;
    })();
    App.GameBoard = Backbone.Model.extend({
      initialize: function() {
        this.moves = {};
        return this.scoreBoard = new App.ScoreBoard;
      },
      moves: function() {
        return this.moves;
      },
      result: function() {
        return this.scoreBoard.result(this);
      },
      recordMove: function(location) {
        if (this.moves[location] !== void 0) {
          throw "Cell is already taken";
        }
        this.moves[location] = "x";
        return this.makeMove();
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
