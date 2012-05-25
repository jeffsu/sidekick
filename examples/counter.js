/*
 * A full on example of how to use sidekick as a proxy multiplexer
 * 1) create sd server
 * 2) create app
 * 5) create a proxy to multiplex the request
 */
var connect  = require('connect');
var sidekick = require('../lib/sidekick');
var http     = require('http');

var SD_PORT    = 7777;
var ORIG_PORT  = 7778;

// Create sidekick server
var sd = new sidekick.Server();
sd.listen(SD_PORT);

// Create original app and attach sidekick server to it
var origApp = connect.createServer();
origApp.use(sd.connect());
origApp.use(function (req, res, next) { 
  setTimeout(function () { 
    console.log('Orig Server: Get request!');
    res.end("hello");
  }, 200);
});
origApp.listen(ORIG_PORT);


// Create sidekick client to listen to sidekick server
var client = new sidekick.Client('localhost', SD_PORT);
var count = 0;
client.on('response', function (data) { 
  console.log("Number of Requests: " + ++count);
});


setInterval(function () { 
  console.log("External Request: Make request to original server");
  http.get({ host: 'localhost', port: ORIG_PORT, path: '/' }, function (res) {});
}, 1000);
