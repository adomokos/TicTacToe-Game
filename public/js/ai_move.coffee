window.aiMove = (App)->
  class AIMove

    next: (moves)->
      for row in App.ScoreBoard::PERMUTATIONS
        for locationToSet in row
          if (moves[locationToSet] == undefined)
            moves[locationToSet] = "o"
            return locationToSet
