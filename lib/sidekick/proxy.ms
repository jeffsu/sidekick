var sidekick = require('./index');

export class Proxy {
  private {
    var connect = require('connect');
    var http = require('http');
  }

  function proxy(req, res) {
    var options = {
      method:  req.method,
      headers: req.headers,
      path:    req.url,
      port:    this.back.port,
      host:    this.back.host
    };

    var preq = http.request(options, #(pres) {
      res.writeHead(pres.statusCode, pres.headers);
      pres.on('data', #{ res.write($1) });
      pres.on('end',  #{ res.end() });
    });

    if (req.method == 'GET' || req.method == 'DELETE') {
      preq.end();
    } else {
      req.on('data', #{ preq.write($1) });
      req.on('end',  #{ preq.end() });
    }
  }

  function connect() {
    return #(req, res, next) {
      self.proxy(req, res);
    };
  }

  function listen(port, host) {
    if (this.front) {
      port = port || this.front.port;
      host = host || this.front.host;
    }

    var sk = sidekick.middleware();

    var app = connect.createServer();
    app.use(sk.connect());
    app.use(this.connect());
    sk.listen(this.sk.port, this.sk.host);

    app.listen(port, host);
  }

  function initialize(config) {
    this.config = config;
    if (config.front) {
      this.front  = {
        port: config.front.port,
        host: config.front.host
      };
    }

    this.back = {
      port: config.back.port,
      host: config.back.host
    };

    this.sk = {
      port: config.sk.port,
      host: config.sk.host
    };
  }
}

