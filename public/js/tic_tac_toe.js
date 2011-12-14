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
      ScoreBoard.prototype.result = function(moves) {
        var check_for_winners, result;
        check_for_winners = function(x_or_o) {
          var found_matches, matches, permutation, _i, _len;
          found_matches = _.select(_.keys(moves), function(item) {
            return moves[item] === x_or_o;
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
        if (_.keys(moves).length === 9) {
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
      result: function() {
        var scoreBoard;
        scoreBoard = new App.ScoreBoard;
        return scoreBoard.result(this.moves);
      },
      recordMove: function(location) {
        var ai_move;
        if (this.moves[location] !== void 0) {
          throw "Cell is already taken";
        }
        this.moves[location] = "x";
        if (this.hasGameEnded()) {
          this.trigger('gameEnded', this.scoreBoardResult);
          return;
        }
        ai_move = this.makeMove();
        if (this.hasGameEnded()) {
          this.trigger('gameEnded', this.scoreBoardResult);
        }
        return ai_move;
      },
      hasGameEnded: function() {
        this.scoreBoardResult = this.result();
        if (this.scoreBoardResult === App.UNDECIDED) {
          return false;
        }
        return true;
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
        this.board = new App.GameBoard;
        return this.board.bind('gameEnded', this.onGameEnded, this);
      },
      clicked: function(source) {
        var result;
        if (!source.target.id.match(/A|B|C_1|2|3/)) {
          source.preventDefault;
          return;
        }
        try {
          result = this.board.recordMove(source.target.id);
          $(source.target).html("x");
          return $("#" + result).html("o");
        } catch (error) {
          return console.log(error);
        }
      },
      onGameEnded: function(result) {
        if (result === App.X_WINS) {
          return $("#won").show();
        } else if (result === App.O_WINS) {
          return $("#lost").show();
        } else {
          return $("#tie").show();
        }
      }
    });
    return App;
  };
}).call(this);
