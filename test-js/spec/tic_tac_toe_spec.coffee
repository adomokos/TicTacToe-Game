require "#{__dirname}/spec_helper.coffee"

game = require "#{jsDirPath}/tic_tac_toe"
scoreBoard = require "#{jsDirPath}/score_board"
aiMove = require "#{jsDirPath}/ai_move"

describe "GameView", ->
  beforeEach ->
    @theApp = window.theApp()
    @gameView = new @theApp.GameView

  it "has the #container as its el", ->
    (expect @gameView.el.selector).toEqual('#container')

  it "has events", ->
    (expect @gameView.events['click']).toEqual "clicked"

  it "initializes the GameBoard", ->
    (expect (@gameView.board instanceof @theApp.GameBoard)).toBeTruthy

  describe "when game ends", ->
    beforeEach ->
      @resultSpy = spyOn($.fn, 'show')

    describe "and X wins", ->
      it "shows the #won div", ->
        @gameView.onGameEnded(@theApp.X_WINS)
        (expect @resultSpy).toHaveBeenCalled()
        (expect @resultSpy.mostRecentCall.object.selector).toEqual('#won')

    describe "and O wins", ->
      it "shows the #lost div", ->
        @gameView.onGameEnded(@theApp.O_WINS)
        (expect @resultSpy).toHaveBeenCalled()
        (expect @resultSpy.mostRecentCall.object.selector).toEqual('#lost')

    describe "and the result is tie", ->
      it "shows the #tie div", ->
        @gameView.onGameEnded(@theApp.TIE)
        (expect @resultSpy).toHaveBeenCalled()
        (expect @resultSpy.mostRecentCall.object.selector).toEqual('#tie')

  describe "clicked", ->
    describe "when the click is outside of the board", ->
      it "does not recognize it", ->
        boardSpy = spyOn(@gameView.board, 'recordMove')
        source = {
          target: {
            id: 'XYZ'
          }
        }
        @gameView.clicked(source)
        (expect boardSpy).not.toHaveBeenCalled()

    describe "when the click was valid", ->
      it "recognizes it", ->
        boardSpy = spyOn(@gameView.board, 'recordMove').andReturn('B_1')
        fieldMarker = spyOn($.fn, 'html')
        source = {
          target: {
            id: 'A_1'
          }
        }

        @gameView.clicked(source)
        (expect boardSpy).toHaveBeenCalledWith('A_1')
        (expect fieldMarker).toHaveBeenCalledWith('o')
        (expect fieldMarker.calls.length).toEqual(2)
        (expect fieldMarker.calls[0].object['0'].id).toEqual('A_1')
        (expect fieldMarker.calls[0].args).toEqual(['x'])
        (expect fieldMarker.mostRecentCall.object.selector).toEqual('#B_1')

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
