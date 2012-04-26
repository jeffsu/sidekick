var Tailer = require('./tailer');

export class Profiler extends Tailer {
  function initialize(host, port) {
    this.$super(host, port);
    this.url = "/profile";
  }
}
