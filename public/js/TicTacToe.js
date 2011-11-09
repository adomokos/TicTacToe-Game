(function() {
  window.theApp = function() {
    var App;
    App = {};
    App.GameBoard = Backbone.Model.extend({
      initialize: function() {
        return this.shots = {};
      },
      shots: function() {
        return this.shots;
      },
      recordShot: function(location) {
        if (this.shots[location] !== void 0) {
          throw "Cell is already taken";
        }
        this.shots[location] = "x";
        return this.makeMove();
      },
      makeMove: function() {
        return this.tryCells(['1_2', '1_3']);
      },
      tryCells: function(locations) {
        var i, locationToSet, _results;
        i = 0;
        _results = [];
        while (i <= locations.length - 1) {
          locationToSet = locations[i];
          i++;
          if (this.shots[locationToSet] === void 0) {
            this.shots[locationToSet] = "o";
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
        return this.board = new App.GameBoard;
      },
      clicked: function(source, eventArg) {
        var result;
        if (source.target === this.el[0]) {
          return;
        }
        try {
          result = this.board.recordShot(source.target.id);
          $(source.target).html("x");
          return $("#" + result).html("o");
        } catch (error) {
          return console.log(error);
        }
      }
    });
    return App;
  };
}).call(this);
