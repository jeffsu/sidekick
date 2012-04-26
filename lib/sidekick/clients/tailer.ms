export class Tailer {
  include $m.EventEmitter;

  private {
    var http = require('http');
  }

  function initialize(host, port, isJson) {
    this.host = host;
    this.port = port;
  }

  function start() {
    this.req = http.get({ path: '/tail.json', host: this.host, port: this.port });

    this.req.on('response', function (resp) {
      resp.on('data', #(data){ self.emit('request', JSON.parse(data)) });
      resp.on('end',  #{ self.emit('end') });
    });
  }

  function stop() {
    if (this.req) req.abort();
  }
}
