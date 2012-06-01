AIMove = require './ai_move'
App = require("./tic_tac_toe")

class ScoreBoard
  PERMUTATIONS:
    [['A_1', 'B_1', 'C_1'],
     ['A_2', 'B_2', 'C_2'],
     ['A_3', 'B_3', 'C_3'],

     ['A_1', 'A_2', 'A_3'],
     ['B_1', 'B_2', 'B_3'],
     ['C_1', 'C_2', 'C_3'],

     ['A_1', 'B_2', 'C_3'],
     ['A_3', 'B_2', 'C_1']]

  result: (moves) ->
    check_for_winners = (x_or_o) ->
      found_matches = _.select(_.keys(moves), (item) ->
        return moves[item] == x_or_o
      )

      for permutation in ScoreBoard::PERMUTATIONS
        matches = _.intersect(found_matches, permutation)
        return true if matches.length == 3

      return false

    result = check_for_winners('x')
    return App.X_WINS if result
    result = check_for_winners('o')
    return App.O_WINS if result

    return App.TIE if _.keys(moves).length == 9

    App.UNDECIDED

module.exports = ScoreBoard
