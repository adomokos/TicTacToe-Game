(function() {
  var ScoreBoard;

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
      if (result) return exports.App.X_WINS;
      result = check_for_winners('o');
      if (result) return exports.App.O_WINS;
      if (_.keys(moves).length === 9) return exports.App.TIE;
      return exports.App.UNDECIDED;
    };

    return ScoreBoard;

  })();

  exports.ScoreBoard = ScoreBoard;

}).call(this);
