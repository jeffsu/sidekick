var assert = require('assert');
module.exports = function (helper) {
  console.log('trying to connect');
  var Client = require('../lib/sidekick/client');
  var client = new Client('localhost', 12345);
  var error = false;
  client.on('error', #{ console.log('connection error expected!'); error = true });
  helper.delay(#{ assert.ok(error); });
  client.end();
};
