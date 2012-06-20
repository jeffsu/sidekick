var assert = require('assert');

var channel = "testing-subscribers";

module.exports = #(helper) {
  var client = helper.client();
  var server = helper.server();
  console.log(channel);

  assert.ok(! server.hasSubscribers(channel));
  assert.equal(server.subscriberCount(channel), 0);

  client.subscribe(channel, #{ });

  helper.delay(#{ 
    console.log(channel + ' should have 1 subscriber');
    assert.ok(server.hasSubscribers(channel));
    assert.equal(server.subscriberCount(channel), 1);
    client.end();
  });

  helper.delay(#{
    console.log(channel + ' should have 0 subscribers');
    assert.ok(! server.hasSubscribers(channel));
    assert.equal(server.subscriberCount(channel), 0);
  });
};
