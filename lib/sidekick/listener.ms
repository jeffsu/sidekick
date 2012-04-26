export class Listener {
  include $m.EventEmitter;

  private {
    var crypto = require('crypto');
  }

  function initialize() {
    this.listeners = {};
    this.afters    = {};
    this.afterCount = 0;
  }

  function attach(req, cb) {
    var id = this.randId();
    this.emit('add', id);

    req.on('close', #{ 
      delete self.listeners[id];  
      self.emit('delete', id);
    });

    this.listeners[id] = cb;
  }

  function attachAfter(req, cb) {
    var id = this.randId();
    this.afterCount++;
    this.emit('add', id);

    req.on('close', #{ 
      delete self.listeners[id];  
      self.emit('delete', id);
      self.afterCount--;
    });

    this.afters[id] = cb;
  }

  function handle(req, res) {
    for (var key in this.listeners) {
      var listener = this.listeners[key];
      try {
        listener(req, res);
      } catch(e) {
        console.log(e); 
      }
    }
  }

  function handleAfters(req, res, meta) {
    for (var key in this.afters) {
      var listener = this.afters[key];
      try {
        listener(req, res, meta);
      } catch(e) {
        console.log(e); 
      }
    }
  }

  function handleAfter(req, res) {
    var start = new Date();
    var meta  = {};
    res.on('header', #{
      meta.responseTime = new Date() - start;
      self.handleAfters(req, res, meta);
    });
  }

  function randId() {
    var current_date = (new Date()).valueOf().toString();
    var random = Math.random().toString();
    return crypto.createHash('sha1').update(current_date + random).digest('hex');
  }
}
