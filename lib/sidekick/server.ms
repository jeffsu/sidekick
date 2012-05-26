
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
    this.on('request', #(data) { self.writeToPool({ type: 'request', data: data }, 'data'); });
    this.on('data', #(data) { self.writeToPool({ type: 'data', data: data }, 'data'); });
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
      
      var method = req.method;
      if (method == 'POST' || method == 'PUT') {
        var body = [];
        req.on('data', #{ body.push($1.toString()) });
        req.on('end', #{ 
          data.body = body.join('');
          self.emit('request', data); 
        });
      } else {
        this.emit('request', data);
      }
    }

    next();
  }

  function handleData(req, res, next) {
    this.addToPool(req, res, 'data');
  }

  function writeToPool(data, poolName) {
    var pool = this.pool[poolName];
    var json = JSON.stringify(data);
    for (var key in pool) {
      pool[key].write(json + "\n");
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
