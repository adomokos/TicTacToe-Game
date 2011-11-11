require "#{__dirname}/spec_helper.coffee"

game = require 'TicTacToe'

describe "GameView", ->
  it "has events", ->
    App = window.theApp()
    gameView = new App.GameView
    (expect gameView.events['click']).toEqual "clicked"

describe "GameBoard", ->
  App = window.theApp()

  beforeEach ->
    @gameBoard = new App.GameBoard

  it "takes a move", ->
    @gameBoard.recordMove("A_1")
    (expect @gameBoard.moves['A_1']).toEqual "x"

  it "records a second move", ->
    @gameBoard.recordMove("A_1")
    @gameBoard.recordMove("3_1")
    (expect @gameBoard.moves['A_1']).toEqual "x"
    (expect @gameBoard.moves['3_1']).toEqual "x"

  it "ignores move into the same slot", ->
    @gameBoard.recordMove("A_1")
    (expect => @gameBoard.recordMove("A_1")).toThrow("Cell is already taken") 

  describe "determining a winner", ->
    it "is a win if there are three x's like \\", ->
      @gameBoard.recordMove("A_1")
      @gameBoard.recordMove("B_2")
      @gameBoard.recordMove("C_3")
      (expect @gameBoard.result()).toEqual(App.X_WINS)

  describe "the AI moves", ->
    describe "the first move", ->
      context "when human plays A_1", ->
        it "plays A_2", -> 
          @gameBoard.recordMove("A_1")
          (expect @gameBoard.moves['A_1']).toEqual "x"
          (expect @gameBoard.moves['A_2']).toEqual "o"
      context "when the human plays A_2", ->
        it "plays A_1", ->
          @gameBoard.recordMove("A_2")
          (expect @gameBoard.moves['A_1']).toEqual "o"
          (expect @gameBoard.moves['A_2']).toEqual "x"

    it "the second move", ->
      result = @gameBoard.recordMove("A_1")
      (expect result).toEqual "A_2"
      result = @gameBoard.recordMove("2_2")
      (expect result).toEqual "A_3"
      (expect @gameBoard.moves['A_1']).toEqual "x"
      (expect @gameBoard.moves['A_2']).toEqual "o"
      (expect @gameBoard.moves['2_2']).toEqual "x"
      (expect @gameBoard.moves['A_3']).toEqual "o"
