var Proxy = require('./proxy');

export class Client {
  include $m.EventEmitter;
  private {
    var http = require('http');
  }

  function initialize(host, port) {
    this.host = host;
    this.port = port;
    this.listen();
  }

  function subscribe(key, handler) {
    var req = http.request({
      host:   this.host,
      port:   this.port,
      method: 'GET',
      path:   '/subscribe/' + key
    });

    req.on('response', #(res) {
      res.on('data', #{ 
        var json = JSON.parse($1.toString());
        handler(json);
      });
      res.on('end', #{ self.emit('end', res) });
    });

    req.end();
  }

  function listen() {
    var req = http.request({
      host: this.host,
      port: this.port,
      method: 'GET',
      path: '/requests'
    });

    req.on('response', #(res) {
      res.on('data', #{ 
        var json = JSON.parse($1.toString());
        self.emit('request', json);
      });
      res.on('end', #{ self.emit('end', res) });
    });

    req.end();
  }

  function proxy(host, port) {
    if (!this.proxies) {
      this.proxies = [];
      this.on('request', #(data) {
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

