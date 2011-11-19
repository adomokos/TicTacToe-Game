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

    result: (gameBoard) ->

      check_for_winners = (x_or_o) ->
        found_matches = _.select(_.keys(gameBoard.moves), (item) ->
          return gameBoard.moves[item] == x_or_o
        )

        for permutation in permutations
          matches = _.intersect(found_matches, permutation)
          return true if matches.length == 3

        return false

      result = check_for_winners('x')
      return App.X_WINS if result
      result = check_for_winners('o')
      return App.O_WINS if result

      return App.TIE if _.keys(gameBoard.moves).length == 9

      App.UNDECIDED

  App.GameBoard = Backbone.Model.extend({
    initialize: ->
      @moves = {}
      @scoreBoard = new App.ScoreBoard

    moves: ->
      @moves

    result: ->
        @scoreBoard.result(this)

    recordMove: (location)->
      unless @moves[location] == undefined
        throw "Cell is already taken"

      @moves[location] = "x"
      this.makeMove()

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
      'click': 'clicked'
    }

    initialize: ->
      @board = new App.GameBoard

    clicked: (source, eventArg) ->
      return if source.target == this.el[0]

      try
        result = @board.recordMove(source.target.id)

        $(source.target).html("x")
        $("##{result}").html("o")
      catch error
        console.log error

      #console.log("you clicked: " + source.target.id)
  })

  return App
