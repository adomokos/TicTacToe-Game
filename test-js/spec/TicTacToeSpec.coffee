require "#{__dirname}/spec_helper.coffee"

game = require 'TicTacToe'

describe "GameView", ->
  it "has events", ->
    App = window.theApp()
    gameView = new App.GameView
    #console.log gameView.events
    (expect gameView.events['click']).toEqual "clicked"

describe "GameBoard", ->
  it "records shots", ->
    App = window.theApp()
    gameBoard = new App.GameBoard
    gameBoard.recordShot("1_1")
    (expect gameBoard.shots).toEqual = ["1_1"]
