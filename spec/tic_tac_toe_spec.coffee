require "#{__dirname}/spec_helper.coffee"

App = require "#{jsDirPath}/tic_tac_toe"
ScoreBoard = require "#{jsDirPath}/score_board"
AIMove = require "#{jsDirPath}/ai_move"

describe "GameView", ->
  beforeEach ->
    @gameView = new App.GameView({el: $("#container")})

  it "has the #container as its el", ->
    @gameView.el.selector.should.equal '#container'

  it "has events", ->
    @gameView.events['click'].should.equal 'clicked'
    @gameView.events['click #restart'].should.equal 'onRestart'

  it "initializes the GameBoard", ->
    (@gameView.board  instanceof App.GameBoard).should.be.true

  it "initializes the disabled field with false", ->
    @gameView.disabled.should.be.false

  it "initializes the counters with 0", ->
    @gameView.wonCount().should.equal 0
    @gameView.lostCount().should.equal 0
    @gameView.tieCount().should.equal 0

  describe "when game ends", ->
    beforeEach ->
      @updateUIWithSpy = sinon.spy(@gameView, '_updateUIWith')

    it "disables the Game", ->
      @gameView.onGameEnded(App.X_WINS)
      @gameView.disabled.should.be.true

    describe "and X wins", ->
      it "updates the UI with 'won'", ->
        @gameView.onGameEnded(App.X_WINS)
        @updateUIWithSpy.calledWith('won').should.be.true

      it "increments the wonCount by 1", ->
        @gameView.onGameEnded(App.X_WINS)
        @gameView.wonCount().should.equal 1

    describe "and O wins", ->
      it "shows the #lost div", ->
        @gameView.onGameEnded(App.O_WINS)
        @updateUIWithSpy.calledWith('lost').should.be.true

      it "increments the lostCount by 1", ->
        @gameView.onGameEnded(App.O_WINS)
        @gameView.lostCount().should.equal 1

    describe "and the result is tie", ->
      it "shows the #tie div", ->
        @gameView.onGameEnded(App.TIE)
        @updateUIWithSpy.calledWith('tie').should.be.true

      it "increments the tieCount by 1", ->
        @gameView.onGameEnded(App.TIE)
        @gameView.tieCount().should.equal 1

  describe "clicked", ->
    describe "when GameView is disabled", ->
      it "does not recognizes clicks", ->
        boardSpy = sinon.spy(@gameView.board, 'recordMove')
        @gameView.onGameEnded(App.O_WINS)
        @gameView.clicked({})
        boardSpy.called.should.be.false

    describe "when the click is outside of the board", ->
      it "does not recognize it", ->
        boardSpy = sinon.spy(@gameView.board, 'recordMove')
        source = {
          target: {
            id: 'XYZ'
          }
        }
        @gameView.clicked(source)
        boardSpy.called.should.be.false

    describe "when the click was valid", ->
      it "recognizes it", ->
        boardSpy = sinon.stub(@gameView.board, 'recordMove').returns('B_1')
        fieldMarker = sinon.spy($.fn, 'text')
        source = {
          target: {
            id: 'A_1'
          }
        }

        @gameView.clicked(source)
        # jsdom would be much better for this
        boardSpy.calledWith('A_1').should.be.true
        fieldMarker.calledWith('o').should.be.true
        fieldMarker.calledTwice.should.be.true

        fieldMarker.restore()

  describe "onRestart", ->
    it "sets the disabled field to true", ->
      @gameView.disabled = true
      @gameView.onRestart(null, null)
      @gameView.disabled.should.be.false

    it "calls the GameBoard's clearMoves() funciton", ->
      boardSpy = sinon.spy(@gameView.board, 'clearMoves')

      @gameView.onRestart(null, null)

      boardSpy.called.should.be.true

    it "clears the the cells", ->
      textSpy = sinon.spy($.fn, 'text')
      hideSpy = sinon.spy($.fn, 'hide')

      @gameView.onRestart(null, null)

      textSpy.called.should.be.true
      hideSpy.called.should.be.true

describe "GameBoard", ->

  beforeEach ->
    @gameBoard = new App.GameBoard

  it "clears the moves for restart", ->
    @gameBoard.recordMove("A_1")
    @gameBoard.recordMove("A_2")
    @gameBoard.clearMoves()

    _.keys(@gameBoard.moves).should.be.empty

  it "does not have moves when initialized", ->
    _.keys(@gameBoard.moves).should.be.empty

  it "reports the result as UNDECIDED when initialized", ->
    @gameBoard.result().should.equal App.UNDECIDED

  it "takes a move", ->
    @gameBoard.recordMove("A_1")
    @gameBoard.moves['A_1'].should.equal "x"

  it "records a second move", ->
    @gameBoard.recordMove("A_1")
    @gameBoard.recordMove("C_1")
    @gameBoard.moves['A_1'].should.equal "x"
    @gameBoard.moves['C_1'].should.equal "x"

  it "ignores move into the same slot"#, ->
    #@gameBoard.recordMove("A_1")
    #@gameBoard.recordMove("A_1").should.throw("Cell is already taken")

  it "check's if the game has ended", ->
    result = @gameBoard.hasGameEnded()
    result.should.be.false
    @gameBoard.scoreBoardResult.should.equal App.UNDECIDED

  describe "determining a winner", ->
    it "is a win if there are three x's like \\", ->
      @gameBoard.recordMove("A_1")
      @gameBoard.recordMove("B_2")
      @gameBoard.recordMove("C_3")
      @gameBoard.result().should.equal App.X_WINS
      _.keys(@gameBoard.moves).should.have.length 5

  describe "the AI moves", ->
    describe "the first move", ->
      context "when human plays A_1", ->
        it "plays A_2", -> 
          @gameBoard.recordMove("A_1")
          @gameBoard.moves['A_1'].should.equal "x"
          @gameBoard.moves['B_1'].should.equal "o"

      context "when the human plays B_1", ->
        it "plays A_1", ->
          @gameBoard.recordMove("B_1")
          @gameBoard.moves['A_1'].should.equal "o"
          @gameBoard.moves['B_1'].should.equal "x"

    describe "the second move", ->
      context "with moves x A_1, o B_1, x B_2", ->
        it "plays C_1", ->
          result = @gameBoard.recordMove("A_1")
          result.should.equal 'B_1'
          result = @gameBoard.recordMove("B_2")
          result.should.equal 'C_1'
          @gameBoard.moves['A_1'].should.equal "x"
          @gameBoard.moves['B_1'].should.equal "o"
          @gameBoard.moves['B_2'].should.equal "x"
          @gameBoard.moves['C_1'].should.equal "o"

    describe "the third move", ->
      context "with moves x A_2, o A_1, x B_2, o A_2, x B_3, ", ->
        beforeEach ->
          @gameBoard.recordMove("A_2")
          @gameBoard.recordMove("B_2")
          @gameBoard.recordMove("B_3")

        it "plays C_1", ->
          @gameBoard.moves['C_1'].should.equal "o"

        it "wins!", ->
          _.keys(@gameBoard.moves).should.have.length 6
          @gameBoard.result().should.equal App.O_WINS
