export class Tailer {
  include $m.EventEmitter;

  private {
    var http = require('http');
  }

  function initialize(host, port) {
    this.host = host;
    this.port = port;
    this.url  = '/tail';
  }


  function start() {
    this.req = http.get({ path: this.url, host: this.host, port: this.port });

    this.req.on('response', function (resp) {
      resp.on('data', #(data){ self.emit('request', JSON.parse(data)) });
      resp.on('end',  #{ self.emit('end') });
    });
  }

  function stop() {
    if (this.req) req.abort();
  }
}
