(function() {
  window.theApp = function() {
    var App;
    App = {};
    App.X_WINS = 1;
    App.O_WINS = 2;
    App.UNDECIDED = 3;
    App.TIE = 4;
    App.ScoreBoard = window.scoreBoard(App);
    App.AIMove = window.aiMove(App);
    App.GameBoard = Backbone.Model.extend({
      initialize: function() {
        return this.moves = {};
      },
      result: function() {
        var scoreBoard;
        scoreBoard = new App.ScoreBoard;
        return scoreBoard.result(this.moves);
      },
      recordMove: function(location) {
        var ai_move;
        if (this.moves[location] !== void 0) {
          throw "Cell is already taken";
        }
        this.moves[location] = "x";
        if (this.hasGameEnded()) {
          this.trigger('gameEnded', this.scoreBoardResult);
          return;
        }
        ai_move = this.makeMove();
        if (this.hasGameEnded()) {
          this.trigger('gameEnded', this.scoreBoardResult);
        }
        return ai_move;
      },
      hasGameEnded: function() {
        this.scoreBoardResult = this.result();
        if (this.scoreBoardResult === App.UNDECIDED) {
          return false;
        }
        return true;
      },
      makeMove: function() {
        return this.tryCells(['A_1', 'B_1', 'C_1']);
      },
      tryCells: function(locations) {
        var i, locationToSet, _results;
        i = 0;
        _results = [];
        while (i <= locations.length - 1) {
          locationToSet = locations[i];
          i++;
          if (this.moves[locationToSet] === void 0) {
            this.moves[locationToSet] = "o";
            return locationToSet;
          }
        }
        return _results;
      }
    });
    App.GameView = Backbone.View.extend({
      el: $("#container"),
      events: {
        'click': 'clicked'
      },
      initialize: function() {
        this.board = new App.GameBoard;
        return this.board.bind('gameEnded', this.onGameEnded, this);
      },
      clicked: function(source) {
        var result;
        if (!source.target.id.match(/A|B|C_1|2|3/)) {
          source.preventDefault;
          return;
        }
        try {
          result = this.board.recordMove(source.target.id);
          $(source.target).html("x");
          return $("#" + result).html("o");
        } catch (error) {
          return console.log(error);
        }
      },
      onGameEnded: function(result) {
        if (result === App.X_WINS) {
          return $("#won").show();
        } else if (result === App.O_WINS) {
          return $("#lost").show();
        } else {
          return $("#tie").show();
        }
      }
    });
    return App;
  };
}).call(this);
