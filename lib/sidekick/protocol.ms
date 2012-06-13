var qs = require('querystring');

export class Protocol {
  include $m.EventEmitter;

  function initialize(socket) {
    this.socket = socket;
    this._data  = [];
    socket.on('data', #(chunk) { self.data(chunk) });
    socket.setKeepAlive(true);
    socket.setTimeout(0);
    socket.on('close', #{ console.log(self.hi); self.emit('close'); });
  }

  function data(chunk) {
    chunk = chunk.toString();
    var chunks = chunk.split(/\n/);

    if (chunks.length == 1) return this._data.push(chunk);

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

      var match = str.match(/^(.*?)&(.*)$/);
      try {
        this.emit('message', this.parseChannel(match[1]), match[2] == 'undefined' ? null : this.parseData(match[2]));
      } catch(e) {
        console.warn("Error receiving sidekick message: ", match[1], match[2]);
      }
    }
  }

  static function escapeData(data) {
    return JSON.stringify(data);
  }

  static function parseData(data) {
    return JSON.parse(data);
  }

  static function parseChannel(channel) {
    return qs.unescape(channel);
  }

  static function escapeChannel(channel) {
    return qs.escape(channel);
  }


  function escapeData(data) {
    return (data === null || data === undefined) ? "" : JSON.stringify(data);
  }

  function parseData(data) {
    return JSON.parse(data);
  }

  function parseChannel(channel) {
    return qs.unescape(channel);
  }

  function escapeChannel(channel) {
    return qs.escape(channel);
  }

  function abort(bypassSocket) {
    this.socket.end();
  }

  function send(channel, data) {
    this.socket.write(channel + '&' + data + "\n");
  }

}
