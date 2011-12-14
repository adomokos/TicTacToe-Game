window.theApp = ->
  App = {}

  App.X_WINS = 1
  App.O_WINS = 2
  App.UNDECIDED = 3
  App.TIE = 4

  class App.ScoreBoard
    permutations =
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

        for permutation in permutations
          matches = _.intersect(found_matches, permutation)
          return true if matches.length == 3

        return false

      result = check_for_winners('x')
      return App.X_WINS if result
      result = check_for_winners('o')
      return App.O_WINS if result

      return App.TIE if _.keys(moves).length == 9

      App.UNDECIDED

  App.GameBoard = Backbone.Model.extend({
    initialize: ->
      @moves = {}

    result: ->
      scoreBoard = new App.ScoreBoard
      scoreBoard.result(@moves)

    recordMove: (location)->
      unless @moves[location] == undefined
        throw "Cell is already taken"

      @moves[location] = "x"

      if @hasGameEnded()
        this.trigger('gameEnded', @scoreBoardResult)
        return

      ai_move = this.makeMove()

      if @hasGameEnded()
        this.trigger('gameEnded', @scoreBoardResult)

      ai_move

   hasGameEnded: ->
     @scoreBoardResult = @result()
     return false if @scoreBoardResult == App.UNDECIDED
     true

    makeMove: ->
      this.tryCells(['A_1', 'B_1', 'C_1'])

    tryCells: (locations) ->
      i = 0
      while i <= locations.length-1
        locationToSet = locations[i]
        i++
        if (@moves[locationToSet] == undefined)
          @moves[locationToSet] = "o"
          return locationToSet
  })

  App.GameView = Backbone.View.extend({
    el: $("#container")

    events: {
      'click': 'clicked',
    }

    initialize: ->
      @board = new App.GameBoard
      @board.bind('gameEnded', @onGameEnded, this)

    clicked: (source) ->
      unless source.target.id.match /A|B|C_1|2|3/
        source.preventDefault
        return

      try
        result = @board.recordMove(source.target.id)

        $(source.target).html("x")
        $("##{result}").html("o")
      catch error
        console.log error

      #console.log("you clicked: " + source.target.id)

    onGameEnded: (result) ->
      if result == App.X_WINS
        $("#won").show()
      else if result == App.O_WINS
        $("#lost").show()
      else
        $("#tie").show()
  })

  return App
