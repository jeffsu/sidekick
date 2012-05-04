var http = require('http');

public class Multi {
  function initialize() {
    this.clients = [];
  }

  function addClient(client) {
    this.clients.push(client); 
  }

  function multiplex(json) {
    var req = JSON.parse(json);
    foreach (var client in this.clients) {
      client.handle(req);
    }
  }

  function listen(host, port) {
    var req = http.request({ host: host, port: port, path: '/tail' });
    req.on('response', #(res) {
      res.on('data', #{ self.multiplex($1.toString()) });
    });
    req.end();
  }
}

public class Client {
  include $m.EventEmitter;

  function initialize(host, port) {
    this.host = host;
    this.port = port;
  }

  function handle(req) {
    var proxy = http.request({ 
      host: this.host, 
      port: this.port, 
      path: req.url,
      headers: req.headers
    });

    proxy.on('response', #(res) {
      self.emit('response', res);
      res.on('data', #{ self.emit('data', $1) });
      res.on('end', #{ self.emit('end', res) });
    });

    proxy.end();
  }
}

