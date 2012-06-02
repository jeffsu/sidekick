var net = require('net');
var Protocol = require('./protocol');

export class Server {
  include $m.EventEmitter;

  private {
    var url = require('url');
  }

  function initialize() {
    this.pools  = {};
    this.counts = {};
  }

  function publish(key, data) {
    this.writeToPool(key, data);
  }

  function app() {
    var connect = require('connect');
    var app = connect.createServer();
    app.use(this.connectSidekick());
    return app;
  }

  function listen(port, address) {
    var server = net.createServer(#(socket) {
      var p = new Protocol(socket);
      p.on('message', #(key, message) {
        if (key == 'subscribe') self.addToPool(p, message);
      });
    });
    server.listen(port, address);
    return server;
  }

  function connectSidekick() {
    return #(req, res, next) { self.handleSidekick(req, res, next) };
  }

  function handleSidekick(req, res, next) {
    var m = null;

    if (m = req.url.match(/^\/subscribe\/([^\/]+)/)) {
      this.addToPool(req, res, m[1]);
    }
    
    else {
      next();
      return;
    }
  }

  function connect() {
    return #(req, res, next) { self.handle(req, res, next) };
  }

  function handle(req, res, next) {
    if (self.counts['sidekick.requests'] > 0) {
      var data = {
        path:    req.url,
        headers: req.headers,
        method:  req.method
      };

      
      var method = req.method;
      if (method == 'POST' || method == 'PUT') {
        var body = [];
        req.on('data', #{ body.push($1.toString()) });
        req.on('end', #{ 
          data.body = body.join('');
          self.writeToPool('sidekick.requests', data);
        });
      } else {
        this.writeToPool('sidekick.requests', data);
      }
    }

    next();
  }

  function hasSubscribers(poolName) {
    return this.counts[poolName];
  }

  function writeToPool(poolName, data) {
    if (!this.hasSubscribers(poolName)) return;  

    var pool = this.pools[poolName];
    if (!pool) return;

    var json = JSON.stringify(data);
    for (var key in pool) pool[key].send(poolName, json);
  }

  function addToPool(p, poolName) {
    var pools  = this.pools;
    var counts = this.counts;
    if (!counts[poolName]) counts[poolName] = 0;
    if (!pools[poolName])  pools[poolName]  = {};

    var pool = pools[poolName];
    counts[poolName]++;

    var id = this.getId(pool);
    pool[id] = p;

    p.on('close', #{
      delete pool[id];
      self.counts[poolName]--;
    });
  }

  function getId(hash) {
    var time = (new Date).getTime();
    var id   = time;
    var inc  = 0;
    while (id in hash) id = time + '-' + inc++;
    return id;
  }

}
