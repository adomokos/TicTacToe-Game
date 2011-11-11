window.theApp = ->
  App = {}

  App.X_WINS = 1
  App.O_WINS = 2

  App.GameBoard = Backbone.Model.extend({
    initialize: ->
      @moves = {}

    moves: ->
      @moves

    result: ->
      if(this.moves['A_1'] == 'x')
        return App.X_WINS

      App.O_WINS

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
