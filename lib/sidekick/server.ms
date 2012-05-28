
export class Server {
  include $m.EventEmitter;

  private {
    var url = require('url');
    var IS_PUBLISH = true;
  }

  function initialize() {
    this.pool   = { requests: {} };
    this.counts = { requests: 0 };
    this.subscribers      = {};
    this.subscriberCounts = {};
    this.setup();
  }

  function publish(key, data) {
    this.writeToPool(key, data, IS_PUBLISH);
  }

  function setup() {
    this.on('request', #(data) { self.writeToPool('requests', data); });
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

    if (req.url == '/requests') {
      this.addToPool(req, res, 'requests'); 
    }

    else if (m = req.url.match(/^\/subscribe\/([\w-\.]+)/)) {
      this.addToPool(req, res, m[1], IS_PUBLISH);
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

  function writeToPool(data, poolName, isPublish) {
    var pool = isPublish ? this.subscribers[poolName] : this.pool[poolName];
    var json = JSON.stringify(data);
    for (var key in pool) {
      pool[key].write(json + "\n");
    }
  }

  function addToPool(req, res, poolName, isPublish) {
    var pool   = isPublish ? this.subscribers[poolName] : this.pool[poolName];
    var counts = isPublish ? this.subscriberCounts[poolName] : this.counts[poolName];
    if (!counts[poolName]) counts[poolName] = 0;
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
