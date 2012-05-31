class AIMove

  next: (moves)->
    for row in exports.ScoreBoard::PERMUTATIONS
      for locationToSet in row
        if (moves[locationToSet] == undefined)
          moves[locationToSet] = "o"
          return locationToSet

exports.AIMove = AIMove
