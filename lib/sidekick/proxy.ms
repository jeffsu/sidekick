export class Proxy {
  include $m.EventEmitter;

  private {
    var connect = require('connect');
    var http = require('http');
  }

  function initialize(host, port) {
    this.host = host;
    this.port = port;
  }

  function send(data) {
    var options = {
      method:  data.method,
      headers: data.headers,
      path:    data.path,
      port:    this.port,
      host:    this.host
    };

    var startTime = (new Date()).getTime();
    var preq = http.request(options, #(pres) {
      var body = [];
      var meta = {};
      pres.on('data', #{ body.push($1.toString())});
      pres.on('end',  #{ 
        meta.responseTime = (new Date()).getTime() - startTime;
        self.emit('response', pres.statusCode, body.join(''), pres.headers, meta) 
      });
    });

    if (data.method == 'GET' || data.method == 'DELETE') {
      preq.end();
    } else {
      if (data.body) preq.write(data.body);
      preq.end();
    }
  }
}

