
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

  function listen() {
    var app = this.app();
    app.listen.apply(app, arguments);
    return app;
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

  function writeToPool(poolName, data) {
    var pools  = this.pools;
    var counts = this.counts;

    if (!pools[poolName]) return;
    var pool = pools[poolName];

    if (!counts[poolName]) return;

    var json = JSON.stringify(data);
    for (var key in pool) pool[key].write(json + "\n");
  }

  function addToPool(req, res, poolName) {
    var pools  = this.pools;
    var counts = this.counts;
    if (!counts[poolName]) counts[poolName] = 0;
    if (!pools[poolName])  pools[poolName]  = {};

    var pool = pools[poolName];
    counts[poolName]++;

    var id = this.getId(pool);
    pool[id] = res;

    req.on('close', #{
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
