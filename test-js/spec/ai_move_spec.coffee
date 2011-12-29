require "#{__dirname}/spec_helper.coffee"

game = require "#{jsDirPath}/tic_tac_toe"
scoreBoard = require "#{jsDirPath}/score_board"
aiMove = require "#{jsDirPath}/ai_move"

describe "AIMove", ->
  App = window.theApp()

  beforeEach ->
    @scoreBoard = new App.ScoreBoard
    @gameBoard = new App.GameBoard
    @aiMove = new App.AIMove

  it "provides A_1 when there are no moves", ->
    (expect @aiMove.next(@gameBoard.moves)).toEqual("A_1")

  it "provides B_1 when A_1 is taken", ->
    @gameBoard.moves['A_1'] = 'x'
    (expect @aiMove.next(@gameBoard.moves)).toEqual("B_1")
