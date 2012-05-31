require "#{__dirname}/spec_helper.coffee"

theApp = require "#{jsDirPath}/tic_tac_toe"
ScoreBoard = require "#{jsDirPath}/score_board"
AIMove = require "#{jsDirPath}/ai_move"

describe "AIMove", ->
  beforeEach ->
    theApp.App.ScoreBoard = ScoreBoard.ScoreBoard
    theApp.App.AIMove = AIMove.AIMove
    @scoreBoard = new theApp.App.ScoreBoard
    @gameBoard = new theApp.App.GameBoard
    @aiMove = new theApp.App.AIMove
    #console.log AIMove
    #@scoreBoard = new ScoreBoard
    #@gameBoard = new GameBoard
    #@aiMove = new AIMove

  it "provides A_1 when there are no moves", ->
    #console.log theApp.App.ScoreBoard::PERMUTATIONS
    @aiMove.next(@gameBoard.moves).should.equal("A_1")

  #it "provides B_1 when A_1 is taken", ->
    #@gameBoard.moves['A_1'] = 'x'
    #@aiMove.next(@gameBoard.moves).should.equal("B_1")
