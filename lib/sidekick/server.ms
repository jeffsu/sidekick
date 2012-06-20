var nssocket = require('nssocket');
export class Server {
  include $m.EventEmitter;

  private {
    var url = require('url');
  }

  function initialize() {
    this.pools  = {};
    this.counts = {};
    this.clientCount = 0;
  }

  function publish(channel, data) {
    this.writeToPool(channel, data);
  }

  function listen(port, address) {
    var server = nssocket.createServer(#(socket) {
      socket.data(['subscribe'], #(channel) {
        console.log('subscribing', channel);
        self.clientCount++;
        self.addToPool(socket, channel); 
      });
    });
    server.listen(port, address);
    return server;
  }

  function connect() {
    return #(req, res, next) { self.handle(req, res, next) };
  }

  function handle(req, res, next) {
    if (self.hasSubscribers('sidekick.requests')) {
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

  function subscriberCount(poolName) {
    return this.counts[poolName] || 0;
  }


  function writeToPool(poolName, data) {
    if (!this.hasSubscribers(poolName)) return;  

    var pool = this.pools[poolName];
    if (!pool) return;

    for (var key in pool) pool[key].send([ 'message', poolName ], data);
  }

  function addToPool(socket, poolName) {
    var pools  = this.pools;
    var counts = this.counts;
    console.log('adding to pool:' + poolName);

    if (!counts[poolName]) counts[poolName] = 0;
    if (!pools[poolName])  pools[poolName]  = {};

    var pool = pools[poolName];
    counts[poolName]++;

    var id = this.getId(pool);
    pool[id] = socket;

    socket.on('close', #{
      self.clientCount--;
      delete pool[id];
      counts[poolName]--;
      console.log("Client Count (closing):" + self.clientCount);
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

/*
 * hack to allow for unnecessary json stringifying
nssocket.NsSocket.prototype.sendJSON = function(event, json, callback) {
  var data     = json;
  var dataType = typeof json,
      message;

  // rebinds
  if (typeof event === 'string') {
    event = event.split(this._delimiter);
  }
  
  if (dataType === 'undefined' || dataType === 'function') {
    callback = data;
    data = null;
  }

  // if we aren't connected/socketed, then error
  if (!this.socket || !this.connected) {
    return this.emit('error', new Error('NsSocket: sending on a bad socket'));
  }
  
  message = Buffer(event.concat(json) + '\n');

  if (this.socket.cleartext) {
    this.socket.cleartext.write(message, callback);
  }
  else {
    // now actually write to the socket
    this.socket.write(message, callback);
  }
};


 */
