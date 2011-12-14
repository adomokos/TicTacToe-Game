(function() {
  window.scoreBoard = function(App) {
    var ScoreBoard;
    return ScoreBoard = (function() {
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
  };
}).call(this);
