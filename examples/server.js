var connect  = require('connect');
var parasite = require('../lib/parasite');
var http     = require('http');

var pm  = parasite.middleware();
var app = connect.createServer();
app.use(pm.connect());
app.use(function (req, res, next) { res.end('hello'); });

app.listen(8080);
pm.listen(8079);

var tailer = new parasite.clients.Tailer('localhost', 8079);
tailer.on('request', function (request) {
  console.log(request.url);
});
tailer.start();
