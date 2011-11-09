window.theApp = ->
  App = {}

  App.GameBoard = Backbone.Model.extend({
    initialize: ->
      @shots = []

    shots: ->
      @shots

    recordShot: (location)->
      @shots.push location
      console.log "you hit: #{location}"
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

      @board.recordShot(source.target.id)

      $(source.target).html("x")
      #console.log("you clicked: " + source.target.id)
  })

  return App
