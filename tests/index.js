require('mochiscript');

var connect  = require('connect');
var sidekick = require('../lib/sidekick');
var http     = require('http');


var SD_PORT    = 7777;
var ORIG_PORT  = 7778;
var CLONE_PORT = 7779;

var server = new sidekick.Server();
server.listen(SD_PORT);

// Create original app and attach sidekick server to it
var app = connect.createServer();
var count = 0;
app.use(server.connect());
app.use(connect.query());
app.use(function (req, res, next) { 
  server.publish(req.url);
  server.publish('count', ++count); 
  res.end(req.url);
});
app.listen(ORIG_PORT);

var delayN = 0;

var helper = {
  request: function (path) {
    http.get({ host: 'localhost', port: ORIG_PORT, path: path }, function (res) {});
  },

  client: function () {
    var client = new sidekick.Client('localhost', SD_PORT);
    return client;
  },

  delay: function (cb, n) {
    n = n ? n : delayN += 200;
    setTimeout(cb, n);
  }
}


require('./stop')(helper);
require('./no-connect')(helper);

