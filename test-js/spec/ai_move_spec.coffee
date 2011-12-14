require "#{__dirname}/spec_helper.coffee"

game = require 'tic_tac_toe'
scoreBoard = require 'score_board'
aiMove = require 'ai_move'

describe "AIMove", ->
  App = window.theApp()

  beforeEach ->
    @scoreBoard = new App.ScoreBoard
    @gameBoard = new App.GameBoard
    @aiMove = new App.AIMove

  it "provides A_1 when there are no moves", ->
    (expect @aiMove.next(@gameBoard.moves)).toEqual("A_1")
