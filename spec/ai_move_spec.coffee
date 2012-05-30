require "#{__dirname}/spec_helper.coffee"

#game = require "#{jsDirPath}/tic_tac_toe"
#scoreBoard = require "#{jsDirPath}/score_board"
#aiMove = require "#{jsDirPath}/ai_move"
#App = window.theApp()

describe "AIMove", ->
  beforeEach ->
    @app = window.theApp()
    @scoreBoard = new @app.ScoreBoard
    @gameBoard = new @app.GameBoard
    @aiMove = new @app.AIMove

  it "provides A_1 when there are no moves", ->
    @aiMove.next(@gameBoard.moves).should.equal("A_1")

  it "provides B_1 when A_1 is taken", ->
    @gameBoard.moves['A_1'] = 'x'
    @aiMove.next(@gameBoard.moves).should.equal("B_1")
