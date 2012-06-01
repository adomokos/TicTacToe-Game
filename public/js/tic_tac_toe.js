(function() {

  if (typeof App === "undefined" || App === null) App = {};

  App.X_WINS = 1;

  App.O_WINS = 2;

  App.UNDECIDED = 3;

  App.TIE = 4;

  App.GameBoard = Backbone.Model.extend({
    initialize: function() {
      this.moves = {};
      return this.aiMove = new (require('./ai_move'));
    },
    result: function() {
      var scoreBoard;
      scoreBoard = new (require('./score_board'));
      return scoreBoard.result(this.moves);
    },
    recordMove: function(location) {
      var ai_move;
      if (this.moves[location] !== void 0) throw "Cell is already taken";
      this.moves[location] = "x";
      if (this.hasGameEnded()) {
        this.trigger('gameEnded', this.scoreBoardResult);
        return;
      }
      ai_move = this.makeMove();
      if (this.hasGameEnded()) this.trigger('gameEnded', this.scoreBoardResult);
      return ai_move;
    },
    hasGameEnded: function() {
      this.scoreBoardResult = this.result();
      if (this.scoreBoardResult === App.UNDECIDED) return false;
      return true;
    },
    makeMove: function() {
      return this.aiMove.next(this.moves);
    },
    clearMoves: function() {
      var properties, property, _i, _len, _results;
      properties = _.keys(this.moves);
      _results = [];
      for (_i = 0, _len = properties.length; _i < _len; _i++) {
        property = properties[_i];
        _results.push(delete this.moves[property]);
      }
      return _results;
    }
  });

  App.GameView = Backbone.View.extend({
    events: {
      'click #restart': 'onRestart',
      'click': 'clicked'
    },
    initialize: function() {
      this.board = new App.GameBoard;
      this.board.bind('gameEnded', _.bind(this.onGameEnded, this));
      this.disabled = false;
      return this.counts = {
        won: 0,
        lost: 0,
        tie: 0
      };
    },
    clicked: function(source) {
      var result;
      if (this.disabled) return false;
      if (!source.target.id.match(/A|B|C_1|2|3/)) return false;
      try {
        result = this.board.recordMove(source.target.id);
        $(source.target).text("x");
        return $("#" + result).text("o");
      } catch (error) {
        return console.log(error);
      }
    },
    onRestart: function(sender, eventArgs) {
      var _this = this;
      this.disabled = false;
      (function() {
        var columnId, i, j, _i, _len, _ref;
        _ref = ['A', 'B', 'C'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          i = _ref[_i];
          for (j = 1; j <= 3; j++) {
            columnId = "#" + i + "_" + j;
            $(columnId).text('');
          }
        }
        _this.board.clearMoves();
        $('#restart_container').hide();
        $('#won').hide();
        $('#lost').hide();
        return $('#tie').hide();
      })();
      return false;
    },
    onGameEnded: function(result) {
      this.disabled = true;
      $('#restart_container').show();
      switch (result) {
        case App.X_WINS:
          this.counts.won++;
          return this._updateUIWith('won');
        case App.O_WINS:
          this.counts.lost++;
          return this._updateUIWith('lost');
        default:
          this.counts.tie++;
          return this._updateUIWith('tie');
      }
    },
    _updateUIWith: function(what) {
      $("#" + what).show();
      return this.el.find("span[id='" + what + "_count']").text(this.counts[what]);
    },
    wonCount: function() {
      return this.counts['won'];
    },
    lostCount: function() {
      return this.counts['lost'];
    },
    tieCount: function() {
      return this.counts['tie'];
    }
  });

  module.exports = App;

}).call(this);
