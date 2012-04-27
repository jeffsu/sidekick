
export class Server {
  include $m.EventEmitter;

  private {
    var url = require('url');
  }

  function initialize(listener) {
    this.listener = listener;
  }

  function handle(req, res, next) {
    var parsed = url.parse(req.url);

    if (parsed.pathname == '/tail') {
      this.tailJSON(req, res, parsed);
    }

    else if (parsed.pathname == '/profile') {
      this.profileJSON(req, res, parsed);
    }
    
    else {
      next();
      return;
    }
  }

  function tailJSON(req, res, parsed) {
    res.writeHead(200, { 'Content-type': 'application/json' });
    this.listener.attach(req, #{ 
      res.write(JSON.stringify({ url: $1.url, headers: $1.headers }) + "\n"); 
    });
  }

  function profileJSON(req, res, parsed) {
    res.writeHead(200, { 'Content-type': 'application/json' });

    this.listener.attachAfter(req, #(sdReq, sdRes, meta) { 
      res.write(JSON.stringify({ 
        url: sdReq.url, 
        headers: sdReq.headers, 
        responseTime: meta.responseTime
      }) + "\n"); 
    });
  }

}
