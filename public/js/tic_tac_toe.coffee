window.theApp = ->
  App = {}

  App.X_WINS = 1
  App.O_WINS = 2
  App.UNDECIDED = 3
  App.TIE = 4

  App.ScoreBoard = window.scoreBoard(App)
  App.AIMove = window.aiMove(App)

  App.GameBoard = Backbone.Model.extend({
    initialize: ->
      @moves = {}
      @aiMove = new App.AIMove

    result: ->
      scoreBoard = new App.ScoreBoard
      scoreBoard.result(@moves)

    recordMove: (location)->
      unless @moves[location] == undefined
        throw "Cell is already taken"

      @moves[location] = "x"

      if @hasGameEnded()
        @trigger('gameEnded', @scoreBoardResult)
        return

      ai_move = @makeMove()

      if @hasGameEnded()
        @trigger('gameEnded', @scoreBoardResult)

      ai_move

   hasGameEnded: ->
     @scoreBoardResult = @result()
     return false if @scoreBoardResult == App.UNDECIDED
     true

    makeMove: ->
      @aiMove.next(@moves)
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
      switch result
        when App.X_WINS then $("#won").show()
        when App.O_WINS then $("#lost").show()
        else $("#tie").show()
  })

  return App
