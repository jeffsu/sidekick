/*
 * A full on example of how to use sidekick as a proxy multiplexer
 * 1) create sd server
 * 2) create app
 * 3) create clone app
 * 4) create sd client
 * 5) create a proxy to multiplex the request
 */
var connect  = require('connect');
var sidekick = require('../lib/sidekick');
var http     = require('http');

var SD_PORT    = 7777;
var ORIG_PORT  = 7778;
var CLONE_PORT = 7779;

// Create sidekick server
var sd = new sidekick.Server();
sd.listen(SD_PORT);

// Create original app and attach sidekick server to it
var origApp = connect.createServer();
var count = 0;
origApp.use(sd.connect());
origApp.use(function (req, res, next) { 
  setTimeout(function () { 
    sd.emit('data', ++count); 
    console.log('Orig Server: Get request!');
    res.end("hello");
  }, 200);
});
origApp.listen(ORIG_PORT);

// Create clone app
var cloneApp = connect.createServer();
cloneApp.use(function (req, res, next) { 
  setTimeout(function () { 
    console.log('Clone app: Get request!');
    res.end("hello");
  }, 200);
});
cloneApp.listen(CLONE_PORT);

// Create sidekick client to listen to sidekick server
var client = new sidekick.Client('localhost', SD_PORT);
client.on('request', function (data) { 
  console.log("Sidekick Client: " + JSON.stringify(data));
});

client.on('data', function (data) {
  console.log('Sidekick Client Data: ' + JSON.stringify(data));
});

// Create proxy
var proxy = client.proxy('localhost', CLONE_PORT);
proxy.on('response', function (code, body, headers) {
  console.log("Proxy: got response.");
  console.log("--------------------------");
});

setInterval(function () { 
  console.log("External Request: Make request to original server");
  http.get({ host: 'localhost', port: ORIG_PORT, path: '/' }, function (res) {});
}, 1000);

