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
