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
    this.subscribed = {};
    this.listen();
  }

  function listen() {
    if (!this.p) {
      this.shouldListen = true;
      this.subscribed   = {};

      var socket = net.createConnection(this.port, this.host)
      socket.on('error', #{ 
        self.emit('error', $1) 
      });

      this.socket = socket;

      socket.on('close', #{ 
        self.p = null; 
        self.emit('close');
        if (self.shouldListen) setTimeout(#{ self.listen() }, 3000);
      });

      socket.on('connect', #{ 
        self.emit('connect'); 
        self.p = new Protocol(socket);
        self.p.on('message', #(k, message) {
          self.publish(k, message);
        });
        self.resubscribe();
      });
    }
  }

  function resubscribe() {
    for (var channel in this.subscriptions) {
      if (this.subscriptions[channel].length > 0) { 
        if (!this.subscribed[channel]) {
          this.subscribed[channel] = true;
          this.p.send('subscribe', this.p.escapeData(channel));
        }
      }
    }
  }

  function end() {
    this.shouldListen  = false;
    this.subscribed    = {};
    this.subscriptions = {};
    try { this.p.abort(); } catch(e) { };
  }

  function subscribe(channel, handler) {
    if (! this.subscriptions[channel]) {
      this.subscriptions[channel] = [];
      this.listen();
      this.resubscribe();
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

