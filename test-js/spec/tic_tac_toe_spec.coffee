require "#{__dirname}/spec_helper.coffee"

game = require 'tic_tac_toe'
scoreBoard = require 'score_board'

describe "GameView", ->
  it "has events", ->
    App = window.theApp()
    gameView = new App.GameView
    (expect gameView.events['click']).toEqual "clicked"

describe "GameBoard", ->
  App = window.theApp()

  beforeEach ->
    @gameBoard = new App.GameBoard

  it "does not have moves when initialized", ->
    (expect _.keys(@gameBoard.moves).length).toEqual 0

  it "reports the result as UNDECIDED when initialized", ->
    (expect @gameBoard.result()).toEqual App.UNDECIDED

  it "takes a move", ->
    @gameBoard.recordMove("A_1")
    (expect @gameBoard.moves['A_1']).toEqual "x"

  it "records a second move", ->
    @gameBoard.recordMove("A_1")
    @gameBoard.recordMove("C_1")
    (expect @gameBoard.moves['A_1']).toEqual "x"
    (expect @gameBoard.moves['C_1']).toEqual "x"

  it "ignores move into the same slot", ->
    @gameBoard.recordMove("A_1")
    (expect => @gameBoard.recordMove("A_1")).toThrow("Cell is already taken")

  it "check's if the game has ended", ->
    result = @gameBoard.hasGameEnded()
    (expect result).toBeFalsy
    (expect @gameBoard.scoreBoardResult).toEqual App.UNDECIDED

  describe "determining a winner", ->
    it "is a win if there are three x's like \\", ->
      @gameBoard.recordMove("A_1")
      @gameBoard.recordMove("B_2")
      @gameBoard.recordMove("C_3")
      (expect @gameBoard.result()).toEqual(App.X_WINS)
      (expect _.keys(@gameBoard.moves).length).toEqual 5

  describe "the AI moves", ->
    describe "the first move", ->
      context "when human plays A_1", ->
        it "plays A_2", -> 
          @gameBoard.recordMove("A_1")
          (expect @gameBoard.moves['A_1']).toEqual "x"
          (expect @gameBoard.moves['B_1']).toEqual "o"

      context "when the human plays B_1", ->
        it "plays A_1", ->
          @gameBoard.recordMove("B_1")
          (expect @gameBoard.moves['A_1']).toEqual "o"
          (expect @gameBoard.moves['B_1']).toEqual "x"

    describe "the second move", ->
      context "with moves x A_1, o B_1, x B_2", ->
        it "plays C_1", ->
          result = @gameBoard.recordMove("A_1")
          (expect result).toEqual "B_1"
          result = @gameBoard.recordMove("B_2")
          (expect result).toEqual "C_1"
          (expect @gameBoard.moves['A_1']).toEqual "x"
          (expect @gameBoard.moves['B_1']).toEqual "o"
          (expect @gameBoard.moves['B_2']).toEqual "x"
          (expect @gameBoard.moves['C_1']).toEqual "o"

    describe "the third move", ->
      context "with moves x A_2, o A_1, x B_2, o A_2, x B_3, ", ->
        beforeEach ->
          @gameBoard.recordMove("A_2")
          @gameBoard.recordMove("B_2")
          @gameBoard.recordMove("B_3")

        it "plays C_1", ->
          (expect @gameBoard.moves['C_1']).toEqual "o"

        it "wins!", ->
          (expect _.keys(@gameBoard.moves).length).toEqual 6
          (expect @gameBoard.result()).toEqual(App.O_WINS)
