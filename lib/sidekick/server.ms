
export class Server {
  include $m.EventEmitter;

  private {
    var url = require('url');
  }

  function initialize() {
    this.pool   = { data: {} };
    this.counts = { data: 0 };
    this.setup();
  }

  function setup() {
    this.on('data', #(json) { self.writeToPool(json, 'data'); });
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
    if (req.url == '/data') {
      this.handleData(req, res); 
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
    if (self.counts.data > 0) {
      var data = {
        path:    req.url,
        headers: req.headers,
        method:  req.method
      };
      
      this.emit('data', JSON.stringify(data));
    }

    next();
  }

  function handleData(req, res, next) {
    this.addToPool(req, res, 'data');
  }

  function writeToPool(data, poolName) {
    var pool = this.pool[poolName];
    for (var key in pool) {
      pool[key].write(data + "\n");
    }
  }

  function addToPool(req, res, poolName) {
    var pool = this.pool[poolName];
    var id = this.getId(pool);
    pool[id] = res;
    this.counts[poolName]++;

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
