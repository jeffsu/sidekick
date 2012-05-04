var connect  = require('connect');
var sidekick = require('../lib/sidekick');
var http     = require('http');

var SERVER_PORT   = 8888;
var SERVER2_PORT  = 8889;

var SIDEKICK_PORT = 8887;

var sd  = sidekick.middleware();
var app = connect.createServer();
app.use(sd.connect());
app.use(function (req, res, next) { 
  setTimeout(function () { 
    res.end("hello");
  }, 200);
});

var app2 = connect.createServer();
app2.use(function (req, res, next) { 
  console.log('multiplexed');
  res.end('hello');
});

app2.listen(SERVER2_PORT);
app.listen(SERVER_PORT);
sd.listen(SIDEKICK_PORT);

var tailer = new sidekick.clients.Tailer('localhost', SIDEKICK_PORT);
tailer.on('request', function (request) { console.log(request.url); });
tailer.start();

var profiler = new sidekick.clients.Profiler('localhost', SIDEKICK_PORT);
profiler.on('request', function (data) { 
  console.log("Response Time: "    + data.responseTime); 
  console.log("Response headers: " + data.headers); 
});
profiler.start();

var multi = new sidekick.clients.multi.Multi();
multi.listen('localhost', SIDEKICK_PORT);
var client = new sidekick.clients.multi.Client('localhost', SERVER2_PORT);
client.on('data', function (chunk) { console.log('DATA: ' + chunk.toString()) });
multi.addClient(client);

console.log("Send requests to port: " + SERVER_PORT);
