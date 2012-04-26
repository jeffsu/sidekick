export class Server {
  include $m.EventEmitter;

  function initialize(listener) {
    this.listener = listener;
  }

  function handle(req, res, next) {
    var lambda = null;
    if (req.path == '/tail') {
      lambda = this.tail(res);
    } else {
      next();
      return;
    }

    req.suck = lambda;
    this.listener.attach(req);
  }

  function tail(res) {
    return #(req) { res.write(req.path + "\n"); };
  }

}
