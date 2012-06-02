var Proxy    = require('./proxy');
var Protocol = require('./protocol');

export class Client {
  include $m.EventEmitter;

  private {
    var net = require('net');
  }

  function initialize(host, port) {
    this.host = host;
    this.port = port;
    this.subscriptions = {};
  }

  function listen() {
    if (!this.p) {
      var socket = net.createConnection(this.port, this.host)
      socket.setKeepAlive(true);
      socket.on('close', #{ self.p = null; self.listen() })
      this.p = new Protocol(socket);
      this.p.on('message', #(k, message) {
        self.publish(k, message);
      });
    }
  }

  function stop() {
    try { this.p.abort(); } catch(e) { };
  }

  function subscribe(channel, handler) {
    if (! this.subscriptions[channel]) {
      this.subscriptions[channel] = [];
      this.listen();
      this.p.send('subscribe', this.p.escapeData(channel));
    }

    this.subscriptions[channel].push(handler);
  }

  function publish(channel, data) {
    var subscribers = null; 
    if (subscribers = this.subscriptions[channel]) {
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

