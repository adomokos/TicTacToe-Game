#ScoreBoard = require './score_board'

class AIMove

  next: (moves)->
    for row in require('./score_board')::PERMUTATIONS
      for locationToSet in row
        if (moves[locationToSet] == undefined)
          moves[locationToSet] = "o"
          return locationToSet

module.exports = AIMove
