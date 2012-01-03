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

    clearMoves: ->
      properties = _.keys(@moves)
      for property in properties
        delete @moves[property]
  })

  App.GameView = Backbone.View.extend({
    el: $("#container")

    events: {
      'click #restart': 'onRestart',
      'click': 'clicked'
    }

    initialize: ->
      @board = new App.GameBoard
      @board.bind('gameEnded', _.bind(@onGameEnded, this))
      @disabled = false
      @counts = {
        won: 0,
        lost: 0,
        tie: 0
      }

    clicked: (source) ->
      return false if @disabled

      return false unless source.target.id.match /A|B|C_1|2|3/

      try
        result = @board.recordMove(source.target.id)

        $(source.target).text("x")
        $("##{result}").text("o")
      catch error
        console.log error

      #console.log("you clicked: " + source.target.id)

    onRestart: (sender, eventArgs) ->
      @disabled = false

      (=>
        for i in ['A', 'B', 'C']
          for j in [1..3]
            columnId = "##{i}_#{j}"
            $(columnId).text('')

        @board.clearMoves()

        $('#restart_container').hide()
        $('#won').hide()
        $('#lost').hide()
        $('#tie').hide()
      )()

      return false

    onGameEnded: (result) ->
      @disabled = true
      $('#restart_container').show()

      switch result
        when App.X_WINS
          @counts.won++
          @_updateUIWith('won')
        when App.O_WINS
          @counts.lost++
          @_updateUIWith('lost')
        else
          @counts.tie++
          @_updateUIWith('tie')

    _updateUIWith: (what)->
      $("##{what}").show()
      @el.find("span[id='#{what}_count']").text(@counts[what])

    wonCount: ->
      @counts['won']

    lostCount: ->
      @counts['lost']

    tieCount: ->
      @counts['tie']
  })

  return App
