export class Protocol {
  include $m.EventEmitter;

  function initialize(socket) {
    this.socket = socket;
    this._data  = [];
    socket.on('data', #(chunk) { self.data(chunk) });
  }

  function data(chunk) {
    chunk = chunk.toString();
    var chunks = chunk.split(/\n/);

    if (chunks.length == 0) return this._data.push(chunk);

    var usedData = false;
    while (chunks.length > 1) {
      var str;

      if (!usedData) {
        str = this._data.join('') + chunks.shift();
        usedData = true;
        this._data = [];
      } else {
        str = chunks.shift();
      }

      var match = str.match(/^(.*?):(.*)$/);
      this.emit('message', match[1], match[2]);
    }
  }

  function abort() {
    this.emit('close');
    this.socket.end();
  }

  function send(key, data) {
    this.socket.write(key + ':' + data + "\n");
  }

}
