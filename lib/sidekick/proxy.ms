export class Proxy {
  private {
    var http = require('http');
  }

  function initialize(options) {
    this.front = options.front;
    this.back  = options.back;
  }

}
