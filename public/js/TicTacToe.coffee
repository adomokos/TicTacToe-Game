window.theApp = ->
  App = {}

  App.GameBoard = Backbone.Model.extend({
    initialize: ->
      @shots = {}

    shots: ->
      @shots

    recordShot: (location)->
      unless @shots[location] == undefined
        throw "Cell is already taken"

      @shots[location] = "x"
      this.makeMove()

    makeMove: ->
      this.tryCells(['1_2', '1_3'])

    tryCells: (locations) ->
      i = 0
      while i <= locations.length-1
        locationToSet = locations[i]
        i++
        if (@shots[locationToSet] == undefined)
          @shots[locationToSet] = "o"
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
        result = @board.recordShot(source.target.id)

        $(source.target).html("x")
        $("##{result}").html("o")
      catch error
        console.log error

      #console.log("you clicked: " + source.target.id)
  })

  return App
