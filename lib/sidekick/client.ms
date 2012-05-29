var Proxy = require('./proxy');

export class Client {
  include $m.EventEmitter;
  private {
    var http = require('http');
  }

  function initialize(host, port) {
    this.host = host;
    this.port = port;
    this.subscriptions = {};
    this.requests = [];
  }

  function listen(key) {
    var req = http.request({
      host:   this.host,
      port:   this.port,
      method: 'GET',
      path:   '/subscribe/' + key
    });

    req.on('response', #(res) {
      res.on('data', #{ 
        var json = JSON.parse($1.toString());
        self.publish(key, json);
      });
      res.on('end', #{ self.listen(key) });
    });
    req.end();
    this.requests.push(req);
  }

  function stop() {
    this.subscriptions = {};
    foreach (var req in this.requests) {
      try { req.abort(); } catch(e) { };
    }
    this.requests = [];
  }

  function subscribe(key, handler) {
    if (! this.subscriptions[key]) {
      this.subscriptions[key] = [];
      this.listen(key);
    }

    this.subscriptions[key].push(handler);
  }

  function publish(key, data) {
    var subscribers = null; 
    if (subscribers = this.subscriptions[key]) {
      foreach (var s in subscribers) {
        s(data);
      }
    }
  }

  function proxy(host, port) {
    if (!this.proxies) {
      this.proxies = [];
      this.subscribe('sidekick.requests', #(data) {
        foreach (var proxy in self.proxies) {
          proxy.send(data);
        }
      });
    } 

    var proxy = new Proxy(host, port);
    this.proxies.push(proxy);

    return proxy;
  }

}

