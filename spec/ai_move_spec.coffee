require "#{__dirname}/spec_helper.coffee"

App = require "#{jsDirPath}/tic_tac_toe"
AIMove = require "#{jsDirPath}/ai_move"

describe "AIMove", ->
  beforeEach ->
    @aiMove = new AIMove
    @gameBoard = new App.GameBoard

  it "provides A_1 when there are no moves", ->
    @aiMove.next(@gameBoard.moves).should.equal("A_1")

  it "provides B_1 when A_1 is taken", ->
    @gameBoard.moves['A_1'] = 'x'
    @aiMove.next(@gameBoard.moves).should.equal("B_1")
