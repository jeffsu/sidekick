export class Listener {
  include $m.EventEmitter;

  private {
    var crypto = require('crypto');
  }

  function initialize() {
    this.listeners = {};
  }

  function attach(req, cb) {
    var id = this.randId();
    req.on('close', #{ console.log('deleting' + id + req.url); delete self.listeners[id];  });
    this.listeners[id] = cb;
  }

  function handle(req, res, next) {
    for (var key in this.listeners) {
      var listener = this.listeners[key];
      listener(req, res);
    }

    next();
  }

  function randId() {
    var current_date = (new Date()).valueOf().toString();
    var random = Math.random().toString();
    return crypto.createHash('sha1').update(current_date + random).digest('hex');
  }
}
