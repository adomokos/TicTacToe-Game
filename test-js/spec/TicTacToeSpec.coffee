require "#{__dirname}/spec_helper.coffee"

game = require 'TicTacToe'

describe "GameView", ->
  it "has events", ->
    App = window.theApp()
    gameView = new App.GameView
    (expect gameView.events['click']).toEqual "clicked"

describe "GameBoard", ->
  beforeEach ->
    App = window.theApp()
    @gameBoard = new App.GameBoard

  it "takes a move", ->
    @gameBoard.recordMove("A_1")
    (expect @gameBoard.moves['A_1']).toEqual "x"

  it "records a second shot", ->
    @gameBoard.recordMove("A_1")
    @gameBoard.recordMove("3_1")
    (expect @gameBoard.moves['A_1']).toEqual "x"
    (expect @gameBoard.moves['3_1']).toEqual "x"

  it "ignores shot at the same slot", ->
    @gameBoard.recordMove("A_1")
    (expect => @gameBoard.recordMove("A_1")).toThrow("Cell is already taken")

  describe "the AI", ->
    it "computer makes the first move", ->
      @gameBoard.recordMove("A_1")
      (expect @gameBoard.moves['A_1']).toEqual "x"
      (expect @gameBoard.moves['A_2']).toEqual "o"

    it "computer makes its second move", ->
      result = @gameBoard.recordMove("A_1")
      (expect result).toEqual "A_2"
      result = @gameBoard.recordMove("2_2")
      (expect result).toEqual "A_3"
      (expect @gameBoard.moves['A_1']).toEqual "x"
      (expect @gameBoard.moves['A_2']).toEqual "o"
      (expect @gameBoard.moves['2_2']).toEqual "x"
      (expect @gameBoard.moves['A_3']).toEqual "o"
