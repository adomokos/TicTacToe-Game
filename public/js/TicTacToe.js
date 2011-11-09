(function() {
  window.theApp = function() {
    var App;
    App = {};
    App.GameBoard = Backbone.Model.extend({
      initialize: function() {
        return this.shots = [];
      },
      shots: function() {
        return this.shots;
      },
      recordShot: function(location) {
        this.shots.push(location);
        return console.log("you hit: " + location);
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
        if (source.target === this.el[0]) {
          return;
        }
        this.board.recordShot(source.target.id);
        return $(source.target).html("x");
      }
    });
    return App;
  };
}).call(this);
