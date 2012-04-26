export class Listener {
  include $m.EventEmitter;

  private {
    var crypto = require('crypto');
  }

  function initialize() {
    this.connectionCount = 0;
    this.listeners = {};
  }

  function increment() {
    this.connectionCount++;
  }
  
  function decrement() {
    this.connectionCount--;
  }

  function attach(req) {
    var id = this.randId();
    req.on('end', #{ delete self.listeners[id];  });
    this.listeners[id] = req;
  }

  function handle(req, res, next) {
    for (var key in this.listeners) {
      var listener = this.listeners[key];
      listener.suck(req, res);
    }

    next();
  }

  function randId() {
    var current_date = (new Date()).valueOf().toString();
    var random = Math.random().toString();
    return crypto.createHash('sha1').update(current_date + random).digest('hex');
  }
}
