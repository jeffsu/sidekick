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
      self.listener.handle(req, res, next);
    };
  }

  function parasiteApp() {
    if (this.app) return app;
    this.app = connect.createServer();
    app.use(#{ self.server.handle($1, $2, $3) });
    return app;
  }

  function listen(port) {
    this.parasiteApp().listen(port);
  }
}
