
export class Server {
  include $m.EventEmitter;

  private {
    var url = require('url');
  }

  function initialize(listener) {
    this.listener = listener;
  }

  function handle(req, res, next) {
    var parsed = url.parse(req.url, true);
    if (parsed.pathname == '/tail') {
      this.tail(req, res, parsed);
    } 
    
    else if (parsed.pathname == '/tail.json') {
      this.tailJSON(req, res, parsed);
    }
    
    else {
      next();
      return;
    }
  }

  function tail(req, res, parsed) {
    res.writeHead(200, { 'Content-type': 'text/plain' });
    this.listener.attach(req, #{ res.write($1.url + "\n"); });
  }

  function tailJSON(req, res, parsed) {
    res.writeHead(200, { 'Content-type': 'application/json' });
    this.listener.attach(req, #{ res.write(JSON.stringify({ url: $1.url, headers: $1.headers }) + "\n"); });
  }

}
