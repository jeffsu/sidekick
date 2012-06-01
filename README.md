# Sidekick

Realtime site monitoring helper. Sidekick provides a few things:

  1. Insight to incomming requests and the ability to react to them in code
  1. Multiplexing http requests.  This is especially useful for testing live requests against a dev environment.
     
Please look into the examples directory for usage.

## Components in Sidekick

### Server

The sidekick server is a class that offers both the server and the middleware (connect) for your base application.

{{{
  var sidekick = require('./sidekick');
  sidekick.listen(7777);
  originalApp.use(sidekick.connect());
  originalApp.listen(7778);
}}}

At this point, you have your app running on port 7778 and a sidekick port running on 7777.  If you create a client
to access http://localhost:7777/data, you will see an incoming stream of json lines representing the requests coming 
in from the original app. 

Note: Accessing it in the browser is not a good way to view the data, you should use some kind of streaming programatic
client


### Client

The client is a way to tap into the sidekick server and subscribe to requests.

{{{
  var client = sidekick.Client(host, port);
  client.on('request', function (data) {
    /*
     * data == {
     *   headers: <hash>,
     *   path: <string>,
     *   method: <integer>
     * }
     *
     # ... do something ... 
     */
  });
}}}

