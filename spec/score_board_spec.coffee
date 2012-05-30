require "#{__dirname}/spec_helper.coffee"

#game = require "#{jsDirPath}/tic_tac_toe"
#scoreBoard = require "#{jsDirPath}/score_board"

describe "ScoreBoard", ->

  beforeEach ->
    @app = window.theApp()
    @scoreBoard = new @app.ScoreBoard
    @gameBoard = new @app.GameBoard

  it "reports UNDECIDED when no moves are on the board", ->
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.UNDECIDED

  it "reports UNDECIDED when I make my first move", ->
    @gameBoard.recordMove("A_3")
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.UNDECIDED

  it "reports X_WINS when x is set in second row", ->
    @gameBoard.moves['A_1'] = "x"
    @gameBoard.moves['B_1'] = "x"
    @gameBoard.moves['C_1'] = "x"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.X_WINS

  it "reports X_WINS when x is set in second row", ->
    @gameBoard.moves['A_2'] = "x"
    @gameBoard.moves['B_2'] = "x"
    @gameBoard.moves['C_2'] = "x"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.X_WINS

  it "reports X_WINS when x is set in third row", ->
    @gameBoard.moves['A_3'] = "x"
    @gameBoard.moves['B_3'] = "x"
    @gameBoard.moves['C_3'] = "x"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.X_WINS

  it "reports X_WINS when x is set in second column", ->
    @gameBoard.moves['B_1'] = "x"
    @gameBoard.moves['B_2'] = "x"
    @gameBoard.moves['B_3'] = "x"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.X_WINS

  it "reports X_WINS when x is set in third column", ->
    @gameBoard.moves['C_1'] = "x"
    @gameBoard.moves['C_2'] = "x"
    @gameBoard.moves['C_3'] = "x"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.X_WINS

  it "reports X_WINS when x is set in diagonal", ->
    @gameBoard.moves['A_1'] = "x"
    @gameBoard.moves['B_2'] = "x"
    @gameBoard.moves['C_3'] = "x"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.X_WINS

  it "reports O_WINS when x is set in diagonal", ->
    @gameBoard.moves['A_3'] = "o"
    @gameBoard.moves['B_2'] = "o"
    @gameBoard.moves['C_1'] = "o"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.O_WINS

  it "reports TIE when all cells are used and there is no winner", ->
    @gameBoard.moves['A_1'] = "x"
    @gameBoard.moves['B_1'] = "o"
    @gameBoard.moves['C_1'] = "x"
    @gameBoard.moves['A_2'] = "o"
    @gameBoard.moves['B_2'] = "x"
    @gameBoard.moves['C_2'] = "x"
    @gameBoard.moves['A_3'] = "o"
    @gameBoard.moves['B_3'] = "x"
    @gameBoard.moves['C_3'] = "o"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.TIE

  it "reports O_WINS when all cells are used and there is no winner", ->
    @gameBoard.moves['A_2'] = "x"
    @gameBoard.moves['A_1'] = "o"
    @gameBoard.moves['B_2'] = "x"
    @gameBoard.moves['B_1'] = "o"
    @gameBoard.moves['B_3'] = "x"
    @gameBoard.moves['C_1'] = "o"
    result = @scoreBoard.result(@gameBoard.moves)
    result.should.equal @app.O_WINS
