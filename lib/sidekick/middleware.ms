var Listener = require('./listener');
var Server  = require('./server');
var connect = require('connect');

export class Middleware {
  include $m.EventEmitter;

  function initialize() {
    this.listener = new Listener();
    this.server   = new Server(this.listener);
  }

  function connect() {
    return #(req, res, next) {
      if (self.listener.afterCount) self.listener.handleAfter(req, res);
      self.listener.handle(req, res);
      next();
    };
  }

  function data(data) {
    this.listener.emit('data', data);
  }

  function getApp() {
    if (!this.app) {
      this.app = connect.createServer();
      this.app.use(#{ 
        self.server.handle($1, $2, $3) 
      });
    }
    return this.app;
  }

  function listen(port, host) {
    this.getApp().listen(port, host);
  }
}
