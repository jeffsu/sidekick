var assert = require('assert');
module.exports = #(helper) {
  var client = helper.client();

  var n = 0;

  client.subscribe('/testing-stop', #{ n += 1; });

  // make connection
  helper.delay(#{ helper.request('/testing-stop') });
  helper.delay(#{ assert.equal(n, 1) });
  helper.delay(#{
    client.end();
    helper.request('/testing-stop');
  });

  helper.delay(#{ assert.equal(n, 1) });
};
