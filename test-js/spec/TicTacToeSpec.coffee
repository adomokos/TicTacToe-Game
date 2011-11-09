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

  it "records a shot", ->
    @gameBoard.recordShot("1_1")
    (expect @gameBoard.shots['1_1']).toEqual "x"

  it "records a second shot", ->
    @gameBoard.recordShot("1_1")
    @gameBoard.recordShot("3_1")
    (expect @gameBoard.shots['1_1']).toEqual "x"
    (expect @gameBoard.shots['3_1']).toEqual "x"

  it "ignores shot at the same slot", ->
    @gameBoard.recordShot("1_1")
    (expect => @gameBoard.recordShot("1_1")).toThrow("Cell is already taken")

  describe "the computer enters into the game", ->
    it "computer makes the first move", ->
      @gameBoard.recordShot("1_1")
      (expect @gameBoard.shots['1_1']).toEqual "x"
      (expect @gameBoard.shots['1_2']).toEqual "o"

    it "computer makes its second move", ->
      result = @gameBoard.recordShot("1_1")
      (expect result).toEqual "1_2"
      result = @gameBoard.recordShot("2_2")
      (expect result).toEqual "1_3"
      (expect @gameBoard.shots['1_1']).toEqual "x"
      (expect @gameBoard.shots['1_2']).toEqual "o"
      (expect @gameBoard.shots['2_2']).toEqual "x"
      (expect @gameBoard.shots['1_3']).toEqual "o"
