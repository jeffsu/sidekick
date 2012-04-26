var connect  = require('connect');
var sidekick = require('../lib/sidekick');
var http     = require('http');

var sd  = sidekick.middleware();
var app = connect.createServer();
app.use(sd.connect());
app.use(function (req, res, next) { res.end('hello'); });

app.listen(8080);
sd.listen(8079);

var tailer = new sidekick.clients.Tailer('localhost', 8079);
tailer.on('request', function (request) {
  console.log(request.url);
});
tailer.start();
