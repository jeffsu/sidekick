var connect  = require('connect');
var sidekick = require('../lib/sidekick');
var http     = require('http');

var SERVER_PORT   = 8888;
var SIDEKICK_PORT = 8887;

var sd  = sidekick.middleware();
var app = connect.createServer();
app.use(sd.connect());
app.use(function (req, res, next) { 
  setTimeout(function () { 
    res.end("hello");
  }, 200);
});

app.listen(SERVER_PORT);
sd.listen(SIDEKICK_PORT);

var tailer = new sidekick.clients.Tailer('localhost', SIDEKICK_PORT);
tailer.on('request', function (request) { console.log(request.url); });
tailer.start();

var profiler = new sidekick.clients.Profiler('localhost', SIDEKICK_PORT);
profiler.on('request', function (data) { 
  console.log("Response Status: "    + data.response.statusCode); 
  console.log("Response Time: "    + data.response.time); 
  console.log("Response headers: " + data.response.headers); 
});
profiler.start();
