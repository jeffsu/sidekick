export class Proxy {
  private {
    var connect = require('connect');
  }

  function connect(port, host) {
    

  }

  function initialize(port, host) {
    this.host = host;
    this.port = port;
    this.app = connect.createServer();
  }

}
