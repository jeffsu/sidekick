var Proxy    = require('./proxy');
var nssocket = require('nssocket');

export class Client {
  include $m.EventEmitter;

  private {
    var net = require('net');
    var RETRY_INTERVAL = 2000;
  }

  function initialize(host, port) {
    this.host = host;
    this.port = port;
    this.socket = new nssocket.NsSocket({
      reconnect: true,
      retryInterval: RETRY_INTERVAL
    });

    this.socket.on('start', #{
      self.alreadySubscribed = {};
      self.emit('start');
    });

    this.socket.on('error', #{
      self.emit('error', $1);
    });

    this.socket.connect(this.port, this.host);
  }

  function end() {
    this.alreadySubscribed = {};
    this.socket.end();
  }

  function subscribe(channel, handler) {
    if (!this.alreadySubscribed[channel]) {
      this.alreadySubscribed[channel] = true;
      this.socket.send(['subscribe'], channel);
    }
    this.socket.data(['message', channel], handler);
  }

  function publish(channel, data) {
    this.socket.send(['message', channel], data);
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

